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
      author = author_names(d["authors"] || d["author"])
      meta << "By #{author}" unless author.empty?
      date = d["date"]
      meta << date.strftime("%b %Y") if date.respond_to?(:strftime)
      rt = reading_time(d.content)
      meta << rt unless rt.empty?
      {
        "tag"    => dispatch_tag(d),
        "accent" => dispatch_accent(d),
        "title"  => d["title"],
        "body"   => (d["summary"] || d["description"]).to_s,
        "meta"   => meta.join(" · "),
        "url"    => d["url"],
      }
    end
  end

  # Reading-time estimate from content length (~200 wpm), minimum 1 min.
  # Strips tags so it works on rendered HTML pages and raw Markdown docs alike.
  def reading_time(content)
    words = content.to_s.gsub(/<[^>]+>/, " ").split(/\s+/).reject(&:empty?).size
    minutes = (words / 200.0).ceil
    minutes = 1 if minutes < 1
    "#{minutes} min read"
  end

  # Composed display tag for a dispatch doc, from the controlled vocabulary in
  # _data/dispatch.yml: "ISSUE 01 · ANNOUNCEMENT" (or just the label when no
  # `issue:` is set). An explicit `tag:` in front matter overrides composition.
  def dispatch_tag(doc)
    explicit = doc["tag"].to_s
    return explicit unless explicit.empty?
    label = dispatch_kind(doc["kind"]).fetch("label") { doc["kind"].to_s.upcase }
    issue = doc["issue"].to_s.strip
    issue.empty? ? label : format("ISSUE %02d · %s", issue.to_i, label)
  end

  # Accent color for a dispatch doc's tag, from the vocabulary kind (falls back
  # to the substring rules in accent_color when only an explicit tag is given).
  def dispatch_accent(doc)
    explicit = doc["tag"].to_s
    return accent_color(explicit) unless explicit.empty?
    bullet_color(dispatch_kind(doc["kind"])["accent"])
  end

  # Byline that links each author to their _people page (matched by title);
  # names with no matching person render as plain text.
  def author_byline(names)
    base = author_baseurl
    join_authors(author_people(names).map { |a|
      a["url"] ? %(<a href="#{base}#{a["url"]}">#{a["name"]}</a>) : a["name"]
    })
  end

  # Plain-text author list (no links), for card meta lines.
  def author_names(names)
    join_authors(author_people(names).map { |a| a["name"] })
  end

  # Map a collection's docs -> card hashes for the card component.
  # Ranking metadata: `order` (ordinal, ascending) is the primary sort key;
  # `category` (a machine-friendly group tag) is carried through so templates
  # can group or filter. `featured` lets the parent split the flagship item
  # out of the grid. Honors published: false.
  def collection_cards(name)
    site = @context.registers[:site]
    coll = site && site.collections[name.to_s]
    return [] unless coll
    coll.docs
        .reject { |d| d.data["published"] == false }
        .sort_by { |d| [(d.data["order"] || 9999), d.data["category"].to_s, d.data["title"].to_s] }
        .map do |d|
          {
            "tag"      => d.data["tag"],
            "title"    => d.data["title"],
            "body"     => (d.data["summary"] || d.data["description"]).to_s,
            "url"      => d.url,
            "featured" => d.data["featured"] == true,
            "order"    => d.data["order"],
            "category" => d.data["category"],
            "meta"     => d.data["meta"],
            "bullets"  => d.data["bullets"],
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

  private

  # A vocabulary entry ({label, accent}) for a kind key, from _data/dispatch.yml.
  # Returns {} for a blank kind; warns once for an unknown (off-vocabulary) one.
  def dispatch_kind(key)
    key = key.to_s
    return {} if key.empty?
    vocab = site_data("dispatch.kinds") || {}
    return vocab[key] if vocab.key?(key)
    @warned_kinds ||= {}
    unless @warned_kinds[key]
      Jekyll.logger.warn "Dispatch:", "unknown kind '#{key}' (not in _data/dispatch.yml)"
      @warned_kinds[key] = true
    end
    {}
  end

  def author_baseurl
    site = @context.registers[:site]
    site ? site.config["baseurl"].to_s : ""
  end

  # Resolve author name(s) to {name, url} hashes via the _people collection,
  # matched on `title`. url is nil when no person matches the name.
  def author_people(names)
    site = @context.registers[:site]
    people = site && site.collections["people"] ? site.collections["people"].docs : []
    Array(names).map do |name|
      n = name.to_s.strip
      doc = people.find { |d| d.data["title"].to_s.strip == n }
      { "name" => n, "url" => (doc && doc.url) }
    end
  end

  # Join author parts with an Oxford-style "&" for the final pair.
  def join_authors(parts)
    parts = parts.reject { |p| p.to_s.empty? }
    case parts.size
    when 0 then ""
    when 1 then parts[0]
    when 2 then "#{parts[0]} &amp; #{parts[1]}"
    else "#{parts[0..-2].join(", ")} &amp; #{parts[-1]}"
    end
  end
end

Liquid::Template.register_filter(CupidsFilters)
