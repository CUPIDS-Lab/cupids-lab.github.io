#!/usr/bin/env node
// Rasterize the brand SVGs in assets/brand/ to PNG previews via headless
// Chrome, so emoji render in full color (Noto Color Emoji on Linux/CI) and the
// wordmark uses our self-hosted fonts. Open-licensed fonts only — we do not
// bundle proprietary emoji artwork.
//
// Usage:  node script/rasterize.mjs        (needs `npm install` first)
import { readFileSync, writeFileSync, readdirSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import puppeteer from "puppeteer";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const BRAND = join(ROOT, "assets", "brand");
const FONTS = join(ROOT, "assets", "fonts");

// Embed the self-hosted fonts as data URLs so the wordmark renders correctly.
const FACES = [
  ["IBM Plex Mono", 400, "ibm-plex-mono-400.woff2"],
  ["IBM Plex Mono", 500, "ibm-plex-mono-500.woff2"],
  ["IBM Plex Mono", 600, "ibm-plex-mono-600.woff2"],
  ["Public Sans", 600, "public-sans-600.woff2"],
  ["Public Sans", 800, "public-sans-800.woff2"],
];
const fontCss = FACES.map(([fam, wt, file]) => {
  const b64 = readFileSync(join(FONTS, file)).toString("base64");
  return `@font-face{font-family:'${fam}';font-weight:${wt};font-display:block;src:url(data:font/woff2;base64,${b64}) format('woff2')}`;
}).join("\n");

const svgs = readdirSync(BRAND).filter((f) => f.endsWith(".svg"));
const dim = (svg, attr) => {
  const m = svg.match(new RegExp(`<svg[^>]*\\b${attr}="(\\d+)"`));
  return m ? +m[1] : 512;
};

const browser = await puppeteer.launch({ args: ["--no-sandbox", "--disable-setuid-sandbox"] });
const page = await browser.newPage();
let n = 0;

for (const file of svgs) {
  const svg = readFileSync(join(BRAND, file), "utf8");
  const w = dim(svg, "width"), h = dim(svg, "height");
  const scale = Math.min(8, Math.max(1, Math.round(640 / Math.max(w, h))));
  await page.setViewport({ width: w, height: h, deviceScaleFactor: scale });
  await page.setContent(
    `<!doctype html><meta charset="utf-8"><style>${fontCss}\nhtml,body{margin:0;padding:0}</style>${svg}`,
    { waitUntil: "domcontentloaded" }
  );
  await page.evaluate(async () => { try { await document.fonts.ready; } catch (e) {} });
  const out = file.replace(/\.svg$/, ".png");
  const buf = await page.screenshot({ type: "png", omitBackground: true, clip: { x: 0, y: 0, width: w, height: h } });
  writeFileSync(join(BRAND, out), buf);
  console.log(`  ${out}  ${w * scale}x${h * scale}  ${(buf.length / 1024).toFixed(1)} KB`);
  n++;
}

await browser.close();
console.log(`Rasterized ${n} PNG previews into assets/brand/.`);
