#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Validates the verification keys in every device guide's front matter.
#
# WHY THIS EXISTS
# ---------------
# _layouts/device.html gates the "Verified:" row, the "Verified on firmware"
# label and the "Not yet verified on hardware" status block on
# `page.hardware_verified == true`, compared against the boolean rather than
# tested for truthiness. It has to: in Liquid the only falsy values are `false`
# and `nil`, so `{% if page.hardware_verified %}` treats the YAML string
# "false" — quoted by accident — as a verification claim.
#
# Comparing against `true` makes any malformed value degrade to UNVERIFIED,
# which is the safe direction. But it degrades SILENTLY: an author who writes
# `hardware_verified: "true"` has made a real claim, in good faith, and gets a
# page that quietly says the opposite with nothing to explain why. That is the
# case this script exists to make loud.
#
# So the rule is: `hardware_verified` must be a genuine YAML boolean, and
# claiming verification requires the evidence to go with it.
#
#   ruby script/check-device-frontmatter.rb [devices_dir]

require "yaml"
require "date"

DIR = ARGV[0] || "_devices"

files = Dir.glob(File.join(DIR, "*.md")).sort
abort "error: no device guides found in #{DIR}" if files.empty?

failures = []

def check(failures, ok, label)
  puts(ok ? "  ok    #{label}" : "  FAIL  #{label}")
  failures << label unless ok
end

puts "device guides: #{files.size}"

files.each do |path|
  raw = File.read(path)
  unless raw.start_with?("---\n")
    check failures, false, "#{path} starts with a front-matter block"
    next
  end

  # Everything between the opening --- and the next --- on its own line.
  body = raw.split(/^---\s*$/, 3)[1]
  front = begin
    # permitted_classes lets a bare `last_verified: 2026-07-25` load as a Date
    # instead of raising, which is exactly how Jekyll reads it.
    YAML.safe_load(body, permitted_classes: [Date, Time])
  rescue Psych::Exception => e
    check failures, false, "#{path} front matter parses as YAML (#{e.message})"
    next
  end

  name = File.basename(path)

  if front.key?("hardware_verified")
    value = front["hardware_verified"]
    boolean = value.is_a?(TrueClass) || value.is_a?(FalseClass)
    check failures, boolean,
          "#{name}: hardware_verified is a YAML boolean" \
          "#{boolean ? " (#{value})" : " — got #{value.class}: #{value.inspect}. " \
             'Write `hardware_verified: true`, unquoted. A quoted "true" is not a ' \
             'claim the layout will honour, and this is the check that says so ' \
             'instead of letting the page silently read as unverified.'}"

    if value == true
      # The claim is only well formed with the evidence attached. The layout
      # already refuses to honour a flag without a date; without this, that
      # refusal is invisible to whoever set the flag.
      date = front["last_verified"]
      check failures, !date.nil?,
            "#{name}: hardware_verified: true is accompanied by last_verified" \
            "#{date.nil? ? ' — the layout will not honour the claim without it' : ''}"

      unless date.nil?
        parsed = date.is_a?(Date) || date.is_a?(Time) ||
                 (date.is_a?(String) && (Date.parse(date) rescue false))
        check failures, parsed,
              "#{name}: last_verified parses as a date (#{date.inspect})"
      end
    end
  else
    # The ordinary case, and the one the whole scheme is built around.
    puts "  ok    #{name}: no verification claim — renders the status block"
  end
end

if failures.empty?
  puts "\nOK — every device guide's verification keys are well formed"
  exit 0
end

warn "\n#{failures.size} device front-matter problem(s):"
failures.each { |f| warn "  - #{f}" }
warn "\n`hardware_verified` must be an unquoted YAML boolean, and a `true` claim"
warn "must carry a `last_verified` date. See contribute/device-template.md."
exit 1
