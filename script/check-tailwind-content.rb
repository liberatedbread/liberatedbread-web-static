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
  exclusions.any? do |entry|
    entry = normalize(entry)
    if entry.end_with?("/")
      rel.start_with?(entry)
    else
      rel == entry
    end
  end
end

config = YAML.load_file(CONFIG)
exclusions = Array(config.fetch("exclude")).map(&:to_s)

tailwind = File.read(TAILWIND_CONFIG)
content_body = tailwind[/content:\s*\[(.*?)\]/m, 1]
abort "error: could not find `content: [...]` in #{TAILWIND_CONFIG}" unless content_body

patterns = content_body.scan(/["']([^"']+)["']/).flatten.map do |pattern|
  [pattern, "."]
end

tailwind_input = File.read(TAILWIND_INPUT)
unless tailwind_input.match?(/^\s*@import\s+["']tailwindcss["']\s+source\(none\)\s*;/)
  abort "error: #{TAILWIND_INPUT} must import Tailwind with source(none)"
end

source_patterns = tailwind_input.scan(/^\s*@source\s+(?:not\s+)?["']([^"']+)["']\s*;/).flatten
source_patterns.each do |pattern|
  patterns << [pattern, File.dirname(TAILWIND_INPUT)]
end

abort "error: no Tailwind content sources found" if patterns.empty?

matched = Set.new
patterns.each do |pattern, base|
  next if pattern.start_with?("!")

  Dir.glob(File.join(base, pattern), File::FNM_DOTMATCH).each do |path|
    matched << normalize(path) if File.file?(path)
  end
end

offenders = matched.select { |path| excluded?(path, exclusions) }.sort

puts "Tailwind content files checked: #{matched.size}"

if offenders.empty?
  puts "OK - Tailwind content excludes non-served paths"
  exit 0
end

warn "\n#{offenders.size} Tailwind content path(s) are excluded from Jekyll:"
offenders.each { |path| warn "  - #{path}" }
warn "\nRemove them from tailwind.config.js content, or remove them from"
warn "#{CONFIG} exclude if they are intentionally served pages."
exit 1
