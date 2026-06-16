/* ============================================================
   cupids-lab <3  — all behavior is local, no external libraries.
     · heart-emoji particle network with a half-second SI spread
     · heart-burst easter egg
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
      '%c♥ cupids-lab — made with love for public data. github.com/CUPIDS-Lab',
      'color:#cfb87c;font-size:13px;'
    );
  } catch (e) {}

  /* ---------- heart burst ---------- */
  function burst(e) {
    if (reduceMotion) return;
    try {
      if (e && e.stopPropagation) e.stopPropagation();
      var x = (e && e.clientX) || (window.innerWidth / 2);
      var y = (e && e.clientY) || 80;
      var colors = ['#cfb87c', '#b23a2e', '#6fcf97'];
      for (var i = 0; i < 7; i++) {
        var s = document.createElement('span');
        s.textContent = '♥';
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

  // Real color-emoji hearts, rendered with the platform's color-emoji font (so
  // on Apple devices these ARE the Apple glyphs). The hero runs an SI
  // (susceptible -> infected) spread: every node starts as a colored heart and
  // the Cupid 💘 spreads along the links to its neighbors. Each glyph maps to a
  // color the edges interpolate between.
  var SUSCEPTIBLE = [
    { g: '❤️', c: '#ed4e5b' }, { g: '🧡', c: '#f0883e' }, { g: '💛', c: '#f7c948' },
    { g: '💚', c: '#6fcf97' }, { g: '💙', c: '#4a9fe6' }, { g: '💜', c: '#9b6dd6' },
    { g: '🤎', c: '#9c6b4a' }, { g: '🤍', c: '#e8e6e0' }
  ];
  var INFECTED   = { g: '💘', c: '#f06fa0' }; // the Cupid heart that spreads
  var EMOJI_FONT = '"Apple Color Emoji","Segoe UI Emoji","Noto Color Emoji",sans-serif';
  var SPREAD_MS  = 500;   // half-second infection tick
  var TRANSMIT   = 0.45;  // chance an infected node infects a given neighbor per tick
  var RESET_FRAC = 0.88;  // once this fraction is infected, reset & re-seed so it loops
  // Viewport scaling: keep heart density (and the look) consistent desktop↔mobile.
  var AREA_PER_NODE = 12000; // px² of hero per heart (data-count is the upper cap)
  var SIZE_REF = 1100;       // hero width at which hearts render full-size

  function initCanvas(c) {
    var maxCount = +(c.dataset.count || 40);  // desktop cap
    var baseLink = +(c.dataset.link || 130);
    var dotOp = +(c.dataset.dotop || 0.45);
    var lineOp = +(c.dataset.lineop || 0.14);
    var pts = null;          // seeded lazily, once we have real dimensions
    var raf = null;
    var timer = null;        // SI spread interval
    var linkDist = baseLink; // recomputed per seed for the current viewport

    // Node count scales with hero AREA (constant density) and heart size +
    // link distance scale with hero WIDTH — so a phone isn't a crowded,
    // fast-spreading clump and desktop isn't sparse.
    function seed(W, H) {
      var scale = Math.max(0.6, Math.min(1, W / SIZE_REF));
      var n = Math.max(6, Math.min(maxCount, Math.round((W * H) / AREA_PER_NODE)));
      linkDist = baseLink * scale;
      pts = [];
      for (var i = 0; i < n; i++) {
        var s = SUSCEPTIBLE[(Math.random() * SUSCEPTIBLE.length) | 0];
        pts.push({
          x: Math.random() * W, y: Math.random() * H,
          vx: (Math.random() - 0.5) * 0.22, vy: (Math.random() - 0.5) * 0.22,
          glyph: s.g, color: s.c, infected: false,
          size: (14 + Math.random() * 30) * scale
        });
      }
      seedInfections();
    }

    function infect(p) { p.infected = true; p.glyph = INFECTED.g; p.color = INFECTED.c; }

    // Patient zero (a few seeds, scaled to the network size).
    function seedInfections() {
      if (!pts || !pts.length) return;
      var n = Math.max(1, Math.round(pts.length * 0.05));
      for (var i = 0; i < n; i++) infect(pts[(Math.random() * pts.length) | 0]);
    }

    // One SI step: infected nodes spread 💘 to connected (in-range) neighbors.
    // Decisions use the state at tick start; saturation triggers a reset.
    function spreadTick() {
      if (!c.isConnected) { if (timer) { clearInterval(timer); timer = null; } return; }
      if (!pts || !pts.length) return;
      var inf = 0, k;
      for (k = 0; k < pts.length; k++) if (pts[k].infected) inf++;
      if (inf === 0) { seedInfections(); return; }
      // Saturated: refresh the ENTIRE network — new positions, new hearts, new
      // patient zero — so the spread restarts on a fresh graph.
      if (inf >= pts.length * RESET_FRAC) { seed(c._w, c._h); return; }
      var d2 = linkDist * linkDist, toInfect = [];
      for (var a = 0; a < pts.length; a++) {
        if (!pts[a].infected) continue;
        for (var b = 0; b < pts.length; b++) {
          if (b === a || pts[b].infected) continue;
          var dx = pts[a].x - pts[b].x, dy = pts[a].y - pts[b].y;
          if (dx * dx + dy * dy < d2 && Math.random() < TRANSMIT) toInfect.push(pts[b]);
        }
      }
      for (k = 0; k < toInfect.length; k++) infect(toInfect[k]);
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
      for (var a = 0; a < pts.length; a++) {
        for (var b = a + 1; b < pts.length; b++) {
          var dx = pts[a].x - pts[b].x, dy = pts[a].y - pts[b].y;
          var d = Math.hypot(dx, dy);
          if (d < linkDist) {
            // Edge color interpolates between its two endpoint hearts.
            var grad = ctx.createLinearGradient(pts[a].x, pts[a].y, pts[b].x, pts[b].y);
            grad.addColorStop(0, pts[a].color);
            grad.addColorStop(1, pts[b].color);
            ctx.globalAlpha = lineOp * (1 - 0.7 * d / linkDist);
            ctx.strokeStyle = grad;
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.moveTo(pts[a].x, pts[a].y);
            ctx.lineTo(pts[b].x, pts[b].y);
            ctx.stroke();
          }
        }
      }
      ctx.globalAlpha = dotOp;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      for (var m = 0; m < pts.length; m++) {
        ctx.font = pts[m].size + 'px ' + EMOJI_FONT;
        ctx.fillText(pts[m].glyph, pts[m].x, pts[m].y);
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

  function wireForm(form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var success = form.parentNode.querySelector('.js-form-success');
      var endpoint = form.getAttribute('data-endpoint');

      function reveal() {
        if (success) {
          form.style.display = 'none';
          success.hidden = false;
        }
      }

      if (endpoint) {
        var btn = form.querySelector('button[type="submit"]');
        if (btn) { btn.disabled = true; btn.textContent = 'Sending…'; }
        fetch(endpoint, {
          method: 'POST',
          body: new FormData(form),
          headers: { 'Accept': 'application/json' }
        }).then(function () { reveal(); })
          .catch(function () { reveal(); });
      } else {
        reveal();
      }
    });
  }

  /* ---------- boot ---------- */
  function boot() {
    // hearts
    Array.prototype.forEach.call(document.querySelectorAll('.heart'), function (el) {
      el.addEventListener('click', burst);
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
