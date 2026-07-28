#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Asserts Tailwind only scans files Jekyll can serve.
#
# The production stylesheet is committed and shipped directly. If Tailwind
# scans repository documentation excluded from Jekyll, ordinary prose can create
# new utilities and mutate assets/tailwind.css. _config.yml's exclude list is
# the authority for paths that are not web content.
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

puts "OK - Tailwind content exactly covers served paths"
