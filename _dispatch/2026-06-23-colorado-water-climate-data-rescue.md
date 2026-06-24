---
title: "AI-built, auto-updated, audited, archived: rescuing Colorado's water and climate data"
kind: report
issue: 2
date: 2026-06-23
authors:
  - brian-keegan
summary: "Four open pipelines pull Colorado's reservoir, streamflow, snowpack, and climate records out of a dozen agency systems — generated with AI, rebuilt every month, auditable from source to code, and bound for permanent DOIs on Harvard Dataverse."
published: false
---

Public-interest data has an availability problem. Across 2025 and 2026, federal and state agencies have removed, decommissioned, paywalled, or quietly relocated datasets on water, air, and climate — the very records Colorado's environmental journalists, watchdogs, and researchers rely on. The data is public in principle but stranded in practice: scattered across a dozen agency systems, each with its own undocumented interface, and none of it guaranteed to be there next year.

What's new is that rescuing it no longer takes a dedicated engineering team. Modern AI coding assistants can generate the software that retrieves, cleans, and documents a messy public source — which means a small lab can liberate many datasets quickly and keep them alive. Over the past several weeks we used that capability to build the **Colorado Environmental Data Hub**: four parallel pipelines that pull the state's water and climate record out of the agencies that hold it and into tidy, documented, day-by-day tables. Here is how it works and where it stands.

## Four datasets, liberated

What began as a single reservoir dataset is now four built pipelines, each liberating one slice of the record:

- **Reservoir storage** — volume, pool elevation, and releases for 118 major reservoirs from Colorado's Division of Water Resources (DWR/CDSS) and the federal Bureau of Reclamation's RISE platform, plus 20 federal reservoirs.
- **Streamflow** — daily mean discharge for 33 curated major-river gages across all eight river basins, from the U.S. Geological Survey's NWIS and DWR's surface-water service, which re-serves many USGS gages and often extends them past the point where federal monitoring cut off.
- **Snowpack** — snow-water equivalent, snow depth, and water-year precipitation at 199 NRCS stations: the automated SNOTEL sites (daily since about 1980) and the manual snow courses, some with records reaching back to the 1930s and '40s.
- **Climate stations** — twelve kinds of daily observation (temperature, precipitation, snowfall, evaporation, solar radiation, and more) through a single DWR API that itself aggregates five networks (NOAA, CoCoRaHS, SNOTEL, CoAgMet, and the Northern Colorado district), seeded with 40 stations and expandable toward the full ~4,962-station catalog.

## AI-enabled liberation

Each pipeline was built by an AI assistant following two open-source "skills" the lab maintains — plain-English playbooks any coding agent can run. One scaffolds an accountable project repository; the other orchestrates the liberation itself, in four stages: retrieve, audit, clean, publish. The assistant wrote a dedicated client for each agency API, mapped the universe of stations and gages behind it, and assembled the parsing and cleaning code. Crucially, all four pipelines are thin, domain-specific packages over one shared engine — a common core that handles the work every pipeline needs (fetching, provenance, cleaning, schema, auditing) — so an improvement or fix written once lands for all four at the same time. The result is leverage: four very different sources, one maintainable codebase, built in weeks rather than months.

## Kept current, automatically

A rescue archive is only useful if it stays fresh. Each pipeline is wired into a scheduled job that rebuilds and re-audits the dataset every month, pulling the latest telemetry and re-deriving the table from scratch. Because the cleaning step de-duplicates on a stable key, a full monthly rebuild is self-healing: it picks up new readings and quietly corrects any revisions the agencies made to older ones, with no human in the loop for the routine case. The pipelines also run offline in a demo mode and exit with an error on any regression — zero rows, an empty pull, a failed reconciliation — so a silent breakage upstream surfaces as a loud failure rather than a stale file nobody notices.

## Auditable, source and code

The point of liberating data this way is that nothing has to be taken on trust. Every raw API response is saved once and untouched, alongside a provenance record — the source URL, the time it was retrieved, and a cryptographic checksum — so any number in a final table can be traced back to the exact bytes an agency served on a given day. The cleaning code reshapes incompatible source formats into one consistent table validated against a strict schema. Where two sources overlap — DWR re-serving a USGS gage, a SNOTEL site beside a manual snow course — the pipeline reconciles them automatically, and the overlap doubles as a built-in accuracy check. Each pipeline also carries a **concept catalog** documenting the caveats that quietly produce errors: reservoir elevations measured against different vertical datums, "percent of capacity" defined differently by each agency, climate units that vary by measurement type. And because the whole thing is code, the audit extends to the software itself — the pipelines, their tests, and their documentation are all open on GitHub, so a skeptical reader can check not just the data but the exact logic that produced it.

That transparency is also a brake. Publication is gated by a quality-assurance review, and a late-June audit found the reservoir output not yet ready: its reconciliation step was still a stub and the file carried some impossible values. That is exactly what the gate is for, and exactly why the first public release is on hold until the checks clear.

## Durably archived

Open code and a monthly rebuild keep the data current, but they don't make it citable or permanent — a GitHub repository can move or vanish like anything else online. So each dataset ships with a deposit kit for **Harvard Dataverse**, the scholarly data archive, which will give every release a permanent, citable DOI and a stable home independent of the lab's own infrastructure. The monthly job can prepare a deposit automatically, but by design it only ever drafts one: minting a permanent identifier always takes a human signature, and won't happen until the QA checklists clear. Dataverse is the project's planned home of record — set up, but not yet live.

## How to follow along — and help

Everything is open in the repository today: [`github.com/CUPIDS-Lab/co-environmental-data`](https://github.com/CUPIDS-Lab/co-environmental-data). You can read the documented sources and the code, and you can run any pipeline yourself — each is self-contained, installs a pinned environment, and rebuilds its dataset from the live APIs (or runs offline) in a few commands.

We are deliberately **not** yet shipping the finished tables as downloadable deliverables. They are forthcoming, behind the QA gate, with the Harvard Dataverse DOIs as their permanent home; when a dataset clears review, this Dispatch will say so. In the meantime, if you are a journalist who wants a particular series, who spots a gage or station we've missed, or who finds a number that looks wrong, that is exactly the feedback this architecture is built to use — bring it to the lab's [help desk](/get-involved/#desk).
