# cupids-lab.github.io

**CUPIDS Lab** — the University of Colorado Public Interest Data Science
Laboratory. We preserve the data democracy depends on: archiving at-risk
public datasets, building data infrastructure, sharing resources, and
matching technical capacity with the journalists and civic groups who need
it.

This repository is the lab's website — a static [Jekyll](https://jekyllrb.com)
site deployed to GitHub Pages. The design is the "data-forward / technical"
direction: dark theme, IBM Plex Mono + Public Sans, black + CU gold, with the
CUPIDS matchmaker heart (`<3` / ♥) threaded throughout.

---

## Pages

| Page             | URL              | Source                |
|------------------|------------------|-----------------------|
| Home (showcase)  | `/`              | `index.html`          |
| Projects         | `/projects/`     | `projects.html`       |
| People           | `/people/`       | `people.html`         |
| Research         | `/research/`     | `research.html`       |
| Dispatch         | `/dispatch/`     | `dispatch.html`       |
| Resources        | `/resources/`    | `resources.html`      |
| Get Involved     | `/get-involved/` | `get-involved.html`   |

The **home page** is hand-built. Every **child page** renders through one
shared layout (`_layouts/page.html`) driven entirely by its front matter —
edit the front matter and the page updates. This is the Jekyll equivalent of
the design's Markdown-driven model.

---

## Editing content

Each child page is just front matter: an `eyebrow`, a `title`, an `intro`, and
a list of `sections`. Each section has a `type`:

```yaml
sections:
  - type: content          # prose + a grid of cards
    heading: "What we build"
    cols: 3                 # cards per row (1–4)
    body: "Optional intro paragraph."
    cards:
      - tag: "GUIDE"        # colors itself: GUIDE/ARCHIVE→green,
        title: "A card"     #   REPORT/RAPID/ISSUE→amber,
        body: "Body text."  #   INVESTIGATION→red, else gold
        meta: "May 2026"    # optional byline/meta line
        bullets:            # optional 2-col bullet list
          - { text: "Item", accent: green }   # green|amber|red|gold

  - type: chips             # heading + body + pill row
    heading: "Focus areas"
    chips: [Information retrieval, Accessible visualization]

  - type: archive           # public-data-archive table
    rows:
      - { dataset: "…", source: "EPA", updated: "2026-05", status: "PRESERVED", tone: green }

  - type: director          # headshot + bio + contacts
    name: "Brian C. Keegan"
    role: "…"
    email: "…"
    github: "github.com/CUPIDS-Lab"
    bio: |
      Paragraph one.
      Paragraph two.

  - type: cta               # call-to-action banner
    title: "…"
    text: "…"
    label: "Join the lab →"
    to: "/get-involved/"

  - type: subscribe         # newsletter signup
  - type: helpdesk          # "how it works" steps + request form
  - type: interest          # join-the-lab interest form
```

Section backgrounds alternate automatically.

---

## Local development

Requires Ruby 3.x and Bundler.

```bash
bundle install
bundle exec jekyll serve      # http://localhost:4000

# Validate HTML + internal links (matches CI)
bundle exec jekyll build
LANG=C.UTF-8 bundle exec htmlproofer ./_site \
  --disable-external --allow-hash-href --ignore-empty-alt --no-enforce-https
```

---

## Performance & privacy

The site makes **no external CDN, font, or API requests** — everything is
served from this origin:

- **Fonts are self-hosted.** IBM Plex Mono and Public Sans (OFL, latin subset,
  `woff2`) live in `assets/fonts/`, declared via `@font-face` with
  `font-display: swap`. No Google Fonts / `gstatic.com` calls. Licenses are
  bundled alongside the fonts.
- **No third-party libraries.** The particle-links hero background and the
  heart-burst easter egg are ~5 KB of hand-written vanilla JS in
  `assets/js/cupids.js`. Nothing is loaded from a CDN.
- The two primary font weights are `<link rel="preload">`-ed to avoid layout
  shift, and animations are disabled under `prefers-reduced-motion`.

## Forms

The help-desk, join-interest, and newsletter forms show a client-side
confirmation by default and **send nothing** (honest to the prototype — no
hidden third-party calls). To wire them to a real backend, set a
[Formspree](https://formspree.io) endpoint in `_config.yml`:

```yaml
form_endpoint: "https://formspree.io/f/xxxxxxxx"
```

When set, forms `POST` there and then show the confirmation.

---

## Deployment (GitHub Pages)

Deployment is handled by GitHub Actions, **not** the legacy Pages Jekyll
builder, so the site can use current Jekyll 4 + plugins.

**One-time setup:** repo **Settings → Pages → Build and deployment → Source**
= **GitHub Actions**.

- `.github/workflows/ci.yml` — builds the site and runs HTML/link validation
  on every push and pull request (the quality gate).
- `.github/workflows/pages.yml` — builds and deploys to GitHub Pages on every
  push to `main`.

---

## License

Site code is released under the terms in [`LICENSE`](LICENSE). Bundled fonts
are licensed under the SIL Open Font License (see `assets/fonts/`).

Matchmaking data &amp; democracy — made with ♥ in Boulder.
