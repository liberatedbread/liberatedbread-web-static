#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Asserts the BUILT site agrees with the `phase0` master switch in _config.yml
# (DESIGN §9.6).
#
# `phase0` gates three separate things — the root page, sitemap coverage, and
# devices-feed autodiscovery. This checks all three against the flag, in both
# positions, so a half-flipped launch fails the build instead of shipping. The
# Phase 0 failure mode it exists to prevent is subtle: a root page that looks
# perfectly clean to a human while quietly advertising the unlaunched catalog
# to crawlers and feed readers.
#
#   ruby script/check-phase0.rb [site_dir]

require "yaml"

SITE = ARGV[0] || "_site"

config  = YAML.load_file("_config.yml")
phase0  = config.fetch("phase0")
index   = File.read(File.join(SITE, "index.html"))
sitemap = File.read(File.join(SITE, "sitemap.xml"))
locs    = sitemap.scan(%r{<loc>(.*?)</loc>}m).flatten.map(&:strip)

failures = []
def check(failures, ok, label)
  puts(ok ? "  ok    #{label}" : "  FAIL  #{label}")
  failures << label unless ok
end

puts "phase0: #{phase0.inspect}"

# The site feed is advertised in both phases — §9.6 wants the teaser linking a
# valid-but-empty feed.
check(failures, index.include?("/feed.xml"), "/ advertises the site feed")

if phase0
  puts "\nexpecting the Phase 0 teaser, and nothing advertised to machines:"
  check failures, index.include?("Reclaim your household hardware. Coming soon."),
        "/ is the coming-soon teaser"
  check failures, !index.include?("<nav"),
        "/ has no navigation bar"
  check failures, !index.include?("<script"),
        "/ ships no JavaScript"
  check failures, !index.include?("/devices/"),
        "/ does not link any device guide"
  check failures, !index.include?("/feed/devices.xml"),
        "/ does NOT advertise the devices feed"
  # Only the teaser is suppressed. The unlinked-but-reachable pages still serve
  # the devices feed to anyone who has already found them.
  devices_index = File.read(File.join(SITE, "devices", "index.html"))
  check failures, devices_index.include?("/feed/devices.xml"),
        "/devices/ still advertises the devices feed"
  check failures, locs == ["https://liberatedbread.com/"],
        "sitemap.xml lists only / (got #{locs.size}: #{locs.join(', ')})"
else
  puts "\nexpecting the launched site, fully advertised:"
  check failures, index.include?("Reclaim Your Household Hardware"),
        "/ is the full landing page"
  check failures, index.include?("/feed/devices.xml"),
        "/ advertises the devices feed"
  check failures, locs.size > 1,
        "sitemap.xml lists the whole site (#{locs.size} urls)"
  check failures, locs.include?("https://liberatedbread.com/"),
        "sitemap.xml includes /"
  Dir.glob("_devices/*.md").map { |f| File.basename(f, ".md") }.sort.each do |slug|
    check failures, locs.include?("https://liberatedbread.com/devices/#{slug}/"),
          "sitemap.xml includes /devices/#{slug}/"
  end
end

# Guards the mechanism itself: jekyll-sitemap regenerates its own all-inclusive
# sitemap the moment the source sitemap.xml disappears.
check failures, File.exist?("sitemap.xml"),
      "source sitemap.xml exists (deleting it hands generation back to jekyll-sitemap)"

if failures.empty?
  puts "\nOK — built site matches phase0: #{phase0.inspect}"
  exit 0
end

warn "\n#{failures.size} phase0 inconsistency(ies):"
failures.each { |f| warn "  - #{f}" }
warn "\nThe site does not match the phase0 flag in _config.yml. Either the flag"
warn "or the templates it gates is wrong — see PHASE0.md."
exit 1
