---
layout: detail
permalink: /resources/durable-archives/
nav: resources
eyebrow: What we build
title: "Durable archives"
summary: "At-risk public datasets captured in open, persistent repositories that outlive their original sources."
back: /resources/
back_label: Resources
---
When a dataset disappears, the public loses the ability to hold power to account. **Durable archives** are our answer: at-risk public data captured in open, persistent form that outlives its original source.

Durability is a discipline, not a backup. We follow the archival community's reference model, **[OAIS](https://www.iso.org/standard/57284.html)** (ISO 14721), and standard practices for keeping bits trustworthy over time:

- **Fixity** — checksums recorded at capture and re-verified, so silent corruption or tampering is detectable.
- **Packaging** with **[BagIt](https://datatracker.ietf.org/doc/html/rfc8493)** (RFC 8493), so files travel with their manifests.
- **Persistent identifiers** — [DOIs via DataCite](https://datacite.org/) — so a citation still resolves years later.
- **Open formats** — non-proprietary, text-based formats (CSV, Parquet, JSON) so the data stays readable without licensed software.
- **Redundancy** across independent repositories, in the spirit of **[LOCKSS](https://www.lockss.org/)**: lots of copies keep stuff safe.

We don't work alone. We build on and contribute to the data-rescue ecosystem — the **[Internet Archive](https://web.archive.org/)**, the **[Environmental Data & Governance Initiative](https://envirodatagov.org/)** (EDGI), and **[DataLumos](https://www.datalumos.org/)**, ICPSR's archive for government data.

Every archived dataset is paired with a [documentation guide](/resources/data-documentation-guides/) and, where possible, the [reproducible pipeline](/resources/reproducible-pipelines/) that captured it. This is the public face of our [At-Risk Federal Data Archive](/projects/at-risk-archive/) and [data liberation toolkit](/resources/data-liberation/).

Know of a dataset at risk? [Tell the help desk](/get-involved/#desk).
