source "https://rubygems.org"

# Jekyll 4.x — the site is built and deployed via GitHub Actions
# (not the legacy github-pages gem), so we can use a current Jekyll.
gem "jekyll", "~> 4.4"

# Plugins
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-sitemap", "~> 1.4"
end

# Link / HTML validation in CI
gem "html-proofer", "~> 5.0", group: :test

# Boilerplate for newer Rubies that dropped default gems
gem "webrick", "~> 1.8"
gem "csv"
gem "base64"
gem "bigdecimal"

# Windows / JRuby helpers (harmless elsewhere)
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
gem "wdm", "~> 0.1.1", platforms: [:mingw, :x64_mingw, :mswin]
