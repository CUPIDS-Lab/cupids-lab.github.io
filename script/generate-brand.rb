#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Brand asset harness. Digests the brand prompt + metadata in _data/brand.yml
# (see AGENTS.md "## Brand identity") and emits deterministic SVG assets into
# assets/brand/ — favicon, avatar/profile image, OG/social card, banner, and a
# tiling pattern — all built around the central conceit: a "folder with arrow",
# CUPID's golden arrow piercing open a magenta-pink file folder.
#
# The logo mark is the cleaned seed SVG; the decorative art is drawn from a
# palette of recolored file folders. All artwork is our own vectors.
#
# Usage:  ruby script/generate-brand.rb
require "yaml"
require "fileutils"

ROOT  = File.expand_path("..", __dir__)
BRAND = YAML.load_file(File.join(ROOT, "_data", "brand.yml"))
OUT   = File.join(ROOT, "assets", "brand")
FileUtils.mkdir_p(OUT)

C          = BRAND["colors"]
PALETTE    = BRAND["motif"]["palette"]   # color-folder palette ({ name, color })
# Single-quote the family name so it sits cleanly inside double-quoted SVG attrs.
MONO = "'#{BRAND['fonts']['mono']}', ui-monospace, monospace"

# ---- Mark: a golden arrow piercing a magenta-pink open file folder -----------
# Embedded straight from the cleaned seed at assets/brand/parent-elements/
# folder-arrow-seed.svg (magenta-pink open file folder + CU-gold arrow). Edit
# that seed to change the artwork — its colors and framing live there.
PARENTS    = File.join(ROOT, "assets", "brand", "parent-elements")
SEED       = File.read(File.join(PARENTS, "folder-arrow-seed.svg"))
SEED_VB    = SEED[/viewBox="([^"]+)"/, 1].split.map(&:to_f)           # [x, y, w, h] (square)
SEED_INNER = SEED.sub(/\A.*?<svg[^>]*>/m, "").sub(%r{</svg>\s*\z}m, "")

# Compact number formatting for SVG coordinates (trim trailing zeros).
def nf(x)
  format("%.2f", x).sub(/\.?0+$/, "")
end

# The mark's transform when its (square) frame is centered on (cx,cy), `size` across.
def mark_transform(cx, cy, size)
  vbx, vby, vbw, vbh = SEED_VB
  s = size.to_f / [vbw, vbh].max
  "translate(#{nf(cx - size / 2.0 - vbx * s)},#{nf(cy - size / 2.0 - vby * s)}) scale(#{nf s})"
end

# The mark centered on (cx,cy), scaled so its (square) frame is `size` across.
def folder_arrow(cx, cy, size)
  %(<g transform="#{mark_transform(cx, cy, size)}">#{SEED_INNER}</g>)
end

# Repeatable mark: define the seed once (`mark_defs`), then stamp instances with
# `mark_stamp` — a canvas full of marks would otherwise repeat the seed's
# gradient ids (and its markup) once per copy.
MARK_ID = "mark"
def mark_defs
  %(<defs><g id="#{MARK_ID}">#{SEED_INNER}</g></defs>\n)
end

def mark_stamp(cx, cy, size)
  %(<use href="##{MARK_ID}" transform="#{mark_transform(cx, cy, size)}"/>)
end

# The seed frames the artwork loosely, and the art's extremities (the arrow's
# point and fletching) still reach past the frame's inscribed circle — so a
# square lockup cropped to a circle clips the mark. This is the artwork's
# minimal enclosing circle, as a fraction of the seed's square frame, measured
# off the rendered seed (opaque-pixel scan, strokes included). Re-measure if the
# seed art changes.
ART_CX, ART_CY, ART_R = 0.4721, 0.4713, 0.5138

# The mark sized and placed so its enclosing circle is exactly the circle
# (cx,cy,r) — i.e. the WHOLE folder-arrow sits inside that circle, whatever
# crop is applied outside it.
def folder_arrow_in_circle(cx, cy, r)
  size = r / ART_R
  folder_arrow(cx - (ART_CX - 0.5) * size, cy - (ART_CY - 0.5) * size, size)
end

# ---- color helpers (derive per-folder shades) --------------------------------
def hx_rgb(h); h = h.delete("#"); [h[0, 2], h[2, 2], h[4, 2]].map { |x| x.to_i(16) }; end
def rgb_hx(r, g, b); format("#%02x%02x%02x", r.round.clamp(0, 255), g.round.clamp(0, 255), b.round.clamp(0, 255)); end
def mix(hex, t, f); r, g, b = hx_rgb(hex); rgb_hx(r + (t[0] - r) * f, g + (t[1] - g) * f, b + (t[2] - b) * f); end
def lighten(hex, f); mix(hex, [255, 255, 255], f); end
def darken(hex, f);  mix(hex, [0, 0, 0], f); end

# The open-file-folder silhouette (32×32), as three paths (back tab, mid body,
# front pocket) — the same shape as the mark's folder, reused for the palette.
FOLDER_BACK  = "M2.81964 7.79683C2.81964 6.80271 3.62553 5.99683 4.61964 5.99683H12.4297C12.9467 5.99683 13.4435 6.197 13.8161 6.55536L16.6732 9.30336C17.0924 9.70651 17.6514 9.9317 18.233 9.9317H25.9713C26.9654 9.9317 27.7713 10.7376 27.7713 11.7317V19.9078L24.2068 29.8838H6.81964C4.6105 29.8838 2.81964 28.0929 2.81964 25.8838V7.79683Z"
FOLDER_MID   = "M8.00856 15.5628C8.52664 14.1561 9.88739 13.2188 11.4116 13.2188H25.6241C26.7862 13.2188 26.5159 14.3229 26.1655 15.4102L24.4835 27.102C24.2456 27.8403 23.5476 28.3422 22.7584 28.3422L6.6694 28.3422L6.6593 28.3422C5.93643 28.3402 5.26343 28.1303 4.69914 27.7701L4.69511 27.7676C4.50932 27.5576 3.98357 26.5591 4.25478 25.8653L8.00856 15.5628Z"
FOLDER_FRONT = "M8.29999 15.4886C8.87268 13.904 10.3769 12.8481 12.0618 12.8481L28.8637 12.8482C30.1483 12.8482 31.0626 14.0963 30.6753 15.321L26.5118 28.4868C26.2488 29.3185 25.4772 29.8838 24.6049 29.8838L6.81964 29.8838L6.80847 29.8838C6.0094 29.8816 5.26544 29.6451 4.64166 29.2394L4.63721 29.2366C4.26239 28.9921 3.93115 28.6865 3.65753 28.3339C3.53326 28.1737 3.4209 28.0038 3.32172 27.8255C3.69391 27.798 3.8877 27.6138 3.98157 27.4372L8.29999 15.4886Z"
FOLDER_CX, FOLDER_CY = 15.3, 17.9   # ~center of the 32×32 folder art

# A `color` file folder centered at (cx,cy), `size` tall, optionally rotated —
# flat two-tone shades (light tab / deep pocket) + a dark fold outline, so it
# reads distinctly as a folder even small; repeatable freely in the decorative art.
def folder_glyph(cx, cy, size, color, rot = 0)
  sc = size.to_f / 24.0
  st = %( stroke="#{darken(color, 0.48)}" stroke-width="1.5" stroke-linejoin="round" paint-order="stroke")
  paths = %(<path fill="#{lighten(color, 0.34)}"#{st} d="#{FOLDER_BACK}"/>) +
          %(<path fill="#{darken(color, 0.10)}" d="#{FOLDER_MID}"/>) +
          %(<path fill="#{darken(color, 0.16)}"#{st} d="#{FOLDER_FRONT}"/>)
  %(<g transform="translate(#{nf cx},#{nf cy}) rotate(#{rot}) scale(#{nf sc}) translate(#{-FOLDER_CX},#{-FOLDER_CY})">#{paths}</g>)
end

# XML-escape text destined for SVG content/attributes (the brand prompt may
# contain `<`, `>` or `&`, which would otherwise be invalid XML).
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

# A row of color folders, centered on cx — one per palette hue.
def palette_row(cx, y, gap, size)
  cols = PALETTE.map { |p| p["color"] }
  total = (cols.length - 1) * gap
  startx = cx - total / 2.0
  cols.each_with_index.map { |col, i| folder_glyph(startx + i * gap, y, size, col, (i.even? ? -4 : 4)) }.join("\n")
end

def favicon
  doc(64, 64, %(<rect width="64" height="64" rx="13" fill="#{C['bg']}"/>\n) + folder_arrow(32, 32, 60))
end

# Standalone transparent mark for inline use in the site chrome (nav / footer).
def pixmark
  doc(96, 96, folder_arrow(48, 48, 96))
end

def avatar
  body = +""
  body << %(<rect width="512" height="512" rx="96" fill="#{C['bg']}"/>\n)
  body << %(<rect x="14" y="14" width="484" height="484" rx="84" fill="none" stroke="#{C['panel']}" stroke-width="2"/>\n)
  # Arrow-pierced file folder up top, then the wordmark below with breathing room.
  body << folder_arrow(256, 206, 348)
  body << "\n" << wordmark(256, 470, 66, anchor: "middle")
  doc(512, 512, body)
end

# Circular profile avatar: the mark alone — no wordmark — on a dark disc, sized
# so the whole folder-arrow (point and fletching included) clears the circular
# crop avatars get on GitHub, Slack, X, &c. `MARK_FILL` is the share of the
# disc's radius the artwork occupies; the rest is the padding that keeps it whole.
MARK_FILL = 0.78
def avatar_circle(w, h)
  cx = w / 2.0
  cy = h / 2.0
  r = [w, h].min / 2.0
  ring = r * 0.012   # hairline gold rim, so the near-black disc reads on dark UI
  body = +""
  body << %(<circle cx="#{nf cx}" cy="#{nf cy}" r="#{nf r}" fill="#{C['bg']}"/>\n)
  body << %(<circle cx="#{nf cx}" cy="#{nf cy}" r="#{nf(r - ring)}" fill="none" stroke="#{C['gold']}" stroke-opacity="0.34" stroke-width="#{nf ring}"/>\n)
  body << folder_arrow_in_circle(cx, cy, r * MARK_FILL)
  doc(w, h, body)
end

# ---- Particle-link network (a still frame of the hero canvas) ----------------
# A deterministic replay of the drifting folder network in assets/js/cupids.js:
# the same folder art, drift, link rule, prevent-overlap separation and SI spread
# (CUPID's gold "opens" a folder, then travels the links to its neighbors), run
# with a seeded RNG and snapshotted mid-spread — so the banner is an actual
# frame of the hero animation rather than a look-alike of it. Constants mirror
# cupids.js and the home hero's data-attributes in _includes/components/hero.html.
# Where the still departs from the hero, it does so because nothing is layered
# over it: the hero dims the network so headlines stay legible on top of it and
# lets folders run off the edges, while the banner is the whole picture.
NET_SEED       = 101         # RNG seed — change it to draw a different network
NET_COUNT      = 52          # folders on the canvas (hero: 32, on a taller box)
NET_LINK       = 165         # link distance in px at full size (hero: data-link)
NET_DOT_OP     = 0.95        # folder opacity (hero dims to data-dotop, 0.55)
NET_LINE_OP    = 0.55        # link opacity   (hero dims to data-lineop, 0.34)
NET_EDGE_W     = 3           # link width at full size (cupids.js BASE_EDGE)
NET_SIZE_REF   = 1100        # width at which folders + links render full size
NET_ART_SCALE  = 1.25        # folders run a little larger than on the hero
NET_RADIUS     = 0.42        # folder radius as a fraction of node size
NET_PAD        = 2           # extra px of breathing room between folders
NET_MARGIN     = 0.62        # keep folders this far (× size) inside the frame
NET_TRANSMIT   = 0.45        # chance a spread tick propagates
NET_TICK       = 30          # frames between spread ticks (500ms at 60fps)
NET_INFECTED   = 0.42        # snapshot the spread once this share is opened
NET_MAX_FRAMES = 7200        # safety stop (~2 min of animation)

# One animation frame: drift, bounce off the frame, then separate any folders
# that overlap (ForceAtlas2's anti-collision, projected to positions). Folders
# bounce off an inset margin rather than the canvas edge, so none is cropped.
def network_step(pts, w, h)
  pts.each do |p|
    m = p[:size] * NET_MARGIN
    p[:x] += p[:vx]
    p[:y] += p[:vy]
    p[:vx] = -p[:vx] if p[:x] < m || p[:x] > w - m
    p[:vy] = -p[:vy] if p[:y] < m || p[:y] > h - m
  end
  pts.each_with_index do |pa, a|
    pts[(a + 1)..].each do |pb|
      dx = pb[:x] - pa[:x]
      dy = pb[:y] - pa[:y]
      d = Math.sqrt(dx * dx + dy * dy)
      min_d = (pa[:size] + pb[:size]) * NET_RADIUS + NET_PAD
      next unless d.positive? && d < min_d

      push = (min_d - d) / 2.0
      ux = dx / d
      uy = dy / d
      pa[:x] -= ux * push
      pa[:y] -= uy * push
      pb[:x] += ux * push
      pb[:y] += uy * push
    end
  end
  pts.each do |p|
    m = p[:size] * NET_MARGIN
    p[:x] = p[:x].clamp(m, w - m)
    p[:y] = p[:y].clamp(m, h - m)
  end
end

# One SI step: at most ONE new infection per tick, drawn from the susceptible
# folders that are linked to an already-opened one.
def network_tick(pts, link_dist, rng)
  return if rng.rand >= NET_TRANSMIT

  d2 = link_dist * link_dist
  candidates = pts.reject { |p| p[:infected] }.select do |p|
    pts.any? { |q| q[:infected] && (q[:x] - p[:x])**2 + (q[:y] - p[:y])**2 < d2 }
  end
  return if candidates.empty?

  hit = candidates[rng.rand(candidates.length)]
  hit[:infected] = true
  hit[:color] = C["gold"]
end

def network(w, h)
  rng = Random.new(NET_SEED)
  scale = (w / NET_SIZE_REF.to_f).clamp(0.6, 1.0)
  link_dist = NET_LINK * scale
  edge_w = NET_EDGE_W * scale
  pts = Array.new(NET_COUNT) do
    size = (14 + rng.rand * 30) * scale * NET_ART_SCALE
    m = size * NET_MARGIN
    { x: m + rng.rand * (w - 2 * m), y: m + rng.rand * (h - 2 * m),
      vx: (rng.rand - 0.5) * 0.22, vy: (rng.rand - 0.5) * 0.22,
      color: PALETTE[rng.rand(PALETTE.length)]["color"], infected: false,
      size: size }
  end
  # Patient zero, then run the animation until the spread hits the snapshot mark.
  [1, (pts.length * 0.05).round].max.times do
    p = pts[rng.rand(pts.length)]
    p[:infected] = true
    p[:color] = C["gold"]
  end
  target = (pts.length * NET_INFECTED).round
  NET_MAX_FRAMES.times do |frame|
    network_step(pts, w, h)
    next unless ((frame + 1) % NET_TICK).zero?
    break if pts.count { |p| p[:infected] } >= target

    network_tick(pts, link_dist, rng)
  end

  # Links first, each a gradient between its two endpoint folders, fading out
  # with distance; then the folders — opened ones render the mark itself.
  defs = +""
  edges = +""
  pts.each_with_index do |pa, a|
    pts[(a + 1)..].each_with_index do |pb, i|
      d = Math.hypot(pa[:x] - pb[:x], pa[:y] - pb[:y])
      next unless d < link_dist

      id = "e#{a}-#{i}"
      defs << %(<linearGradient id="#{id}" gradientUnits="userSpaceOnUse" x1="#{nf pa[:x]}" y1="#{nf pa[:y]}" x2="#{nf pb[:x]}" y2="#{nf pb[:y]}">) <<
              %(<stop stop-color="#{pa[:color]}"/><stop offset="1" stop-color="#{pb[:color]}"/></linearGradient>\n)
      edges << %(<line x1="#{nf pa[:x]}" y1="#{nf pa[:y]}" x2="#{nf pb[:x]}" y2="#{nf pb[:y]}" ) <<
               %(stroke="url(##{id})" stroke-opacity="#{nf(NET_LINE_OP * (1 - 0.7 * d / link_dist))}" stroke-width="#{nf edge_w}"/>\n)
    end
  end
  nodes = pts.map do |p|
    p[:infected] ? mark_stamp(p[:x], p[:y], p[:size] * 1.6) : folder_glyph(p[:x], p[:y], p[:size], p[:color])
  end

  body = +%(<rect width="#{w}" height="#{h}" fill="#{C['bg']}"/>\n)
  body << mark_defs << %(<defs>\n#{defs}</defs>\n)
  body << edges
  body << %(<g opacity="#{NET_DOT_OP}">\n#{nodes.join("\n")}\n</g>)
  doc(w, h, body)
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
  spots = [[60, 60, 0, -12], [180, 110, 3, 8], [110, 190, 6, -6], [210, 220, 1, 14], [30, 200, 4, -16]]
  body << %(<g opacity="0.62">\n)
  spots.each { |x, y, i, rot| body << folder_glyph(x, y, 46, PALETTE[i % PALETTE.length]["color"], rot) << "\n" }
  body << %(</g>)
  doc(240, 240, body)
end

# A full "folder map" background: a deterministic jittered grid of palette
# folders (with CU-gold folders woven in) on the dark canvas.
def background(w, h)
  rng = Random.new(7)
  step = 120
  body = +%(<rect width="#{w}" height="#{h}" fill="#{C['bg']}"/>\n)
  body << %(<g opacity="0.5">\n)
  (0..(h / step)).each do |row|
    (0..(w / step)).each do |col|
      cx = col * step + step / 2 + rng.rand(-24..24)
      cy = row * step + step / 2 + rng.rand(-24..24)
      color = rng.rand < 0.24 ? C["gold"] : PALETTE[rng.rand(PALETTE.length)]["color"]
      body << folder_glyph(cx, cy, 34 + rng.rand(34), color, rng.rand(-22..22)) << "\n"
    end
  end
  body << %(</g>)
  doc(w, h, body)
end

# A single 32×32 file folder for the per-color folders/ collection — bold-combo:
# a light tab (back gradient), a deep pocket (front gradient), and a dark fold
# outline, so it reads distinctly as a folder even at small sizes.
def folder_svg(base)
  back_hi = lighten(base, 0.40)
  back_lo = lighten(base, 0.24)
  front_lo = darken(base, 0.22)
  st = %( stroke="#{darken(base, 0.48)}" stroke-width="1.5" stroke-linejoin="round" paint-order="stroke")
  body = +%(<defs>)
  body << %(<linearGradient id="fb" x1="7.08807" y1="6.68747" x2="9.90057" y2="16.8125" gradientUnits="userSpaceOnUse"><stop stop-color="#{back_hi}"/><stop offset="1" stop-color="#{back_lo}"/></linearGradient>)
  body << %(<linearGradient id="ff" x1="17.0434" y1="12.8481" x2="17.0434" y2="29.8838" gradientUnits="userSpaceOnUse"><stop stop-color="#{base}"/><stop offset="1" stop-color="#{front_lo}"/></linearGradient>)
  body << %(</defs>)
  body << %(<path fill="url(#fb)"#{st} d="#{FOLDER_BACK}"/>)
  body << %(<path fill="#{darken(base, 0.10)}" d="#{FOLDER_MID}"/>)
  body << %(<path fill="url(#ff)"#{st} d="#{FOLDER_FRONT}"/>)
  doc(32, 32, body)
end

generated = []
BRAND["assets"].each do |a|
  svg =
    case a["kind"]
    when "mark"    then favicon
    when "pixmark" then pixmark
    when "avatar"  then avatar
    when "avatar_circle" then avatar_circle(a["w"], a["h"])
    when "og"         then social(a["w"], a["h"])
    when "network"    then network(a["w"], a["h"])
    when "pattern"    then pattern
    when "background" then background(a["w"], a["h"])
    end
  next unless svg
  File.write(File.join(OUT, a["file"]), svg)
  generated << a["file"]
end

puts "Generated #{generated.length} brand assets in assets/brand/:"
generated.each { |f| puts "  - #{f}" }

# Color-folder collection: one recolored file folder per palette hue.
v = BRAND["variants"]
if v
  vdir = File.join(OUT, v["dir"])
  FileUtils.mkdir_p(vdir)
  files = []
  PALETTE.each do |p|
    fname = "#{p['name']}.svg"
    File.write(File.join(vdir, fname), folder_svg(p["color"]))
    files << fname
  end
  puts "Generated #{files.length} folder icons in assets/brand/#{v['dir']}/."
end
