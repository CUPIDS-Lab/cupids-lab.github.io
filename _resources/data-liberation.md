---
title: "Data liberation toolkit"
order: 5
category: tool
tag: GUIDE
eyebrow: Practitioner guide
summary: "Two open-source agent skills — one that frees stranded public data, one that builds an accountable project around it — that any AI assistant can run."
---
**Data liberation** means getting public-interest data out of wherever it's stuck — a removed page, a stack of PDFs, an undocumented portal — and into clean, documented, durable form. The lab ships it as two composable, MIT-licensed agent skills you can run inside an AI coding assistant like Claude Code, Copilot, or Gemini:

- **[data-liberation](https://github.com/CUPIDS-Lab/data-liberation-skill)** extracts, tidies, validates, and documents a messy source into a reproducible, citable dataset.
- **[data-project](https://github.com/CUPIDS-Lab/data-project-skill)** builds the right-sized project around it — documentation, pipelines, governance, and a publishable knowledge bundle.

Both climb in graded levels: start with a plain CSV, or go all the way to publication.

### What's new

The project template now lives **inside** the liberation skill (agent-driven scaffolding, no separate repo to pin), data-project ships Python and R stacks, and finished datasets archive to Harvard Dataverse with citable DOIs — the same engine behind the [Colorado Environmental Data Hub](/projects/cej/). Still on the roadmap: the governance, responsible-data, and accessibility safeguards each skill defers until a project is ready to publish sensitive material.

### When to reach for it

This is the engine behind the help desk's everyday requests — ["a website's data disappeared"](/get-involved/help/data-disappeared/), ["I have a bunch of PDFs"](/get-involved/help/documents-to-data/), and ["combine data from different sources"](/get-involved/help/combine-data/). Installation and usage live in each repo's README; browse our other [tooling & code](/resources/tooling-code/) and [tutorials & how-tos](/resources/tutorials-howtos/), or [bring a dataset to the help desk](/get-involved/#desk).
