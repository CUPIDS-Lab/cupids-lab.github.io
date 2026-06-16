# cupids-lab.github.io

**CUPIDS Lab** — the University of Colorado Public Interest Data Science
Laboratory. We preserve the data democracy depends on: archiving at-risk
public datasets, building data infrastructure, sharing resources, and
matching technical capacity with the journalists and civic groups who need
it.

A static [Jekyll](https://jekyllrb.com) site deployed to GitHub Pages. The
design is the "data-forward / technical" direction: dark theme, IBM Plex Mono
+ Public Sans, black + CU gold, with the CUPIDS matchmaker heart (`<3` / ♥)
threaded throughout.

---

## How it's built

Content lives in **Markdown + YAML data**; presentation lives in **layouts,
component includes, and Liquid filters**. No page is hand-written HTML.

```
index.md, projects.md, people.md, …   Markdown pages — front matter + a
                                       Markdown body (the hero lead)
_dispatch/*.md                         the Dispatch — one file per issue
_projects/ _people/ _resources/*.md    one file per item; each gets its own
                                       child page, linked from the parent
_data/*.yml                            reference data (director, featured
                                       project, datasets, pillars, nav, …)
_layouts/        default · home · page (section dispatcher) · dispatch
_includes/components/*.html            reusable "functions": card, card_grid,
                                       placeholder_grid/panel, chips, cta,
                                       director, archive_table, hero, steps
_plugins/cupids.rb                     custom Liquid filters ("converters")
assets/                                self-hosted fonts, CSS, ~5 KB JS
```

### Pages are data, not markup

Every page selects a layout and declares its content in front matter. A page's
**Markdown body becomes the hero lead**, and `sections:` compose the body from
components:

```yaml
---
layout: page
nav: people
eyebrow: People
title: "Cross-functional teams, one mission."
sections:
  - { type: director, data: people.director }      # pulls _data/people.yml
  - { type: cards, heading: "Collaborators & advisors", cols: 4, data: people.advisors }
  - { type: cta, title: "…", label: "Join the lab →", to: "/get-involved/" }
---
CUPIDS draws students and faculty from information science, journalism, …
```

Section `type`s: `cards`, `chips`, `archive`, `director`, `cta`,
`dispatch_list`, `subscribe`, `helpdesk`, `interest`. A section's list can be
inline (`items:`) or pulled from a data file via `data:` (a dotted path like
`people.advisors`, resolved by the `site_data` filter).

### Liquid filters ("converters") — `_plugins/cupids.rb`

The design's computed rules are abstracted into filters so templates stay
declarative:

- `accent_color` — tag → accent (INVESTIGATION→red, REPORT/RAPID/ISSUE→amber, GUIDE/ARCHIVE→green, else gold)
- `bullet_color` — `green|amber|red|gold` → hex
- `tone_class` — archive status tone → CSS class
- `site_data` — resolve a dotted path into `_data`
- `smart_url` — baseurl-prefix internal links, leave external/mailto alone
- `dispatch_cards` — map Dispatch collection docs → card data

> Custom plugins run because the site builds via GitHub Actions (not the
> legacy `github-pages` gem). Keep deploying through the included workflow.

---

## Editing content

| To change… | Edit… |
|---|---|
| A page's intro / sections | that page's `.md` file |
| A project / person / resource (each has a child page) | add/edit a file in `_projects/`, `_people/`, `_resources/` |
| The director block | `_data/people.yml` |
| The featured project card | `_data/projects.yml` |
| Research focus areas | `_data/focus_areas.yml` |
| Home pillars | `_data/pillars.yml` |
| Navigation | `_data/navigation.yml` |
| A Dispatch issue | add a file to `_dispatch/` |

Items in the `_projects`, `_people`, and `_resources` collections each render
a **child page** (`/projects/<name>/`, etc.) and are listed as cards — linked
to that page — on the parent. An item flagged `featured: true` is shown via the
parent's bespoke block (featured card / director) and omitted from the grid.

### Placeholders are data-driven

The **projects grid**, **Dispatch list**, and **public data archive** render
on-brand placeholder tiles while their data source is empty. They fill in
automatically when you add content — no template changes:

- add project cards under `more:` in `_data/projects.yml`
- add datasets under `datasets:` in `_data/archive.yml`
- add a `_dispatch/*.md` issue with `published: true`

(`_dispatch/2026-05-15-example-ozone.md` is an unpublished template to copy.)
The funded **Featured · CUPIDS × CEJ** project and the People/Guides lists are
real content.

---

## Local development

```bash
bundle install
bundle exec jekyll serve            # http://localhost:4000

bundle exec jekyll build
LANG=C.UTF-8 bundle exec htmlproofer ./_site \
  --disable-external --allow-hash-href --ignore-empty-alt --no-enforce-https
```

## Performance & privacy

No external CDN / font / API requests — everything is same-origin:

- **Fonts self-hosted.** IBM Plex Mono + Public Sans (OFL, latin `woff2`) in
  `assets/fonts/`, via `@font-face` with `font-display: swap`. No Google Fonts.
- **No third-party JS.** The particle hero background and heart-burst easter
  egg are ~5 KB of vanilla JS in `assets/js/cupids.js`. Animation is disabled
  under `prefers-reduced-motion`.

## Forms

The help-desk, join-interest, and newsletter forms show a client-side
confirmation and send nothing by default. To wire them to a backend, set a
[Formspree](https://formspree.io) endpoint in `_config.yml`:

```yaml
form_endpoint: "https://formspree.io/f/xxxxxxxx"
```

## Deployment (GitHub Pages)

Deployed by GitHub Actions. **One-time setup:** Settings → Pages → Build and
deployment → Source = **GitHub Actions**.

- `.github/workflows/ci.yml` — build + HTML/link validation on every push/PR.
- `.github/workflows/pages.yml` — build + deploy on pushes to `main`.

## License

Site code under [`LICENSE`](LICENSE). Bundled fonts under the SIL Open Font
License (see `assets/fonts/`).

Matchmaking data &amp; democracy — made with ♥ in Boulder.
