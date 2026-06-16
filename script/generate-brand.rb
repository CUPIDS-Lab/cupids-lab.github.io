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
M          = BRAND["mark"]
# Single-quote family names so they sit cleanly inside double-quoted SVG attrs.
MONO       = "'#{BRAND['fonts']['mono']}', ui-monospace, monospace"
SANS       = "'#{BRAND['fonts']['display']}', system-ui, sans-serif"
EMOJI_FONT = "'Apple Color Emoji','Segoe UI Emoji','Noto Color Emoji',sans-serif"

# ---- 8-bit "heart with arrow" mark -------------------------------------------
# The recurring Cupid idiom, redrawn as retro pixel art (a nod to a terminal /
# coding-agent aesthetic) rather than the proprietary Apple emoji. Pure <rect>s
# on an integer grid, so it's license-clean and renders identically everywhere.
#
# The heart is sampled from the implicit curve (x²+y²−1)³ − x²·y³ ≤ 0 onto a
# grid HEART_RES pixels wide; the arrow is a scalable 45° band. Bump HEART_RES
# to make the art finer (less coarse) — everything else scales with it.
HEART_RES = 26

# Compact number formatting for SVG coordinates (trim trailing zeros).
def nf(x)
  format("%.2f", x).sub(/\.?0+$/, "")
end

# Filled heart cells (cropped to bounds) + grid width/height, at `width` columns.
def build_heart(width)
  xmin, xmax = -1.25, 1.25
  ymin, ymax = -1.18, 1.42
  sx = (xmax - xmin) / width.to_f
  rows = ((ymax - ymin) / sx).ceil
  pts = []
  rows.times do |row|
    width.times do |col|
      x = xmin + (col + 0.5) * sx
      y = ymax - (row + 0.5) * sx
      pts << [col, row] if (x * x + y * y - 1.0)**3 - x * x * y * y * y <= 0.0
    end
  end
  minc = pts.map { |p| p[0] }.min
  minr = pts.map { |p| p[1] }.min
  set = {}
  pts.each { |(c, r)| set[[c - minc, r - minr]] = true }
  [set, set.keys.map { |k| k[0] }.max + 1, set.keys.map { |k| k[1] }.max + 1]
end

# The 8-bit heart-with-arrow, sized so its larger dimension is `size`, centered
# on (cx, cy). Returns an SVG <g> of crisp pixel <rect>s.
def pixel_mark(cx, cy, size)
  heart, hw, hh = build_heart(HEART_RES)
  cxh = (hw - 1) / 2.0
  cyh = (hh - 1) / 2.0

  cells = []  # [col, row, fill]

  # Heart body with 8-bit shading: a small sheen on the (arrow-free) right lobe
  # and a lower-right rim shadow.
  hl_cx, hl_cy, hl_r = hw * 0.64, hh * 0.25, hw * 0.13
  heart.each_key do |(c, r)|
    rim_lo = !heart[[c + 1, r]] || !heart[[c, r + 1]]   # open to the right or below
    fill =
      if (c + r) > (cxh + cyh + hh * 0.04) && rim_lo
        M["heart_lo"]
      elsif Math.hypot(c - hl_cx, r - hl_cy) <= hl_r
        M["heart_hi"]
      else
        M["heart"]
      end
    cells << [c, r, fill]
  end

  # Arrow: a 45° band piercing top-left → bottom-right. Work in rotated coords
  # u (along the shaft, increasing down-right) and v (across it). A triangular
  # head pokes out the upper-left; a forked fletch trails out the lower-right.
  us = heart.keys.map { |(c, r)| (c - cxh) + (r - cyh) }
  umin = us.min - hh * 0.16
  umax = us.max + hh * 0.22
  head_len   = hh * 0.52
  fletch_len = hh * 0.50
  shaft_vt   = [hh * 0.115, 1.8].max
  head_vt    = hh * 0.34
  fletch_vt  = hh * 0.40

  exp = (hh * 0.7).ceil
  arrow = {}  # [c,r] => fill (drawn on top of the heart so it reads as pierced)
  (-exp..(hh - 1 + exp)).each do |r|
    (-exp..(hw - 1 + exp)).each do |c|
      u = (c - cxh) + (r - cyh)
      v = (c - cxh) - (r - cyh)
      next if u < umin || u > umax
      fill = nil
      if u <= umin + head_len                       # arrowhead — triangle tapering to a point
        taper = head_vt * (u - umin) / head_len
        fill = M["arrow"] if v.abs <= taper
      elsif u >= umax - fletch_len                  # fletch — forked feathers at the tail
        taper = fletch_vt * (u - (umax - fletch_len)) / fletch_len
        fill = M["arrow_lo"] if v.abs <= taper && v.abs >= taper * 0.5
        fill = M["arrow"] if v.abs <= shaft_vt * 0.6 # thin spine joining the feathers
      elsif v.abs <= shaft_vt                        # shaft across the heart
        fill = M["arrow"]
      end
      arrow[[c, r]] = fill if fill
    end
  end
  arrow.each { |(c, r), fill| cells << [c, r, fill] }

  # Layout: scale the (heart ∪ arrow) grid so its larger side is `size`, centered.
  cols = cells.map { |x| x[0] }
  rows = cells.map { |x| x[1] }
  minc = cols.min; maxc = cols.max
  minr = rows.min; maxr = rows.max
  ncols = maxc - minc + 1
  nrows = maxr - minr + 1
  cell  = size.to_f / [ncols, nrows].max
  ox    = cx - ncols * cell / 2.0
  oy    = cy - nrows * cell / 2.0
  ov    = cell * 0.04  # hairline overlap so neighbouring pixels never seam when scaled

  rects = cells.map do |(c, r, fill)|
    x = ox + (c - minc) * cell
    y = oy + (r - minr) * cell
    %(<rect x="#{nf(x)}" y="#{nf(y)}" width="#{nf(cell + ov)}" height="#{nf(cell + ov)}" fill="#{fill}"/>)
  end.join("\n")

  %(<g shape-rendering="crispEdges">\n#{rects}\n</g>)
end

# An emoji glyph centered at (cx,cy), `size` tall, optionally rotated.
def emoji(cx, cy, size, glyph, rot = 0)
  t = %(<text x="#{cx}" y="#{cy}" font-size="#{size}" text-anchor="middle" dominant-baseline="central" font-family="#{EMOJI_FONT}">#{glyph}</text>)
  rot.zero? ? t : %(<g transform="rotate(#{rot} #{cx} #{cy})">#{t}</g>)
end

# XML-escape text destined for SVG content/attributes (the brand prompt can
# contain `<`, e.g. the ASCII heart "<3", which would otherwise be invalid XML).
def xesc(s)
  s.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
end

def doc(w, h, body)
  meta = "#{BRAND['name']} — generated from _data/brand.yml. #{BRAND['prompt'].to_s.gsub(/\s+/, ' ').strip}"
  %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{w} #{h}" width="#{w}" height="#{h}" role="img" aria-label="#{xesc(BRAND['name'])}">\n) +
    %(<metadata>#{xesc(meta)}</metadata>\n) +
    body + "\n</svg>\n"
end

def wordmark(x, y, size, anchor: "start")
  <<~SVG
    <text x="#{x}" y="#{y}" font-family="#{MONO}" font-weight="600" font-size="#{size}" text-anchor="#{anchor}" letter-spacing="0.01em">
      <tspan fill="#{C['ink']}">cupids</tspan><tspan fill="#{C['green']}">-</tspan><tspan fill="#{C['ink']}">lab</tspan>
    </text>
  SVG
end

# The rainbow heart bar, centered on cx — the Cupid 💘 leads, then the rest of
# the color-heart palette (the duplicate pink/💘 entry is dropped).
def palette_row(cx, y, gap, size)
  chars = [PRIMARY] + PALETTE.map { |p| p["char"] }.reject { |ch| ch == PRIMARY }
  total = (chars.length - 1) * gap
  startx = cx - total / 2.0
  chars.each_with_index.map { |ch, i| emoji(startx + i * gap, y, size, ch) }.join("\n")
end

def favicon
  doc(64, 64, %(<rect width="64" height="64" rx="13" fill="#{C['bg']}"/>\n) + pixel_mark(32, 32, 50))
end

# Standalone transparent mark for inline use in the site chrome (nav / footer).
def pixmark
  doc(96, 96, pixel_mark(48, 48, 86))
end

def avatar
  body = +""
  body << %(<rect width="512" height="512" rx="96" fill="#{C['bg']}"/>\n)
  body << %(<rect x="14" y="14" width="484" height="484" rx="84" fill="none" stroke="#{C['panel']}" stroke-width="2"/>\n)
  # 8-bit heart-with-arrow up top, then the wordmark — bigger, and with more
  # breathing room between the mark and the "cupids-lab" lockup below.
  body << pixel_mark(256, 198, 296)
  body << "\n" << wordmark(256, 456, 66, anchor: "middle")
  doc(512, 512, body)
end

def social(w, h)
  body = +""
  body << %(<rect width="#{w}" height="#{h}" fill="#{C['bg']}"/>\n)
  body << %(<rect x="0" y="0" width="#{w}" height="10" fill="#{C['gold']}"/>\n)
  body << %(<text x="80" y="#{(h * 0.40).round}" font-family="#{MONO}" font-size="26" letter-spacing="0.16em" fill="#{C['green']}">UNIVERSITY OF COLORADO · PUBLIC INTEREST DATA SCIENCE</text>\n)
  body << wordmark(80, (h * 0.40).round + 96, 92)
  body << "\n" << palette_row(w / 2.0, h - 70, 78, 46)
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

# A full "heart emoji map" background: a deterministic jittered grid of the
# palette hearts (with 💘 woven in) on the dark canvas.
def background(w, h)
  rng = Random.new(7)
  step = 120
  body = +%(<rect width="#{w}" height="#{h}" fill="#{C['bg']}"/>\n)
  body << %(<g opacity="0.5">\n)
  (0..(h / step)).each do |row|
    (0..(w / step)).each do |col|
      cx = col * step + step / 2 + rng.rand(-24..24)
      cy = row * step + step / 2 + rng.rand(-24..24)
      glyph = rng.rand < 0.28 ? PRIMARY : PALETTE[rng.rand(PALETTE.length)]["char"]
      body << emoji(cx, cy, 30 + rng.rand(34), glyph, rng.rand(-18..18)) << "\n"
    end
  end
  body << %(</g>)
  doc(w, h, body)
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
    when "pixmark" then pixmark
    when "avatar"  then avatar
    when "og"         then social(a["w"], a["h"])
    when "pattern"    then pattern
    when "background" then background(a["w"], a["h"])
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
