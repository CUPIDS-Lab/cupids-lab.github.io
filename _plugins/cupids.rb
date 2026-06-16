# frozen_string_literal: true
#
# CUPIDS Lab — custom Liquid filters ("converters").
#
# These abstract the design system's computed rules out of the templates so
# the layouts/components stay declarative. They run during `jekyll build`
# (the site deploys via GitHub Actions, which loads _plugins/).
module CupidsFilters
  ACCENTS = {
    "gold"  => "#cfb87c",
    "red"   => "#b23a2e",
    "green" => "#6fcf97",
    "amber" => "#e0a14e",
  }.freeze

  # Tag string -> accent color, matching the original design's precedence.
  def accent_color(tag)
    t = tag.to_s.upcase
    return ACCENTS["red"]   if t.include?("INVESTIGATION")
    return ACCENTS["amber"] if t.include?("RAPID") || t.include?("REPORT") || t.include?("ISSUE")
    return ACCENTS["green"] if t.include?("GUIDE") || t.include?("ARCHIVE")
    ACCENTS["gold"]
  end

  # Bullet accent key (green|amber|red|gold) -> color.
  def bullet_color(key)
    ACCENTS[key.to_s] || ACCENTS["gold"]
  end

  # Archive status tone (green|amber|red) -> CSS status class.
  def tone_class(tone)
    case tone.to_s
    when "green" then "st-preserved"
    when "red"   then "st-removed"
    else "st-archiving"
    end
  end

  # Resolve a dotted path into site.data, e.g. "people.advisors".
  # Returns nil if any segment is missing.
  def site_data(path)
    site = @context.registers[:site]
    return nil unless site
    path.to_s.split(".").reduce(site.data) { |acc, k| acc.is_a?(Hash) ? acc[k] : nil }
  end

  # Map dispatch collection docs -> card hashes (tag/title/body/meta/url) for
  # the card component. Accepts a list (or single doc); always returns a list.
  def dispatch_cards(list)
    Array(list).map do |d|
      meta = []
      author = d["author"].to_s
      meta << "By #{author}" unless author.empty?
      date = d["date"]
      meta << date.strftime("%b %Y") if date.respond_to?(:strftime)
      rt = d["reading_time"].to_s
      meta << rt unless rt.empty?
      {
        "tag"   => d["tag"],
        "title" => d["title"],
        "body"  => (d["summary"] || d["description"]).to_s,
        "meta"  => meta.join(" · "),
        "url"   => d["url"],
      }
    end
  end

  # Map a collection's docs -> card hashes for the card component, sorted by
  # `order` then title. `featured` is carried so the parent can split the
  # flagship item out of the grid. Honors published: false.
  def collection_cards(name)
    site = @context.registers[:site]
    coll = site && site.collections[name.to_s]
    return [] unless coll
    coll.docs
        .reject { |d| d.data["published"] == false }
        .sort_by { |d| [(d.data["order"] || 9999), d.data["title"].to_s] }
        .map do |d|
          {
            "tag"      => d.data["tag"],
            "title"    => d.data["title"],
            "body"     => (d.data["summary"] || d.data["description"]).to_s,
            "url"      => d.url,
            "featured" => d.data["featured"] == true,
          }
        end
  end

  # Prefix internal links with baseurl; leave absolute / mailto / anchor links alone.
  def smart_url(url)
    u = url.to_s
    return u if u.empty? || u.include?("://") || u.start_with?("mailto:", "#")
    site = @context.registers[:site]
    base = site ? site.config["baseurl"].to_s : ""
    "#{base}#{u}"
  end
end

Liquid::Template.register_filter(CupidsFilters)
