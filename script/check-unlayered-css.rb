#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Asserts that the rules which MUST outrank Tailwind's utilities are emitted
# outside every cascade layer in the built stylesheet.
#
# WHY THIS EXISTS
# ---------------
# Tailwind v4 emits `@layer theme, base, components, utilities`, and a later
# cascade layer beats an earlier one regardless of specificity. An *unlayered*
# rule beats all of them. `[data-lb-hidden] { display: none; }` — the entire
# mechanism behind the /devices/ filter (DESIGN §9.4) — therefore only works
# while it stays unlayered: the cards it hides carry the `flex` utility, so the
# same rule inside `@layer components` would lose and the filter would silently
# stop hiding anything. No error, no console warning, no visual difference in
# review — the buttons would just do nothing.
#
# src/input.css carries a comment saying so. Comments do not fail CI. This does.
# A refactor that tidies the rule into a layer, or an upstream change to how
# Tailwind wraps `@source`-derived CSS, fails the build here instead of shipping
# a dead filter.
#
# The fix is never `display: none !important` — that forces the rule past every
# layer at the cost of making the declaration unoverridable everywhere else.
# Keeping it unlayered is the correct cascade position, so that is what is
# checked.
#
#   ruby script/check-unlayered-css.rb [css_file]

CSS_FILE = ARGV[0] || "assets/tailwind.css"

# Selectors whose whole purpose is to beat a utility class, each with the
# declaration that has to survive with it. Position alone is not the point:
# `[data-lb-hidden]{display:block}` would sit in exactly the right place in the
# cascade and still leave the filter hiding nothing. Add to this list only for
# rules that genuinely need to outrank every layer.
REQUIRED_UNLAYERED = {
  "[data-lb-hidden]" => "display:none",
}.freeze

abort "error: #{CSS_FILE} does not exist — run `npm run build:css` first" unless File.exist?(CSS_FILE)

css = File.read(CSS_FILE)

# Walk the stylesheet once, tracking brace depth, and record the byte range of
# every `@layer NAME { ... }` block. Quoted strings are skipped so a brace
# inside `content: "}"` cannot desynchronise the depth count. The statement
# form, `@layer theme, base, components, utilities;`, declares order only and
# has no block — it is ignored, which is correct: it wraps nothing.
layer_ranges = []
open_layers  = []
depth        = 0
i            = 0

while i < css.length
  char = css[i]

  case char
  when '"', "'"
    quote = char
    i += 1
    i += 1 while i < css.length && !(css[i] == quote && css[i - 1] != "\\")
  when "@"
    if css[i, 6] == "@layer"
      # Look ahead to whichever comes first: the `{` that opens a block, or the
      # `;` that ends the statement form.
      brace = css.index("{", i)
      semi  = css.index(";", i)
      open_layers << [i, depth] if brace && (semi.nil? || brace < semi)
    end
  when "{"
    depth += 1
  when "}"
    depth -= 1
    if !open_layers.empty? && open_layers.last[1] == depth
      start, = open_layers.pop
      layer_ranges << (start..i)
    end
  end

  i += 1
end

failures = []

def check(failures, ok, label)
  puts(ok ? "  ok    #{label}" : "  FAIL  #{label}")
  failures << label unless ok
end

puts "#{CSS_FILE}: #{css.bytesize} bytes, #{layer_ranges.size} @layer block(s)"

if layer_ranges.empty?
  warn "\nerror: no @layer blocks found in #{CSS_FILE}."
  warn "Tailwind always emits some — the stylesheet is probably not a real build."
  exit 1
end

last_layer_end = layer_ranges.map(&:last).max
puts "final @layer closing brace at byte #{last_layer_end}\n\n"

REQUIRED_UNLAYERED.each do |selector, declaration|
  offsets = []
  from = 0
  while (found = css.index(selector, from))
    offsets << found
    from = found + 1
  end

  if offsets.empty?
    check failures, false, "#{selector} is present in the built CSS"
    next
  end

  check failures, true, "#{selector} is present in the built CSS (#{offsets.size} occurrence(s))"

  offsets.each do |offset|
    containing = layer_ranges.select { |range| range.cover?(offset) }
    check failures, containing.empty?,
          "#{selector} at byte #{offset} is outside every @layer" \
          "#{containing.empty? ? '' : " (nested in #{containing.size} layer block(s))"}"
    check failures, offset > last_layer_end,
          "#{selector} at byte #{offset} is emitted after the final @layer closing brace (#{last_layer_end})"

    # Position without effect is not a pass. Read the declaration block the
    # selector actually opens and assert the declaration that does the work is
    # still in it — `[data-lb-hidden]{display:block}` would satisfy every check
    # above and hide nothing at all.
    open_brace = css.index("{", offset)
    close_brace = open_brace && css.index("}", open_brace)
    block = open_brace && close_brace ? css[(open_brace + 1)...close_brace] : nil
    normalised = block&.gsub(/\s+/, "")
    check failures, normalised&.include?(declaration.gsub(/\s+/, "")),
          "#{selector} at byte #{offset} still declares `#{declaration}`" \
          "#{normalised.nil? ? ' — could not read its declaration block' : " (got `#{block.strip}`)"}"
  end
end

if failures.empty?
  puts "\nOK — every rule that must beat the utility layer is unlayered and intact"
  exit 0
end

warn "\n#{failures.size} cascade failure(s):"
failures.each { |f| warn "  - #{f}" }
warn "\nA rule listed in REQUIRED_UNLAYERED has to sit outside every cascade"
warn "layer to outrank Tailwind's utilities, AND still carry the declaration"
warn "that does the work. In src/input.css, keep it at the top level of the"
warn "file — not inside @layer base/components/utilities — and do not change"
warn "what it declares."
warn "Do not 'fix' this with !important; the cascade position is the point."
exit 1
