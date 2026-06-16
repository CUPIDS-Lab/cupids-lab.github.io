---
title: "Tooling & code"
order: 4
category: tool
tag: ARCHIVE
summary: "Open-source pipelines and notebooks, free to fork and adapt."
---
Everything the lab builds is open source — pipelines, notebooks, and small utilities you can fork, audit, and adapt. We would rather ship reusable tools than one-off scripts, so the next newsroom or clinic doesn't start from scratch.

Find our code on **[GitHub](https://github.com/CUPIDS-Lab)**, MIT-licensed. The flagship is the **[data liberation toolkit](/resources/data-liberation/)** — an agent skill and project template that scaffold a full acquisition → cleaning → validation → documentation pipeline.

Our tooling is built on open, widely supported standards so it outlives any one contributor:

- **Structure** follows [Cookiecutter Data Science](https://cookiecutter-data-science.drivendata.org/) — a predictable layout for data, code, and outputs.
- **Pipelines** are made reproducible with workflow tools like [Snakemake](https://snakemake.readthedocs.io/), with data and model versioning via [DVC](https://dvc.org/) and Git.
- **Environments** are pinned ([Docker](https://www.docker.com/), conda/uv) so a notebook that ran last year runs today.
- **Analysis** lives in literate documents — [Jupyter](https://jupyter.org/) and [Quarto](https://quarto.org/) — that interleave code, results, and explanation.

We favor small, composable utilities over monoliths, and we write tests so a fix in one project doesn't silently break another. Each release notes its license, dependencies, and the data it expects.

We test before we recommend (see [evaluated tooling](/resources/evaluated-tooling/)) and document as we build (see [data documentation guides](/resources/data-documentation-guides/)), so a tool arrives with its caveats attached.

Found a bug, or want a pipeline adapted to your data? Open an issue on [GitHub](https://github.com/CUPIDS-Lab) or [reach the help desk](/get-involved/#desk).
