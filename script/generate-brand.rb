#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Brand asset harness. Digests the brand prompt + metadata in _data/brand.yml
# (see AGENTS.md "## Brand identity") and emits deterministic SVG assets into
# assets/brand/ — favicon, avatar/profile image, OG/social card, banner, and a
# tiling pattern — all built around the recurring "heart with arrow" motif.
#
# Usage:  ruby script/generate-brand.rb
require "yaml"
require "fileutils"

ROOT  = File.expand_path("..", __dir__)
BRAND = YAML.load_file(File.join(ROOT, "_data", "brand.yml"))
OUT   = File.join(ROOT, "assets", "brand")
FileUtils.mkdir_p(OUT)

C       = BRAND["colors"]
MARK    = BRAND["mark"]
PALETTE = BRAND["emoji"]["palette"]
MONO    = "#{BRAND['fonts']['mono']}, ui-monospace, monospace"
SANS    = "#{BRAND['fonts']['display']}, system-ui, sans-serif"

# A heart-with-arrow centered at (cx,cy), `size` tall, in `heart`/`arrow`
# colors. Unit artwork lives in a ~72-tall box centered on (50,46).
def heart_arrow(cx, cy, size, heart, arrow)
  k = size / 72.0
  sw = 7
  <<~SVG
    <g transform="translate(#{cx} #{cy}) scale(#{format('%.4f', k)}) translate(-50 -46)">
      <path d="M50 82 C 22 62 10 45 10 30 C 10 18 19 10 30 10 C 39 10 47 16 50 24 C 53 16 61 10 70 10 C 81 10 90 18 90 30 C 90 45 78 62 50 82 Z" fill="#{heart}"/>
      <g fill="none" stroke="#{arrow}" stroke-width="#{sw}" stroke-linecap="round" stroke-linejoin="round">
        <line x1="6" y1="74" x2="94" y2="26"/>
        <polyline points="80,22 94,26 90,40"/>
        <polyline points="2,60 6,74 20,70"/>
      </g>
    </g>
  SVG
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

# Row of small color-varied heart-arrows (the palette), centered on cx.
def palette_row(cx, y, gap, size)
  total = (PALETTE.length - 1) * gap
  startx = cx - total / 2.0
  PALETTE.each_with_index.map do |p, i|
    heart_arrow(startx + i * gap, y, size, p["color"], C["gold"])
  end.join("\n")
end

def favicon
  body = %(<rect width="64" height="64" rx="13" fill="#{C['bg']}"/>\n) + heart_arrow(32, 33, 46, MARK["heart"], MARK["arrow"])
  doc(64, 64, body)
end

def avatar
  body = +""
  body << %(<rect width="512" height="512" rx="96" fill="#{C['bg']}"/>\n)
  body << %(<rect x="14" y="14" width="484" height="484" rx="84" fill="none" stroke="#{C['panel']}" stroke-width="2"/>\n)
  body << heart_arrow(256, 224, 300, MARK["heart"], MARK["arrow"])
  body << wordmark(256, 430, 52, anchor: "middle")
  doc(512, 512, body)
end

def social(w, h)
  body = +""
  body << %(<rect width="#{w}" height="#{h}" fill="#{C['bg']}"/>\n)
  body << %(<rect x="0" y="0" width="#{w}" height="10" fill="#{C['gold']}"/>\n)
  body << %(<text x="80" y="#{h * 0.30}" font-family="#{MONO}" font-size="26" letter-spacing="0.16em" fill="#{C['green']}">UNIVERSITY OF COLORADO · PUBLIC INTEREST DATA SCIENCE</text>\n)
  body << wordmark(80, h * 0.30 + 96, 92)
  body << %(<text x="80" y="#{h * 0.30 + 176}" font-family="#{SANS}" font-weight="800" font-size="60" fill="#{C['ink']}">#{BRAND['tagline']}</text>\n)
  body << heart_arrow(w - 200, h * 0.42, 320, MARK["heart"], MARK["arrow"])
  body << palette_row(w / 2.0, h - 70, 72, 40)
  doc(w, h, body)
end

def pattern
  body = +""
  body << %(<rect width="240" height="240" fill="#{C['bg']}"/>\n)
  spots = [[60, 60, 0], [180, 110, 3], [110, 190, 6], [210, 220, 1], [30, 200, 4]]
  body << %(<g opacity="0.5">\n)
  spots.each { |x, y, i| body << heart_arrow(x, y, 34, PALETTE[i % PALETTE.length]["color"], C["gold"]) }
  body << %(</g>)
  doc(240, 240, body)
end

# A single transparent 64x64 heart-with-arrow icon, optionally rotated.
def heart_icon(color, rot, arrow)
  inner = heart_arrow(32, 33, 44, color, arrow)
  body = rot.zero? ? inner : %(<g transform="rotate(#{rot} 32 32)">\n#{inner}</g>)
  doc(64, 64, body)
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

# Heart-with-arrow variant collection: every palette color × each rotation.
v = BRAND["variants"]
if v
  vdir = File.join(OUT, v["dir"])
  FileUtils.mkdir_p(vdir)
  arrow = v["arrow"] || C["gold"]
  hearts = []
  PALETTE.each do |p|
    v["rotations"].each do |r|
      suffix = r.zero? ? "" : (r.negative? ? "-l#{r.abs}" : "-r#{r}")
      fname = "#{p['name']}#{suffix}.svg"
      File.write(File.join(vdir, fname), heart_icon(p["color"], r, arrow))
      hearts << fname
    end
  end
  puts "Generated #{hearts.length} heart-with-arrow variants in assets/brand/#{v['dir']}/."
end

