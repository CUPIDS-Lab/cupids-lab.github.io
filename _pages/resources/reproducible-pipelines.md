---
layout: detail
permalink: /resources/reproducible-pipelines/
nav: resources
eyebrow: What we build
title: "Reproducible pipelines"
summary: "Acquisition, cleaning, and validation workflows documented end to end so anyone can rerun them."
back: /resources/
back_label: Resources
---
A finding nobody can reproduce isn't evidence — it's an assertion. **Reproducible pipelines** mean every number we publish can be traced to its source and regenerated, by us or by a skeptic, with one command.

We design pipelines around a few durable principles, drawn from **[The Turing Way](https://the-turing-way.netlify.app/reproducible-research/reproducible-research.html)** and Sandve et al.'s **[Ten Simple Rules for Reproducible Computational Research](https://doi.org/10.1371/journal.pcbi.1003285)**:

- **One command, end to end.** Acquisition → cleaning → validation → output is automated with workflow tools like [Snakemake](https://snakemake.readthedocs.io/) or `make`, not hand-run steps.
- **Version everything.** Code in Git; data and models in [DVC](https://dvc.org/); nothing depends on a file only one person has.
- **Pin the environment.** [Docker](https://www.docker.com/) or lockfiles (conda/uv) so the pipeline runs the same next year.
- **Validate in place.** Schema and range checks ([Frictionless](https://frictionlessdata.io/), [Great Expectations](https://greatexpectations.io/)) catch bad inputs before they reach a chart.
- **Literate output.** [Quarto](https://quarto.org/) and [Jupyter](https://jupyter.org/) documents interleave code, results, and prose.

The payoff is accountability: a reproducible pipeline can be audited, corrected, and re-run when the source data updates — and handed to someone else without a phone call.

See the [data liberation toolkit](/resources/data-liberation/) (these principles, packaged), our [tooling & code](/resources/tooling-code/), and how outputs become [durable archives](/resources/durable-archives/). [Bring a workflow to the help desk](/get-involved/#desk).
