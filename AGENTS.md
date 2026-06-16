# AGENTS.md

Guidance for coding agents working in this repository.

## What this is

The website for **CUPIDS Lab** (University of Colorado Public Interest Data Science Laboratory) — a static **Jekyll 4** site deployed to GitHub Pages via GitHub Actions. Design direction: dark / data-forward, IBM Plex Mono + Public Sans, black + CU gold, with the matchmaker heart (`<3` / ♥) motif.

## Golden rules

1. **No external requests.** Everything is same-origin: fonts are self-hosted in `assets/fonts/` (`@font-face`), and JS is hand-written in `assets/js/cupids.js`. Do **not** add Google Fonts, CDNs, analytics, or third-party scripts/libraries.
2. **Content is data, not markup.** Author content in Markdown + YAML; keep presentation in `_layouts`, `_includes/components`, and the Liquid filters in `_plugins/`. Don't hand-write page HTML.
3. **Reuse the components and filters** rather than duplicating markup/inline styles. Match the existing dark theme tokens (CSS vars in `assets/css/style.css`).
4. **Keep CI green.** Build + link-check before pushing (see below).

## Layout of the repo

```
_pages/                Top-level pages (Markdown). Each sets an explicit
                       `permalink`. Rendered via `home` or `page` layouts.
_dispatch/             Dispatch collection — one Markdown file per issue.
_projects/ _people/ _resources/
                       Collections — one file per item; each gets a child page
                       and is listed (as a card) on its parent page.
_data/*.yml            Reference data: director block, featured project,
                       datasets (archive), pillars, focus areas, nav, steps.
_layouts/              default · home · page (section dispatcher) · dispatch ·
                       detail (collection item)
_includes/components/  card, card_grid, placeholder_grid, placeholder_panel,
                       chips, cta, director, archive_table, hero, steps
_includes/forms/       subscribe · helpdesk · interest
_plugins/cupids.rb     Custom Liquid filters (run because we build via Actions)
assets/                self-hosted fonts, css/style.css, js/cupids.js
```

Loose files in the repo root are intentionally minimal: `README.md`, `LICENSE`, `AGENTS.md`, `robots.txt`, plus Jekyll infra (`_config.yml`, `Gemfile`, `Gemfile.lock`) which **must** stay at the root.

## Build & test

```bash
bundle install
bundle exec jekyll build
LANG=C.UTF-8 bundle exec htmlproofer ./_site \
  --disable-external --allow-hash-href --ignore-empty-alt --no-enforce-https
```

`LANG=C.UTF-8` is required so html-proofer reads UTF-8 source (the CI sets it). Local serve: `bundle exec jekyll serve`.

## Pages (the `page` layout)

A page declares `sections:` in front matter; each is dispatched to a component. Section `type`s: `cards`, `collection`, `chips`, `archive`, `director`, `cta`, `dispatch_list`, `subscribe`, `helpdesk`, `interest`. A list is inline (`items:`) or pulled from `_data` via a dotted `data:` path, or from a collection via `name:`. The page's Markdown body becomes the hero lead.

## Collections & ranking metadata

Items in `_projects`, `_people`, `_resources` (and `_dispatch`) are individual Markdown files. Front matter conventions:

- `title` — display title
- `summary` — one-line description (used as the card body + hero lead)
- `order` — **ordinal rank** (integer, ascending); the primary sort key
- `category` — **machine-friendly group tag** (e.g. `investigation`, `guide`, `advisor`); used for grouping/filtering and as a secondary sort key
- `tag` — optional display label (drives accent color via `accent_color`)
- `featured: true` — flagship item; rendered by the parent's bespoke block (featured card / director) and **omitted** from the grid
- `published: false` — keep as an unpublished draft/template

`collection_cards` (in `_plugins/cupids.rb`) sorts by `[order, category, title]` and exposes `order` + `category` on each card. The `collection` section accepts an optional `category:` to filter the grid to one category.

## Custom Liquid filters (`_plugins/cupids.rb`)

`accent_color` · `bullet_color` · `tone_class` · `site_data` (dotted-path data lookup) · `smart_url` · `dispatch_cards` · `collection_cards`.

> These run only because the site is built with `bundle exec jekyll build` in the GitHub Actions workflow — **not** the legacy `github-pages` gem (which runs in safe mode and ignores `_plugins/`). Keep deploying through Actions.

## Adding content (no template changes needed)

- **Dispatch issue:** add `_dispatch/<date>-<slug>.md` (set `published: true`).
- **Project / person / resource:** add a file to the matching collection with `title`, `summary`, `order`, `category` (+ optional `tag`). It gets a child page and a linked card on the parent automatically.
- **Datasets (archive table):** add rows under `datasets:` in `_data/archive.yml` — the placeholder panel becomes a table.
- **Forms:** set `form_endpoint` in `_config.yml` (Formspree) to make the forms POST; otherwise they show a client-side confirmation.

## CI / deployment

- `.github/workflows/ci.yml` — build + html-proofer on every push/PR.
- `.github/workflows/pages.yml` — build + deploy to GitHub Pages on `main`.
- Pages source must be **Settings → Pages → Source = GitHub Actions**.

## Git

Develop on a feature branch, open a PR to `main`, keep CI green. Don't commit `_site/`, `vendor/`, or `node_modules/` (see `.gitignore`).
