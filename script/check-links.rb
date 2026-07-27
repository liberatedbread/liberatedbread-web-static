#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Internal link checker for the built Jekyll site (DESIGN §16.1).
#
# Walks every HTML file in _site, collects each same-origin href/src/action, and
# asserts that something in _site actually answers it. Deliberately offline: it
# only checks links we ship, so it can never fail because someone else's server
# is down. External links are counted and listed, never fetched.
#
#   ruby script/check-links.rb [site_dir]
#
# Exits non-zero on the first broken internal reference.

require "set"

SITE  = ARGV[0] || "_site"
ORIGIN = "https://liberatedbread.com"

abort "error: #{SITE} does not exist — run `bundle exec jekyll build` first" unless Dir.exist?(SITE)

# Every path the built site can serve.
served = Set.new
Dir.glob("#{SITE}/**/*", File::FNM_DOTMATCH).each do |path|
  next unless File.file?(path)

  rel = path.delete_prefix("#{SITE}/")
  served << "/#{rel}"
  # /a/b/index.html is also served as /a/b/ and /a/b
  next unless File.basename(rel) == "index.html"

  dir = File.dirname(rel)
  if dir == "."
    served << "/"
  else
    served << "/#{dir}/"
    served << "/#{dir}"
  end
end

ATTR = /(?:href|src|action)\s*=\s*(?:"([^"]*)"|'([^']*)')/i

broken   = []
checked  = 0
external = Set.new

Dir.glob("#{SITE}/**/*.html").sort.each do |file|
  page = "/#{file.delete_prefix("#{SITE}/")}"
  File.read(file).scan(ATTR) do |dq, sq|
    raw = (dq || sq).to_s.strip
    next if raw.empty?

    # Same-origin absolute URLs are ours; rewrite them to a path and check.
    raw = raw.delete_prefix(ORIGIN) if raw.start_with?(ORIGIN)

    next if raw.start_with?("#", "mailto:", "tel:", "data:", "javascript:")

    if raw.start_with?("http://", "https://", "//")
      external << raw
      next
    end

    unless raw.start_with?("/")
      broken << [page, raw, "relative link — use an absolute path or `| relative_url`"]
      next
    end

    target = raw.split("#").first.split("?").first
    next if target.nil? || target.empty?

    checked += 1
    broken << [page, raw, "no such file in #{SITE}"] unless served.include?(target)
  end
end

puts "internal links checked: #{checked}"
puts "external links (not fetched): #{external.size}"

if broken.empty?
  puts "OK — no broken internal links"
  exit 0
end

warn "\n#{broken.size} broken internal link(s):"
broken.each { |page, link, why| warn "  #{page}\n    -> #{link}  (#{why})" }
exit 1
