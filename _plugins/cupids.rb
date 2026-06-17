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

  # Byline that links each author to their _people page (resolved by slug);
  # references with no matching person render as plain text.
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
  # Ranking metadata: `order` (ordinal, ascending) is the primary sort key and
  # is reserved for *pinning* a few items; everything else falls back to
  # alphabetical by `sort_name` (or `title`) so a large roster needs no manual
  # numbering. `category` (a machine-friendly group tag) and `status` are
  # carried through so templates can group/filter (e.g. the People roster).
  # `featured` lets the parent split the flagship item out of the grid.
  # Honors published: false.
  def collection_cards(name)
    site = @context.registers[:site]
    coll = site && site.collections[name.to_s]
    return [] unless coll
    coll.docs
        .reject { |d| d.data["published"] == false }
        .sort_by { |d| [(d.data["order"] || 9999), (d.data["sort_name"] || d.data["title"]).to_s] }
        .map do |d|
          {
            "tag"       => d.data["tag"],
            "title"     => d.data["title"],
            "body"      => (d.data["summary"] || d.data["description"]).to_s,
            "url"       => d.url,
            "featured"  => d.data["featured"] == true,
            "order"     => d.data["order"],
            "category"  => d.data["category"],
            "status"    => d.data["status"],
            "sort_name" => d.data["sort_name"],
            "meta"      => d.data["meta"],
            "bullets"   => d.data["bullets"],
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

  # True when the site has a static file at the given site-absolute path
  # (e.g. "/assets/img/headshots/vu.png"). Lets a template reference an
  # optional asset and skip the markup when the file hasn't been added yet —
  # the page degrades gracefully (and the link checker stays green) until the
  # image lands, then renders automatically once it does.
  def static_exists(path)
    needle = path.to_s.sub(%r{\A/+}, "")
    return false if needle.empty?
    site = @context.registers[:site]
    return false unless site
    site.static_files.any? { |f| f.relative_path.to_s.sub(%r{\A/+}, "") == needle }
  end

  # Slug (or list of slugs) -> linked canonical names, for people-reference
  # front matter (authors:, team:, advisors:, ...). Strict: an unknown slug
  # fails the build (see CupidsPeople.find!), so a reference can't silently rot.
  def people_links(refs)
    site = @context.registers[:site]
    Array(refs).map { |r| CupidsPeople.link(site, CupidsPeople.find!(site, r)) }
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

  # Resolve author reference(s) to {name, url} hashes via the _people
  # collection. References are slugs (display-name fallback for back-compat);
  # the name rendered is always the doc's canonical title, so a rename can't
  # drift a byline. A reference with no matching person renders as plain text
  # (guest authors) but logs a warning.
  def author_people(names)
    site = @context.registers[:site]
    Array(names).map do |ref|
      r = ref.to_s.strip
      doc = CupidsPeople.find(site, r)
      Jekyll.logger.warn "Byline:", "no _people match for '#{r}'" if doc.nil? && !r.empty?
      { "name" => (doc ? doc.data["title"] : r), "url" => (doc && doc.url) }
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

# --- People references -------------------------------------------------------
# Identity is the _people *slug* (the filename), never the display name — so a
# reference can't be ambiguous (slugs are unique) and the name shown is always
# the doc's canonical title (so a rename updates every reference automatically).
# Explicit references ({% person %}, people_links, the post_read hook) resolve
# STRICTLY: an unknown slug raises and fails the build. The byline resolves
# leniently, so a guest author with no profile can still render as plain text.
module CupidsPeople
  module_function

  def docs(site)
    coll = site.collections["people"]
    coll ? coll.docs : []
  end

  # The reference key for a person: explicit `slug:` front matter, else filename.
  def slug_of(doc)
    doc.data["slug"] || File.basename(doc.path, ".*")
  end

  # Resolve a reference (slug first, display-name fallback) to a doc, or nil.
  def find(site, ref)
    r = ref.to_s.strip
    return nil if r.empty?
    list = docs(site)
    list.find { |d| slug_of(d) == r } || list.find { |d| d.data["title"].to_s.strip == r }
  end

  # Strict resolve — raises (fails the build) when a reference doesn't match.
  def find!(site, ref)
    find(site, ref) || raise(
      "Unknown person '#{ref}'. Reference people by their _people slug; " \
      "known slugs: #{docs(site).map { |d| slug_of(d) }.sort.join(', ')}"
    )
  end

  # Anchor linking a person's canonical name to their profile page.
  def link(site, doc)
    %(<a class="person-link" href="#{site.config["baseurl"]}#{doc.url}">#{doc.data["title"]}</a>)
  end
end

# {% person <slug> %} — inline link to a person's profile; the link text is the
# person's canonical title. Liquid variables resolve, so {% person {{ ref }} %}
# works too. An unknown slug fails the build (see CupidsPeople.find!).
class PersonTag < Liquid::Tag
  def initialize(tag_name, markup, tokens)
    super
    @markup = markup.strip
  end

  def render(context)
    site = context.registers[:site]
    ref  = Liquid::Template.parse(@markup).render(context).to_s.strip
    CupidsPeople.link(site, CupidsPeople.find!(site, ref))
  end
end
Liquid::Template.register_tag("person", PersonTag)

# Build-time enforcement (the "constrained" guarantee):
#   1. Every people reference in front matter must resolve to a real person —
#      checked across all collections' published docs before rendering, so a
#      typo or a deleted person fails CI rather than shipping. (Inline
#      {% person %} references are enforced at render time, the same way.)
#   2. Every _people `category` should be a group declared in _data/people.yml;
#      an off-vocabulary category still renders but logs a warning (mirrors the
#      Dispatch `kinds:` vocabulary).
Jekyll::Hooks.register :site, :post_read do |site|
  %w[author authors team advisors contributors].each do |field|
    site.collections.each_value do |coll|
      coll.docs.each { |doc| Array(doc.data[field]).each { |r| CupidsPeople.find!(site, r) } }
    end
  end

  groups = (site.data.dig("people", "groups") || []).map { |g| g["key"] }
  CupidsPeople.docs(site).each do |doc|
    cat = doc.data["category"].to_s
    next if cat.empty? || groups.include?(cat)
    Jekyll.logger.warn "People:", "unknown category '#{cat}' in #{doc.relative_path} (add it to _data/people.yml)"
  end
end
