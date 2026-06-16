#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Brand asset harness. Digests the brand prompt + metadata in _data/brand.yml
# (see AGENTS.md "## Brand identity") and emits deterministic SVG assets into
# assets/brand/ — favicon, avatar/profile image, OG/social card, banner, and a
# tiling pattern — all built around the recurring "heart with arrow" emoji 💘.
#
# The emoji is rendered as SVG <text>, so it uses the viewer's color-emoji font
# (on Apple devices it IS the Apple glyph). We deliberately do NOT embed Apple's
# proprietary artwork — that keeps the repo license-clean.
#
# Usage:  ruby script/generate-brand.rb
require "yaml"
require "fileutils"

ROOT  = File.expand_path("..", __dir__)
BRAND = YAML.load_file(File.join(ROOT, "_data", "brand.yml"))
OUT   = File.join(ROOT, "assets", "brand")
FileUtils.mkdir_p(OUT)

C          = BRAND["colors"]
PALETTE    = BRAND["emoji"]["palette"]
PRIMARY    = BRAND["emoji"]["primary"]
# Single-quote family names so they sit cleanly inside double-quoted SVG attrs.
MONO       = "'#{BRAND['fonts']['mono']}', ui-monospace, monospace"
SANS       = "'#{BRAND['fonts']['display']}', system-ui, sans-serif"
EMOJI_FONT = "'Apple Color Emoji','Segoe UI Emoji','Noto Color Emoji',sans-serif"

# An emoji glyph centered at (cx,cy), `size` tall, optionally rotated.
def emoji(cx, cy, size, glyph, rot = 0)
  t = %(<text x="#{cx}" y="#{cy}" font-size="#{size}" text-anchor="middle" dominant-baseline="central" font-family="#{EMOJI_FONT}">#{glyph}</text>)
  rot.zero? ? t : %(<g transform="rotate(#{rot} #{cx} #{cy})">#{t}</g>)
end

def doc(w, h, body)
  %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{w} #{h}" width="#{w}" height="#{h}" role="img" aria-label="#{BRAND['name']}">\n) +
    %(<metadata>#{BRAND['name']} — generated from _data/brand.yml. #{BRAND['prompt'].to_s.gsub(/\s+/, ' ').strip}</metadata>\n) +
    body + "\n</svg>\n"
end

def wordmark(x, y, size, anchor: "start")
  <<~SVG
    <text x="#{x}" y="#{y}" font-family="#{MONO}" font-weight="600" font-size="#{size}" text-anchor="#{anchor}" letter-spacing="0.01em">
      <tspan fill="#{C['ink']}">cupids</tspan><tspan fill="#{C['green']}">-</tspan><tspan fill="#{C['ink']}">lab</tspan><tspan fill="#{C['red']}">&lt;3</tspan>
    </text>
  SVG
end

# A row of the palette heart emoji, centered on cx.
def palette_row(cx, y, gap, size)
  total = (PALETTE.length - 1) * gap
  startx = cx - total / 2.0
  PALETTE.each_with_index.map { |p, i| emoji(startx + i * gap, y, size, p["char"]) }.join("\n")
end

def favicon
  doc(64, 64, %(<rect width="64" height="64" rx="13" fill="#{C['bg']}"/>\n) + emoji(32, 32, 46, PRIMARY))
end

def avatar
  body = +""
  body << %(<rect width="512" height="512" rx="96" fill="#{C['bg']}"/>\n)
  body << %(<rect x="14" y="14" width="484" height="484" rx="84" fill="none" stroke="#{C['panel']}" stroke-width="2"/>\n)
  body << emoji(256, 220, 300, PRIMARY)
  body << "\n" << wordmark(256, 430, 52, anchor: "middle")
  doc(512, 512, body)
end

def social(w, h)
  body = +""
  body << %(<rect width="#{w}" height="#{h}" fill="#{C['bg']}"/>\n)
  body << %(<rect x="0" y="0" width="#{w}" height="10" fill="#{C['gold']}"/>\n)
  body << %(<text x="80" y="#{(h * 0.30).round}" font-family="#{MONO}" font-size="26" letter-spacing="0.16em" fill="#{C['green']}">UNIVERSITY OF COLORADO · PUBLIC INTEREST DATA SCIENCE</text>\n)
  body << wordmark(80, (h * 0.30).round + 96, 92)
  body << %(<text x="80" y="#{(h * 0.30).round + 176}" font-family="#{SANS}" font-weight="800" font-size="60" fill="#{C['ink']}">#{BRAND['tagline']}</text>\n)
  body << emoji(w - 210, (h * 0.46).round, 300, PRIMARY)
  body << "\n" << palette_row(w / 2.0, h - 64, 78, 46)
  doc(w, h, body)
end

def pattern
  body = +""
  body << %(<rect width="240" height="240" fill="#{C['bg']}"/>\n)
  spots = [[60, 60, 0], [180, 110, 3], [110, 190, 6], [210, 220, 1], [30, 200, 4]]
  body << %(<g opacity="0.6">\n)
  spots.each { |x, y, i| body << emoji(x, y, 40, PALETTE[i % PALETTE.length]["char"]) << "\n" }
  body << %(</g>)
  doc(240, 240, body)
end

# A single transparent 64x64 heart emoji icon, optionally rotated.
def heart_icon(glyph, rot)
  doc(64, 64, emoji(32, 32, 46, glyph, rot))
end

generated = []
BRAND["assets"].each do |a|
  svg =
    case a["kind"]
    when "mark"    then favicon
    when "avatar"  then avatar
    when "og"      then social(a["w"], a["h"])
    when "pattern" then pattern
    end
  next unless svg
  File.write(File.join(OUT, a["file"]), svg)
  generated << a["file"]
end

puts "Generated #{generated.length} brand assets in assets/brand/:"
generated.each { |f| puts "  - #{f}" }

# Heart emoji variant collection: every palette heart × each rotation.
v = BRAND["variants"]
if v
  vdir = File.join(OUT, v["dir"])
  FileUtils.mkdir_p(vdir)
  hearts = []
  PALETTE.each do |p|
    v["rotations"].each do |r|
      suffix = r.zero? ? "" : (r.negative? ? "-l#{r.abs}" : "-r#{r}")
      fname = "#{p['name']}#{suffix}.svg"
      File.write(File.join(vdir, fname), heart_icon(p["char"], r))
      hearts << fname
    end
  end
  puts "Generated #{hearts.length} heart-emoji variants in assets/brand/#{v['dir']}/."
end
