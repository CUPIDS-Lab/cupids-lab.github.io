# AGENTS.md

Guidance for coding agents working in this repository.

## What this is

The website for **CUPIDS Lab** (University of Colorado Public Interest Data Science Laboratory) — a static **Jekyll 4** site deployed to GitHub Pages via GitHub Actions. Design direction: dark / data-forward, IBM Plex Mono + Public Sans, black + CU gold, with the **folder-with-arrow** motif (CUPID's golden arrow piercing open a file folder).

## Golden rules

1. **No external requests.** Everything is same-origin: fonts are self-hosted in `assets/fonts/` (`@font-face`), and JS is hand-written in `assets/js/cupids.js`. Do **not** add Google Fonts, CDNs, analytics, or third-party scripts/libraries.
2. **Content is data, not markup.** Author content in Markdown + YAML; keep presentation in `_layouts`, `_includes/components`, and the Liquid filters in `_plugins/`. Don't hand-write page HTML.
3. **Reuse the components and filters** rather than duplicating markup/inline styles. Match the existing dark theme tokens (CSS vars in `assets/css/style.css`).
4. **Don't repeat content.** Shared values have one home: site identity (title, tagline, description, mission, hero eyebrow, location) in `_config.yml`; per-item content in `_data/*.yml` or the collections. Pages and layouts *retrieve* these — never hard-code a copy that can drift. **People are single-source in `_people`** (one file per person — name, role, photo, links, bio); the director block, cards, and bylines are all projections of it, and other content references a person by **slug** (see `{% person %}` below), never by re-typing their name.
5. **One line per paragraph.** Write each paragraph on a single line (no hard wraps); blank lines separate paragraphs. Only break a line where HTML rendering needs it — e.g. an explicit `<br>`, or a `white-space: pre-line` block like the director bio.
6. **Keep CI green.** Build + link-check before pushing (see below).

## Layout of the repo

```
_pages/                Top-level pages (Markdown). Each sets an explicit
                       `permalink`. Rendered via `home` or `page` layouts.
_dispatch/             Dispatch collection — one Markdown file per issue.
_projects/ _people/ _resources/ _partners/
                       Collections — one file per item; each gets a child page
                       and is listed (as a card) on its parent page. `_people`
                       is the single source of truth for everyone (partitioned
                       by `category`); `_partners` holds organizations,
                       cross-referenced by slug from projects and the People page.
_data/*.yml            Reference data & controlled vocabularies: people group
                       taxonomy (`people.yml`), dispatch kinds (`dispatch.yml`),
                       datasets (archive), pillars, focus areas, nav, contact,
                       brand, steps.
_layouts/              default · home · page (section dispatcher) · dispatch ·
                       detail (collection item)
_includes/components/  card, card_grid, placeholder_grid, placeholder_panel,
                       chips, cta, director, archive_table, hero, steps
_includes/forms/       subscribe · helpdesk · interest
_plugins/cupids.rb     Custom Liquid filters (run because we build via Actions)
assets/                self-hosted fonts, css/style.css, js/cupids.js
```

Loose files in the repo root are intentionally minimal: `README.md`, `LICENSE`, `AGENTS.md`, `robots.txt`, plus Jekyll infra (`_config.yml`, `Gemfile`, `Gemfile.lock`) which **must** stay at the root.

## Brand identity

The brand is a dark, data-forward identity built on the **"folder with arrow"** conceit: the data the public interest depends on, stored in file folders and pierced open by CUPID's golden arrow. The canonical metadata (prompt, palette, colors, fonts, mark, asset specs) lives in **`_data/brand.yml`**; edit there, then regenerate.

**Brand prompt:** *A dark, data-forward identity for a public-interest data lab: a near-black canvas, CU gold accents, an IBM Plex Mono `cupids-lab` wordmark, and a central conceit — a magenta-pink open file folder pierced by CUPID's golden arrow (matchmaking data and democracy). A palette of color folders colors the decorative art. Restrained and civic, with a little matchmaker playfulness.*

**Color-folder palette** — each hue renders as a recolored file folder (the per-color `folders/` collection + the decorative art):

| Name | Hex |
|------|-----|
| red | `#ed4e5b` |
| orange | `#f0883e` |
| yellow | `#f7c948` |
| green | `#6fcf97` |
| blue | `#4a9fe6` |
| purple | `#9b6dd6` |
| brown | `#9c6b4a` |
| white | `#e8e6e0` |
| pink | `#f06fa0` |

The mark is the **folder-with-arrow** artwork — the cleaned seed at `assets/brand/parent-elements/folder-arrow-seed.svg` (a magenta-pink open file folder with a CU-gold arrow through it), embedded as-is. It's emitted as `favicon.svg`, `avatar.svg`, and a transparent **`mark.svg`** rendered inline across the site chrome (header, footer, heading accents `.mark-accent`, form-success) — the interactive ones (`.spark`) trigger the folder-burst easter egg. Edit the seed to change the artwork. Core UI colors mirror the CSS tokens in `assets/css/style.css`.

**Generation harness:** `script/generate-brand.rb` digests `_data/brand.yml` and emits deterministic SVGs into `assets/brand/`:

```bash
ruby script/generate-brand.rb     # SVGs
node script/rasterize.mjs          # PNG previews (needs `npm install` first)
# or both:  npm run brand:all
```

`generate-brand.rb` emits SVGs: `favicon.svg`, **`mark.svg`** (transparent mark for inline chrome), `avatar.svg` (profile lockup: folder-with-arrow + wordmark), `og.svg` (1200×630 social card), `banner.svg`, `pattern.svg` (tiling), `background.svg` (1600×900 "folder map"), and a **`folders/`** collection — one recolored file folder per palette hue (e.g. `folders/green.svg`) for list bullets, scatter art, or icons.

`rasterize.mjs` exports PNG previews next to the SVGs via **headless Chrome** and embeds the self-hosted wordmark fonts. All artwork is our own vectors (folders + arrow), so no emoji fonts are needed. `og.png` is wired as the site's `og:image` (`image:` in `_config.yml`). `cupids.js` renders the same color folders on the hero canvas (a `Path2D` folder filled per node) with an SI "spread" where CUPID's gold opens them. Commit regenerated assets; `script/`, `node_modules/`, and `package*.json` are excluded from the Jekyll build.

## Build & test

```bash
bundle install
bundle exec jekyll build
LANG=C.UTF-8 bundle exec htmlproofer ./_site \
  --disable-external --allow-hash-href --ignore-empty-alt --no-enforce-https
```

`LANG=C.UTF-8` is required so html-proofer reads UTF-8 source (the CI sets it). Local serve: `bundle exec jekyll serve`.

## Pages (the `page` layout)

A page declares `sections:` in front matter; each is dispatched to a component. Section `type`s: `cards`, `collection`, `chips`, `archive`, `director`, `cta`, `dispatch_list`, `subscribe`, `helpdesk`, `interest`. A list is inline (`items:`) or pulled from `_data` via a dotted `data:` path, or from a collection via `name:` (add `only_featured: true` to render just the flagship item, e.g. the projects featured card). The page's Markdown body becomes the hero lead.

The **home** page (`home` layout) is special: its hero comes from `_config.yml` (`hero_eyebrow` + `tagline` headline + `hero_lead`) and `mission`, and its featured block is inherited from the `_projects` doc marked `featured: true` — none of that is duplicated in `index.md`, which holds only the home-specific showcase (the "moment" ledger/stats, pillar headings, featured caption). (`description` is the separate SEO/meta description.)

## Collections & ranking metadata

Items in `_projects`, `_people`, `_resources` (and `_dispatch`) are individual Markdown files. Front matter conventions:

- `title` — display title
- `summary` — one-line description (used as the card body + hero lead)
- `order` — **pin rank** (integer, ascending); reserve it for the few items that must lead (e.g. the director). Unpinned items fall back to alphabetical, so a large roster needs no manual numbering.
- `sort_name` — alphabetical sort key when unpinned (e.g. a surname, `Keegan`); defaults to `title`
- `category` — **machine-friendly group tag**; for `_people` it must be a group key in `_data/people.yml` (`director`, `faculty`, `student`, `advisor`, `alumni`). Drives grouping/filtering.
- `status` — people lifecycle (`active`, `alumni`, `emeritus`); a transition (student → alumni) is a one-field edit, not a moved file
- `tag` — optional display label (drives accent color via `accent_color`)
- `featured: true` — flagship item; rendered by the parent's bespoke block (featured card / director) and **omitted** from the grid
- `published: false` — keep as an unpublished draft/template

`collection_cards` (in `_plugins/cupids.rb`) sorts by `[order, sort_name || title]` and exposes `order`, `category`, `status` on each card. The `collection` section accepts an optional `category:` to filter the grid to one category. The **People page** (`roster` section) renders one card grid per group by iterating `_data/people.yml` — to add a group, add a vocabulary entry there and tag a person's `category`; no template change.

## Custom Liquid filters (`_plugins/cupids.rb`)

`accent_color` · `bullet_color` · `tone_class` · `site_data` (dotted-path data lookup) · `smart_url` · `static_exists` (true when a referenced static asset is present) · `dispatch_cards` · `collection_cards` · `people_links` (slug list → linked names) · the `{% person %}` tag.

**Linking people.** Reference a person by their `_people` **slug** (the filename), never by display name — slugs are unique (no ambiguity) and the link text is read from the person's `title` (so a rename can't drift it). Inline in prose: `{% person brian-keegan %}` → a link to their profile. In front matter (`authors:`, `team:`, …): use slug lists, rendered via `people_links` or the byline. **It's enforced:** an unknown slug *fails the build* — a `post_read` hook validates every reference, and the `{% person %}` tag raises at render — while an off-vocabulary `_people` `category` logs a warning.

> These run only because the site is built with `bundle exec jekyll build` in the GitHub Actions workflow — **not** the legacy `github-pages` gem (which runs in safe mode and ignores `_plugins/`). Keep deploying through Actions.

## Adding content (no template changes needed)

- **Dispatch issue:** add `_dispatch/<date>-<slug>.md` (set `published: true`). Set `kind:` to a key from the controlled vocabulary in `_data/dispatch.yml` (+ optional `issue:` number) — the tag (`ISSUE 01 · ANNOUNCEMENT`) and its accent are composed from there, not hand-written. List `authors:` as `_people` **slugs** so the byline links them (an unknown slug fails the build); mention people in the body with `{% person <slug> %}`. Reading time is estimated from the body length automatically (no field).
- **Project / person / resource:** add a file to the matching collection with `title`, `summary`, `category` (+ optional `tag`, and for people `sort_name`/`status`). It gets a child page and a linked card on the parent automatically. For `_people`, `category` must be a group in `_data/people.yml`; a person's contact (`email`, `github`, `link`/`link_label`) renders from front matter on their profile page.
- **Partner (organization):** add `_partners/<slug>.md` with `title`, `summary`, and optional `link`/`link_label`. It gets a `/partners/<slug>/` page and a card on the People page; link that URL from a project to cross-reference it.
- **Datasets (archive table):** add rows under `datasets:` in `_data/archive.yml` — the placeholder panel becomes a table.
- **Forms:** set `form_endpoint` in `_config.yml` (Formspree) to make the forms POST; otherwise they show a client-side confirmation.

## CI / deployment

- `.github/workflows/ci.yml` — build + html-proofer on every push/PR.
- `.github/workflows/pages.yml` — build + deploy to GitHub Pages on `main`.
- Pages source must be **Settings → Pages → Source = GitHub Actions**.

## Git

Develop on a feature branch, open a PR to `main`, keep CI green. Don't commit `_site/`, `vendor/`, or `node_modules/` (see `.gitignore`).

## Provenance

This site was designed and built with Claude — a combination of **Claude Design** (initial design exploration) and **Claude Code** (implementation) — on the Opus 4.8 model.
