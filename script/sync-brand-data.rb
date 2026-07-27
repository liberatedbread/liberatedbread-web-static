#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Generates _data/brand.yml from the :root block in src/input.css.
#
# DESIGN §3.3 says brand colour lives in exactly one place. CSS custom
# properties cover everything Tailwind renders, but a few values have to appear
# in markup where CSS cannot reach — <meta name="theme-color"> is the current
# one. Rather than paste a hex into a template (which silently goes stale the
# next time the logo changes), those values are mirrored into a Jekyll data file
# and read as {{ site.data.brand.base }}.
#
# _data/brand.yml is GENERATED. Do not hand-edit it: change src/input.css and
# re-run. `npm run build:css` runs this automatically, and CI fails if the
# committed copy is stale — same contract as assets/tailwind.css.

require "yaml"

SOURCE = "src/input.css"
DEST   = "_data/brand.yml"

css  = File.read(SOURCE)
root = css[/:root\s*\{(.*?)\}/m, 1] or abort "error: no :root block found in #{SOURCE}"

tokens = root.scan(/--bread-([a-z-]+)\s*:\s*(#[0-9a-fA-F]{3,8})\s*;/)
abort "error: no --bread-* colour tokens found in #{SOURCE}" if tokens.empty?

data = tokens.to_h { |name, value| [name, value.downcase] }

header = <<~YAML
  # GENERATED FILE — DO NOT EDIT.
  # Mirrors the --bread-* colour tokens from #{SOURCE} so templates can read
  # them where CSS custom properties cannot reach (e.g. <meta name="theme-color">).
  # Regenerate with: npm run build:css   (or: ruby #{__FILE__.sub("#{Dir.pwd}/", "")})
YAML

File.write(DEST, header + data.to_yaml.sub(/\A---\n/, ""))
puts "#{DEST}: #{data.size} tokens (#{data.keys.join(', ')})"
