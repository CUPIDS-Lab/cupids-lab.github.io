/* ============================================================
   cupids-lab  — all behavior is local, no external libraries.
     · color-folder particle network with a half-second SI spread
     · folder-burst easter egg
     · matchmaker console note
     · mobile nav toggle
     · client-side form confirmation (optional Formspree POST)
   ============================================================ */
(function () {
  'use strict';

  var reduceMotion = window.matchMedia &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- matchmaker console note ---------- */
  try {
    console.log(
      '%c📂 cupids-lab — matchmaking data & democracy. github.com/CUPIDS-Lab',
      'color:#cfb87c;font-size:13px;'
    );
  } catch (e) {}

  /* ---------- folder burst ---------- */
  function burst(e) {
    if (reduceMotion) return;
    try {
      if (e && e.stopPropagation) e.stopPropagation();
      var x = (e && e.clientX) || (window.innerWidth / 2);
      var y = (e && e.clientY) || 80;
      var colors = ['#cfb87c', '#d63384', '#6fcf97'];
      for (var i = 0; i < 7; i++) {
        var s = document.createElement('span');
        s.textContent = '📂';
        s.style.cssText =
          'position:fixed;left:' + (x + (Math.random() * 44 - 22)) +
          'px;top:' + y + 'px;z-index:9999;pointer-events:none;font-size:' +
          (12 + Math.random() * 16) + 'px;color:' + colors[i % 3] +
          ';animation:cupid-rise ' + (700 + Math.random() * 600) +
          'ms ease-out forwards;';
        document.body.appendChild(s);
        (function (node) { setTimeout(function () { node.remove(); }, 1400); })(s);
      }
    } catch (err) {}
  }

  /* ---------- particle-links background ----------
     Robust against first-load reflow on mobile: the hero grows after the
     web fonts load (font-display: swap), and the mobile toolbar / rotation
     can resize it too. We seed particles only once the canvas has a real
     measured size, and on any later box change we re-size the backing store
     AND rescale existing particle positions so the network never stretches,
     bunches, or pops. */
  function measure(c) {
    var r = c.getBoundingClientRect();
    if (!r.width || !r.height) return null;
    var dpr = Math.min(window.devicePixelRatio || 1, 2);
    var pw = Math.round(r.width * dpr), ph = Math.round(r.height * dpr);
    if (c.width !== pw || c.height !== ph) {
      c.width = pw; c.height = ph;
    }
    var ctx = c.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    c._w = r.width; c._h = r.height;
    return c;
  }

  // The hero is a drifting network of color file folders. It runs an SI
  // (susceptible -> infected) spread: every node starts as a palette-colored
  // folder and CUPID's gold "opens" them — the gold spreads along the links to
  // its neighbors. Node + edge colors interpolate between these hues.
  // Full open file folder (after parent-elements/open-file-folder.svg): a back
  // tab/panel, a soft mid shadow, and the front pocket — three paths, so it
  // reads as a complete *open* folder rather than a bare silhouette.
  var FOLDER_BACK  = new Path2D('M2.81964 7.79683C2.81964 6.80271 3.62553 5.99683 4.61964 5.99683H12.4297C12.9467 5.99683 13.4435 6.197 13.8161 6.55536L16.6732 9.30336C17.0924 9.70651 17.6514 9.9317 18.233 9.9317H25.9713C26.9654 9.9317 27.7713 10.7376 27.7713 11.7317V19.9078L24.2068 29.8838H6.81964C4.6105 29.8838 2.81964 28.0929 2.81964 25.8838V7.79683Z');
  var FOLDER_MID   = new Path2D('M8.00856 15.5628C8.52664 14.1561 9.88739 13.2188 11.4116 13.2188H25.6241C26.7862 13.2188 26.5159 14.3229 26.1655 15.4102L24.4835 27.102C24.2456 27.8403 23.5476 28.3422 22.7584 28.3422L6.6694 28.3422L6.6593 28.3422C5.93643 28.3402 5.26343 28.1303 4.69914 27.7701L4.69511 27.7676C4.50932 27.5576 3.98357 26.5591 4.25478 25.8653L8.00856 15.5628Z');
  var FOLDER_FRONT = new Path2D('M8.29999 15.4886C8.87268 13.904 10.3769 12.8481 12.0618 12.8481L28.8637 12.8482C30.1483 12.8482 31.0626 14.0963 30.6753 15.321L26.5118 28.4868C26.2488 29.3185 25.4772 29.8838 24.6049 29.8838L6.81964 29.8838L6.80847 29.8838C6.0094 29.8816 5.26544 29.6451 4.64166 29.2394L4.63721 29.2366C4.26239 28.9921 3.93115 28.6865 3.65753 28.3339C3.53326 28.1737 3.4209 28.0038 3.32172 27.8255C3.69391 27.798 3.8877 27.6138 3.98157 27.4372L8.29999 15.4886Z');
  // Shade a #rrggbb hex toward white (f>0) or black (f<0) for the folder's tones.
  function shade(hex, f) {
    var n = parseInt(hex.slice(1), 16), r = n >> 16, g = (n >> 8) & 255, b = n & 255;
    var t = f < 0 ? 0 : 255, a = Math.abs(f);
    return 'rgb(' + Math.round(r + (t - r) * a) + ',' + Math.round(g + (t - g) * a) + ',' + Math.round(b + (t - b) * a) + ')';
  }
  var SUSCEPTIBLE = ['#ed4e5b', '#f0883e', '#f7c948', '#6fcf97', '#4a9fe6', '#9b6dd6', '#9c6b4a', '#e8e6e0', '#f06fa0'];
  var INFECTED   = '#cfb87c'; // edge color for infected nodes (the arrow's gold)
  // Infected nodes render the site's core mark — a magenta-pink folder pierced
  // by the gold arrow — drawn straight from the same-origin mark.svg.
  var MARK_IMG = new Image();
  MARK_IMG.src = '/assets/brand/mark.svg';
  var SPREAD_MS  = 500;   // half-second infection tick
  var TRANSMIT   = 0.45;  // chance the single per-tick propagation fires
  var RESET_FRAC = 0.88;  // once this fraction is infected, reset & re-seed so it loops
  // Fixed node count: the same number of folders on every viewport. Only their
  // size and edge width scale with the hero width, so a phone shows the same
  // network as desktop — just smaller, never sparser.
  var SIZE_REF = 1100;   // hero width at which folders + edges render full-size
  var BASE_EDGE = 3;     // link width (px) at full size, scaled to the viewport
  // Prevent-overlap, adapted from ForceAtlas2's anti-collision ("adjustSizes":
  // https://github.com/bhargavchippada/forceatlas2). Each folder has a radius
  // (~half its node size); overlapping pairs get separated every frame.
  var PREVENT_OVERLAP = true;
  var NODE_RADIUS = 0.42; // folder radius as a fraction of node size
  var OVERLAP_PAD = 2;    // extra px of breathing room between folders

  function initCanvas(c) {
    var nodeCount = +(c.dataset.count || 32);  // fixed folder count (no viewport scaling)
    var baseLink = +(c.dataset.link || 130);
    var dotOp = +(c.dataset.dotop || 0.45);
    var lineOp = +(c.dataset.lineop || 0.14);
    var pts = null;          // seeded lazily, once we have real dimensions
    var raf = null;
    var timer = null;        // SI spread interval
    var linkDist = baseLink; // recomputed per seed for the current viewport
    var edgeW = BASE_EDGE;   // link width, recomputed per seed for the viewport

    // Fixed count of folders on every viewport; only the folder size, link
    // distance and edge width scale with hero WIDTH — so a phone shows the same
    // network as desktop, just rendered smaller.
    function seed(W, H) {
      var scale = Math.max(0.6, Math.min(1, W / SIZE_REF));
      linkDist = baseLink * scale;
      edgeW = BASE_EDGE * scale;
      pts = [];
      for (var i = 0; i < nodeCount; i++) {
        pts.push({
          x: Math.random() * W, y: Math.random() * H,
          vx: (Math.random() - 0.5) * 0.22, vy: (Math.random() - 0.5) * 0.22,
          color: SUSCEPTIBLE[(Math.random() * SUSCEPTIBLE.length) | 0], infected: false,
          size: (14 + Math.random() * 30) * scale
        });
      }
      seedInfections();
    }

    function infect(p) { p.infected = true; p.color = INFECTED; }

    // Patient zero (a few seeds, scaled to the network size).
    function seedInfections() {
      if (!pts || !pts.length) return;
      var n = Math.max(1, Math.round(pts.length * 0.05));
      for (var i = 0; i < n; i++) infect(pts[(Math.random() * pts.length) | 0]);
    }

    // One SI step. Cap: at most ONE new infection per tick — collect the
    // susceptible folders adjacent to an infected one, then infect a single
    // random one. This keeps dense networks from igniting all at once, so the
    // spread rate is independent of how crowded the field is. Saturation resets.
    function spreadTick() {
      if (!c.isConnected) { if (timer) { clearInterval(timer); timer = null; } return; }
      if (!pts || !pts.length) return;
      var inf = 0, k;
      for (k = 0; k < pts.length; k++) if (pts[k].infected) inf++;
      if (inf === 0) { seedInfections(); return; }
      // Saturated: refresh the ENTIRE network — new positions, new folders, new
      // patient zero — so the spread restarts on a fresh graph.
      if (inf >= pts.length * RESET_FRAC) { seed(c._w, c._h); return; }
      if (Math.random() >= TRANSMIT) return;        // this tick doesn't propagate
      var d2 = linkDist * linkDist, candidates = [];
      for (var b = 0; b < pts.length; b++) {
        if (pts[b].infected) continue;
        for (var a = 0; a < pts.length; a++) {
          if (!pts[a].infected) continue;
          var dx = pts[a].x - pts[b].x, dy = pts[a].y - pts[b].y;
          if (dx * dx + dy * dy < d2) { candidates.push(pts[b]); break; }
        }
      }
      if (candidates.length) infect(candidates[(Math.random() * candidates.length) | 0]);
    }

    // Resize backing store; seed on first valid size, rescale on later changes.
    function sync() {
      var prevW = c._w, prevH = c._h;
      if (!measure(c)) return;
      if (!pts) {
        seed(c._w, c._h);
      } else if (prevW && prevH && (prevW !== c._w || prevH !== c._h)) {
        var sx = c._w / prevW, sy = c._h / prevH;
        for (var i = 0; i < pts.length; i++) { pts[i].x *= sx; pts[i].y *= sy; }
      }
    }

    // Prevent-overlap: ForceAtlas2's anti-collision idea (nodes have size and
    // repel when their circles intersect), projected to positions rather than
    // applied as a force — stable for this drifting, non-force-directed field.
    function resolveOverlap(w, h) {
      for (var a = 0; a < pts.length; a++) {
        var pa = pts[a];
        for (var b = a + 1; b < pts.length; b++) {
          var pb = pts[b];
          var dx = pb.x - pa.x, dy = pb.y - pa.y;
          var d = Math.sqrt(dx * dx + dy * dy);
          var minD = (pa.size + pb.size) * NODE_RADIUS + OVERLAP_PAD;
          if (d > 0 && d < minD) {
            var push = (minD - d) / 2, ux = dx / d, uy = dy / d;
            pa.x -= ux * push; pa.y -= uy * push;
            pb.x += ux * push; pb.y += uy * push;
          } else if (d === 0) {
            pa.x += Math.random() - 0.5; pa.y += Math.random() - 0.5;
          }
        }
      }
      for (var i = 0; i < pts.length; i++) {
        var p = pts[i];
        if (p.x < 0) p.x = 0; else if (p.x > w) p.x = w;
        if (p.y < 0) p.y = 0; else if (p.y > h) p.y = h;
      }
    }

    var ctx = c.getContext('2d');
    function draw() {
      if (!c.isConnected) { cancelAnimationFrame(raf); return; }
      var w = c._w, h = c._h;
      if (!w || !h || !pts) { sync(); raf = requestAnimationFrame(draw); return; }
      ctx.clearRect(0, 0, w, h);
      for (var k = 0; k < pts.length; k++) {
        var p = pts[k];
        p.x += p.vx; p.y += p.vy;
        if (p.x < 0 || p.x > w) p.vx *= -1;
        if (p.y < 0 || p.y > h) p.vy *= -1;
        if (p.x < 0) p.x = 0; else if (p.x > w) p.x = w;
        if (p.y < 0) p.y = 0; else if (p.y > h) p.y = h;
      }
      if (PREVENT_OVERLAP) resolveOverlap(w, h);
      for (var a = 0; a < pts.length; a++) {
        for (var b = a + 1; b < pts.length; b++) {
          var dx = pts[a].x - pts[b].x, dy = pts[a].y - pts[b].y;
          var d = Math.hypot(dx, dy);
          if (d < linkDist) {
            // Edge color interpolates between its two endpoint folders.
            var grad = ctx.createLinearGradient(pts[a].x, pts[a].y, pts[b].x, pts[b].y);
            grad.addColorStop(0, pts[a].color);
            grad.addColorStop(1, pts[b].color);
            ctx.globalAlpha = lineOp * (1 - 0.7 * d / linkDist);
            ctx.strokeStyle = grad;
            ctx.lineWidth = edgeW;
            ctx.beginPath();
            ctx.moveTo(pts[a].x, pts[a].y);
            ctx.lineTo(pts[b].x, pts[b].y);
            ctx.stroke();
          }
        }
      }
      ctx.globalAlpha = dotOp;
      for (var m = 0; m < pts.length; m++) {
        var pm = pts[m];
        if (pm.infected) {
          // The core mark (pink folder + gold arrow), centered on the node.
          if (MARK_IMG.complete && MARK_IMG.naturalWidth) {
            var ms = pm.size * 1.6;           // the mark.svg has padding; size up to match
            ctx.drawImage(MARK_IMG, pm.x - ms / 2, pm.y - ms / 2, ms, ms);
          }
        } else {
          // Susceptible: a complete open folder — two-tone (light tab / deep
          // pocket) + a dark fold outline, so it reads as a folder even small.
          var sc = pm.size / 26;
          ctx.save();
          ctx.translate(pm.x, pm.y);
          ctx.scale(sc, sc);
          ctx.translate(-15.3, -17.9);        // center the 32×32 folder art
          ctx.lineJoin = 'round';
          ctx.lineWidth = 1.5;
          ctx.strokeStyle = shade(pm.color, -0.48);
          ctx.fillStyle = shade(pm.color, 0.34);  ctx.fill(FOLDER_BACK);  ctx.stroke(FOLDER_BACK);
          ctx.fillStyle = shade(pm.color, -0.10); ctx.fill(FOLDER_MID);
          ctx.fillStyle = shade(pm.color, -0.18); ctx.fill(FOLDER_FRONT); ctx.stroke(FOLDER_FRONT);
          ctx.restore();
        }
      }
      ctx.globalAlpha = 1;
      raf = requestAnimationFrame(draw);
    }

    sync();

    // Re-sync whenever the hero box actually changes (font load, rotation,
    // mobile toolbar show/hide) — events alone don't cover these.
    if (typeof ResizeObserver !== 'undefined') {
      var ro = new ResizeObserver(function () { sync(); });
      ro.observe(c);
    }
    // Belt-and-suspenders: resync once webfonts land (they grow the hero).
    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(function () { sync(); }).catch(function () {});
    }

    draw();
    timer = setInterval(spreadTick, SPREAD_MS);
    return { el: c, sync: sync };
  }

  // AJAX form submit to Formspree (or any endpoint set via data-endpoint).
  // Shows the on-brand success state on a 2xx, surfaces validation errors
  // otherwise, and re-enables the button. With no endpoint it just confirms
  // (the design's client-side fallback).
  function wireForm(form) {
    var card = form.parentNode;
    var success = card.querySelector('.js-form-success');
    var btn = form.querySelector('button[type="submit"]');
    var label = btn ? btn.innerHTML : '';
    var endpoint = form.getAttribute('data-endpoint');

    function reveal() { if (success) { form.style.display = 'none'; success.hidden = false; } }
    function resetBtn() { if (btn) { btn.disabled = false; btn.innerHTML = label; } }
    function showError(msg) {
      var el = card.querySelector('.js-form-error');
      if (!el) {
        el = document.createElement('div');
        el.className = 'js-form-error form-error';
        el.setAttribute('role', 'alert');
        form.parentNode.insertBefore(el, form.nextSibling);
      }
      el.textContent = msg || "Sorry — that didn't send. Please try again, or reach us directly.";
      el.hidden = false;
    }

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      if (!endpoint) { reveal(); return; }
      var prev = card.querySelector('.js-form-error'); if (prev) prev.hidden = true;
      if (btn) { btn.disabled = true; btn.textContent = 'Sending…'; }
      fetch(endpoint, {
        method: 'POST',
        body: new FormData(form),
        headers: { 'Accept': 'application/json' }
      }).then(function (res) {
        if (res.ok) { reveal(); return; }
        return res.json().then(function (data) {
          var msg = data && data.errors && data.errors.length
            ? data.errors.map(function (er) { return er.message; }).join(' ')
            : null;
          showError(msg); resetBtn();
        }).catch(function () { showError(); resetBtn(); });
      }).catch(function () { showError(); resetBtn(); });
    });
  }

  /* ---------- boot ---------- */
  function boot() {
    // folder-burst triggers
    Array.prototype.forEach.call(document.querySelectorAll('.spark'), function (el) {
      el.addEventListener('click', burst);
      el.addEventListener('keydown', function (ev) {
        if (ev.key === 'Enter' || ev.key === ' ') { ev.preventDefault(); burst(ev); }
      });
    });

    // particles
    var canvases = [];
    if (!reduceMotion) {
      Array.prototype.forEach.call(
        document.querySelectorAll('canvas.cupids-particles'),
        function (c) { canvases.push(initCanvas(c)); }
      );
      window.addEventListener('resize', function () {
        canvases.forEach(function (o) { if (o.el.isConnected) o.sync(); });
      }, { passive: true });
      // Mobile orientation change reflows the hero after a tick.
      window.addEventListener('orientationchange', function () {
        setTimeout(function () {
          canvases.forEach(function (o) { if (o.el.isConnected) o.sync(); });
        }, 200);
      });
    }

    // mobile nav
    var nav = document.querySelector('.nav');
    var toggle = document.querySelector('.nav__toggle');
    if (nav && toggle) {
      toggle.addEventListener('click', function () {
        var open = nav.classList.toggle('is-open');
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      });
    }

    // forms
    Array.prototype.forEach.call(document.querySelectorAll('.js-form'), wireForm);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
