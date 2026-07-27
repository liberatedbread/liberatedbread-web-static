source "https://rubygems.org"

# Mirrors the exact gem set GitHub Pages runs, so a green local build means a
# green deploy. Do not pin jekyll directly — github-pages resolves it.
gem "github-pages", group: :jekyll_plugins

# Plugins in the GitHub Pages allowlist that this site uses.
group :jekyll_plugins do
  gem "jekyll-feed"
  gem "jekyll-redirect-from"
  gem "jekyll-sitemap"
end

# Windows/JRuby timezone data — harmless elsewhere.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "webrick", "~> 1.8"
