/* ============================================================
   cupids-lab <3  — all behavior is local, no external libraries.
     · particle-links background (subtle, CU gold)
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

  /* ---------- particle-links background ---------- */
  function sizeCanvas(c) {
    var r = c.getBoundingClientRect();
    if (!r.width || !r.height) return;
    var dpr = Math.min(window.devicePixelRatio || 1, 2);
    c.width = r.width * dpr;
    c.height = r.height * dpr;
    var ctx = c.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    c._w = r.width; c._h = r.height;
  }

  function initCanvas(c) {
    sizeCanvas(c);
    var color = c.dataset.color || '#cfb87c';
    var count = +(c.dataset.count || 40);
    var linkDist = +(c.dataset.link || 130);
    var dotOp = +(c.dataset.dotop || 0.45);
    var lineOp = +(c.dataset.lineop || 0.14);
    var W = c._w || 900, H = c._h || 400;
    var pts = [];
    for (var i = 0; i < count; i++) {
      pts.push({
        x: Math.random() * W, y: Math.random() * H,
        vx: (Math.random() - 0.5) * 0.22, vy: (Math.random() - 0.5) * 0.22
      });
    }
    var ctx = c.getContext('2d');
    var raf;
    function draw() {
      if (!c.isConnected) { cancelAnimationFrame(raf); return; }
      var w = c._w, h = c._h;
      if (!w || !h) { sizeCanvas(c); raf = requestAnimationFrame(draw); return; }
      ctx.clearRect(0, 0, w, h);
      for (var k = 0; k < pts.length; k++) {
        var p = pts[k];
        p.x += p.vx; p.y += p.vy;
        if (p.x < 0 || p.x > w) p.vx *= -1;
        if (p.y < 0 || p.y > h) p.vy *= -1;
      }
      for (var a = 0; a < pts.length; a++) {
        for (var b = a + 1; b < pts.length; b++) {
          var dx = pts[a].x - pts[b].x, dy = pts[a].y - pts[b].y;
          var d = Math.hypot(dx, dy);
          if (d < linkDist) {
            ctx.globalAlpha = lineOp * (1 - d / linkDist);
            ctx.strokeStyle = color;
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(pts[a].x, pts[a].y);
            ctx.lineTo(pts[b].x, pts[b].y);
            ctx.stroke();
          }
        }
      }
      ctx.globalAlpha = dotOp;
      ctx.fillStyle = color;
      for (var m = 0; m < pts.length; m++) {
        ctx.beginPath();
        ctx.arc(pts[m].x, pts[m].y, 1.6, 0, 7);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
      raf = requestAnimationFrame(draw);
    }
    draw();
    return c;
  }

  /* ---------- forms: optional Formspree POST, then confirm ---------- */
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
        canvases.forEach(function (c) { if (c.isConnected) sizeCanvas(c); });
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
