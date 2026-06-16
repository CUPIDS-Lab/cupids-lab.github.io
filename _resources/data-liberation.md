---
title: "Data liberation toolkit"
order: 5
category: tool
tag: GUIDE
eyebrow: Practitioner guide
summary: "An open-source agent skill and project template for rescuing civic data — finding it, extracting it, and archiving it before it disappears."
---
**Data liberation** is the work of getting public-interest data out of wherever it's stuck — a removed web page, a stack of PDFs, an undocumented portal — and into a clean, documented, durable form. The lab packages that workflow as two open-source, MIT-licensed repositories you can use today:

- **[data-liberation-skill](https://github.com/CUPIDS-Lab/data-liberation-skill)** — an agent skill that orchestrates a data-liberation project end to end: scoping the source, acquiring and extracting the data, validating it, and documenting its provenance.
- **[data-liberation-template](https://github.com/CUPIDS-Lab/data-liberation-template)** — the working Python project the skill scaffolds from. Its `scripts/scaffold.py` copies the template to spin up a new, ready-to-run liberation project.

### How it fits together

Point the skill at a source; it scaffolds a fresh project from the template, then walks the acquisition → cleaning → validation → documentation pipeline so the result is reproducible and citable. Every run is meant to leave behind data *and* the record of how it was obtained.

### When to reach for it

This is the engine behind the help desk's everyday requests — ["a website's data disappeared"](/get-involved/help/data-disappeared/), ["I have a bunch of PDFs"](/get-involved/help/documents-to-data/), and ["combine data from different sources"](/get-involved/help/combine-data/).

Installation and exact usage live in each repo's README. Browse our other [tooling & code](/resources/tooling-code/) and [tutorials & how-tos](/resources/tutorials-howtos/), or [bring a dataset to the help desk](/get-involved/#desk).
