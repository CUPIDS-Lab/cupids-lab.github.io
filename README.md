# cupids-lab.github.io

**CUPIDS Lab** — the University of Colorado Public Interest Data Science Laboratory. We preserve the data democracy depends on: archiving at-risk public datasets, building data infrastructure, sharing resources, and matching technical capacity with the journalists and civic groups who need it.

A static [Jekyll](https://jekyllrb.com) site deployed to GitHub Pages — dark, data-forward design (IBM Plex Mono + Public Sans, black + CU gold) with the CUPIDS matchmaker heart (`<3` / 💘) threaded throughout.

---

## How it's built

Content lives in **Markdown + YAML**; presentation lives in **layouts, component includes, and Liquid filters**. No page is hand-written HTML, and shared values live in exactly one place.

```
_config.yml            Site identity: title, tagline (hero headline),
                       description (hero lead), mission, hero_eyebrow, location
_pages/*.md            Top-level pages (each sets its own permalink)
_dispatch/*.md         the Dispatch — one Markdown file per issue
_projects/ _people/ _resources/*.md
                       collections — one file per item; each gets a child page,
                       linked from its parent
_data/*.yml            reference data: people (director), datasets (archive),
                       pillars, focus areas, navigation, contact, brand, steps
_layouts/              default · home · page (section dispatcher) · dispatch ·
                       detail (collection item)
_includes/components/  card, card_grid, placeholder_grid/panel, chips, cta,
                       director, archive_table, hero, steps, secure_contact
_plugins/cupids.rb     custom Liquid filters ("converters")
assets/                self-hosted fonts, CSS, JS, generated brand assets
```

### Pages are data, not markup

Every page selects a layout and declares its content in front matter; its Markdown body becomes the hero lead, and `sections:` compose the rest from components. A section's data is inline (`items:`), pulled from `_data` via a dotted `data:` path (resolved by `site_data`), or pulled from a collection via `name:`.

Section `type`s: `cards`, `collection`, `chips`, `archive`, `director`, `cta`, `dispatch_list`, `subscribe`, `helpdesk`, `interest`, `secure`.

The **home** page is special: its hero (`hero_eyebrow` + `tagline` + `description`) and `mission` come from `_config.yml`, and its featured block is inherited from the `_projects` doc marked `featured: true` — so none of that is duplicated in `index.md`.

### Liquid filters ("converters") — `_plugins/cupids.rb`

Computed design rules are abstracted into filters so templates stay declarative: `accent_color` (tag → accent), `bullet_color`, `tone_class`, `site_data` (dotted path into `_data`), `smart_url`, `dispatch_cards`, `collection_cards`.

> Custom plugins run because the site builds via GitHub Actions (not the legacy `github-pages` gem). Keep deploying through the included workflow.

---

## Editing content

| To change… | Edit… |
|---|---|
| Site identity (hero, mission, description, location) | `_config.yml` |
| A page's intro / sections | that page's file in `_pages/` |
| A project / person / resource (each has a child page) | add/edit a file in `_projects/`, `_people/`, `_resources/` |
| The featured project (home + projects page) | the `_projects` doc with `featured: true` (`_projects/cej.md`) |
| The director block | `_data/people.yml` |
| Research focus areas · home pillars · navigation | `_data/focus_areas.yml` · `_data/pillars.yml` · `_data/navigation.yml` |
| Secure-contact channels | `_data/contact.yml` |
| Brand metadata | `_data/brand.yml` (then regenerate — see below) |
| A Dispatch issue | add a file to `_dispatch/` |

Collection items each render a **child page** (`/projects/<name>/`, etc.) and appear as linked cards on the parent. An item flagged `featured: true` is shown via the parent's bespoke block and omitted from the grid.

### Placeholders are data-driven

The **projects grid**, **Dispatch list**, and **public data archive** render on-brand placeholder tiles while their source has no entries, and fill in automatically when you add content — no template changes. Add a `_projects/*.md` file, publish a `_dispatch/*.md` issue (`published: true`), or add rows under `datasets:` in `_data/archive.yml`. (`_dispatch/2026-05-15-example-ozone.md` is an unpublished template to copy.)

---

## Brand assets

`_data/brand.yml` is the single source of truth for the brand (the Cupid `💘` motif + the Unicode color-heart palette). Regenerate the SVG/PNG assets in `assets/brand/` with:

```bash
npm install          # once, for the PNG rasterizer (headless Chrome)
npm run brand:all    # ruby script/generate-brand.rb && node script/rasterize.mjs
```

See `AGENTS.md` for the full brand spec. We render emoji via open-licensed fonts (Noto Color Emoji for PNGs) and never bundle proprietary artwork.

## Local development

```bash
bundle install
bundle exec jekyll serve            # http://localhost:4000

bundle exec jekyll build
LANG=C.UTF-8 bundle exec htmlproofer ./_site \
  --disable-external --allow-hash-href --ignore-empty-alt --no-enforce-https
```

## Performance & privacy

No external CDN / font / API requests — everything is same-origin. Fonts are self-hosted (IBM Plex Mono + Public Sans, OFL, latin `woff2`) via `@font-face` with `font-display: swap`. The hero heart-emoji network (an SI "spread" simulation) and the heart-burst easter egg are hand-written vanilla JS in `assets/js/cupids.js`, and all animation is disabled under `prefers-reduced-motion`.

## Forms

The help-desk, join-interest, and newsletter forms show a client-side confirmation and send nothing by default. To wire them to a backend, set a [Formspree](https://formspree.io) endpoint in `_config.yml`:

```yaml
form_endpoint: "https://formspree.io/f/xxxxxxxx"
```

## Deployment (GitHub Pages)

Deployed by GitHub Actions. **One-time setup:** Settings → Pages → Build and deployment → Source = **GitHub Actions**. `.github/workflows/ci.yml` builds and link-checks every push/PR; `.github/workflows/pages.yml` builds and deploys on pushes to `main`.

## License

Site code under [`LICENSE`](LICENSE). Bundled fonts under the SIL Open Font License (see `assets/fonts/`).

Matchmaking data &amp; democracy — made with ♥ in Boulder.
