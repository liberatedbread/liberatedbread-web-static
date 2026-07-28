#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Asserts Tailwind's source list and Jekyll's output agree, in both directions:
#
#   1. Tailwind scans nothing Jekyll excludes. The production stylesheet is
#      committed and shipped directly, so if Tailwind scans repository
#      documentation excluded from Jekyll, ordinary prose can create new
#      utilities and mutate assets/tailwind.css. _config.yml's exclude list is
#      the authority for paths that are not web content.
#   2. Tailwind scans everything that reaches the built HTML - every served
#      page, and every layout and include. A file missing from the source list
#      compiles no classes, which is silent: the page still builds, the markup
#      still ships, and the styling is just gone.
#
#   ruby script/check-tailwind-content.rb

require "set"
require "yaml"
require "pathname"

CONFIG = "_config.yml"
TAILWIND_CONFIG = "tailwind.config.js"
TAILWIND_INPUT = "src/input.css"

def normalize(path)
  Pathname.new(path).cleanpath.to_s.sub(%r{\A\./}, "").sub(%r{\A/}, "")
end

def excluded?(path, exclusions)
  rel = normalize(path)
  exclusions.any? do |raw|
    entry = normalize(raw)
    rel == entry ||
      rel.start_with?("#{entry}/") ||
      File.fnmatch?(entry, rel, File::FNM_PATHNAME) ||
      File.fnmatch?(entry, rel)
  end
end

def front_matter?(path)
  File.open(path) { |file| file.readline.chomp == "---" }
rescue EOFError
  false
end

config = YAML.load_file(CONFIG)
exclusions = Array(config.fetch("exclude")).map(&:to_s)

tailwind = File.read(TAILWIND_CONFIG)
if tailwind.match?(/^\s*content\s*:/)
  abort "error: #{TAILWIND_CONFIG} must not define content; use @source in #{TAILWIND_INPUT}"
end

tailwind_input = File.read(TAILWIND_INPUT)
unless tailwind_input.match?(/^\s*@import\s+["']tailwindcss["']\s+source\(none\)\s*;/)
  abort "error: #{TAILWIND_INPUT} must import Tailwind with source(none)"
end

source_patterns = tailwind_input.scan(/^\s*@source\s+(not\s+)?["']([^"']+)["']\s*;/)
abort "error: no Tailwind @source paths found in #{TAILWIND_INPUT}" if source_patterns.empty?

matched = Set.new
negated = Set.new
base = File.dirname(TAILWIND_INPUT)

source_patterns.each do |not_keyword, pattern|
  target = not_keyword ? negated : matched
  Dir.glob(File.join(base, pattern), File::FNM_DOTMATCH).each do |path|
    target << normalize(path) if File.file?(path)
  end
end

matched.subtract(negated)
offenders = matched.select { |path| excluded?(path, exclusions) }.sort

puts "Tailwind content files checked: #{matched.size}"

unless offenders.empty?
  warn "\n#{offenders.size} Tailwind content path(s) are excluded from Jekyll:"
  offenders.each { |path| warn "  - #{path}" }
  warn "\nRemove them from #{TAILWIND_INPUT} @source paths, or remove them from"
  warn "#{CONFIG} exclude if they are intentionally served pages."
  exit 1
end

renderable = Dir.glob("**/*.{md,html}").reject do |path|
  path.start_with?("_site/", "node_modules/", "vendor/", "assets/") ||
    excluded?(path, exclusions) ||
    File.basename(path).start_with?(".", "_", "#", "~")
end.select { |path| File.file?(path) && front_matter?(path) }

unscanned = renderable.reject { |path| matched.include?(normalize(path)) }.sort

unless unscanned.empty?
  warn "\n#{unscanned.size} served page(s) NOT scanned by Tailwind - their classes will not compile:"
  unscanned.each { |path| warn "  - #{path}" }
  exit 1
end

# Jekyll's template directories, checked separately because the served-page
# test above cannot see them. That test keys on front matter, and a template
# need not have any: all of _includes is partials, and _layouts/base.html
# opens with <!DOCTYPE html>. Layout coverage was therefore accidental - it
# held only because home/default/device.html happen to carry `layout:` front
# matter - and _includes was invisible outright.
#
# That mattered in production. Dropping the _includes @source line left this
# guard green while .accent-bread-accent and .shrink-0 vanished from the
# compiled stylesheet, rendering the subscribe checkbox in browser-default
# blue. "Verify committed Tailwind build" cannot catch it either: it only
# proves the commit matches a rebuild, and the rebuild is wrong the same way.
#
# The directories are globbed for the files actually on disk rather than
# asserted against a hardcoded list of expected @source patterns. That keeps
# the requirement from drifting: a newly added include is demanded
# automatically, and any @source glob that genuinely covers these files
# satisfies it. The directory names come from _config.yml, so renaming a
# template directory there cannot silently void the check.
template_dirs = [
  config.fetch("layouts_dir", "_layouts"),
  config.fetch("includes_dir", "_includes")
].map { |dir| normalize(dir) }

templates = template_dirs.flat_map { |dir| Dir.glob("#{dir}/**/*.{html,md}") }
                         .select { |path| File.file?(path) }
                         .reject { |path| File.basename(path).start_with?(".", "#", "~") }
                         .map { |path| normalize(path) }
                         .sort
                         .uniq

unscanned_templates = templates.reject { |path| matched.include?(path) }

puts "Jekyll template files required: #{templates.size}"

unless unscanned_templates.empty?
  warn "\n#{unscanned_templates.size} template file(s) NOT scanned by Tailwind - their classes will not compile:"
  unscanned_templates.each { |path| warn "  - #{path}" }
  warn "\nEvery class in a layout or include reaches the built HTML, so Tailwind"
  warn "must scan them. Add the missing @source line(s) to #{TAILWIND_INPUT}:"
  unscanned_templates.map { |path| path.split("/").first }.uniq.sort.each do |dir|
    warn "  @source \"../#{dir}/**/*.html\";"
  end
  exit 1
end

puts "OK - Tailwind content exactly covers served paths and Jekyll templates"
