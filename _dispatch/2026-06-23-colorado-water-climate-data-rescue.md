---
title: "Generating code, not answers: a rescue archive for Colorado's water and climate data"
kind: report
issue: 2
date: 2026-06-23
authors:
  - brian-keegan
summary: "What began as one reservoir dataset is now four parallel pipelines — reservoirs, streams, snow, and climate — rescuing Colorado's water and climate record from the agencies that hold it. Here's the method, the honest status, and how to follow along."
published: false
---

The fear about putting a large language model near data journalism is a reasonable one: these systems hallucinate. Ask a chatbot for the snowpack in the Gunnison basin or the storage level of Blue Mesa Reservoir and it may hand you a confident, fluent, and entirely fabricated number. For any newsroom whose credibility rests on being right, that failure mode is disqualifying.

But the same technology has a strength that points to a different way of working. Modern AI assistants are very good at writing code — and code does not hallucinate. A function that fetches a record from a government API, parses it, and checks it against the agency's own published total either works or fails in ways you can see, test, and re-run. So the discipline is simple to state and demanding to keep: never let the model *interpret* the data. Let it generate the *machinery* that retrieves and cleans the data, and keep every actual value flowing through deterministic, inspectable code that a human — or another program — can audit.

## From one dataset to four

Over the past several weeks we put that principle to work on a growing target: a reproducible archive of Colorado's environmental data, rescued from the public agencies that hold it before any more of it erodes. Since 2025, federal and state datasets on water, air, and climate have been removed, decommissioned, paywalled, or quietly moved behind logins. The lab's response is the **Colorado Environmental Data Hub**, and what began as a single reservoir dataset has grown into **four parallel pipelines**, each liberating one slice of the state's water and climate record into a tidy, documented, day-by-day table.

- **Reservoir storage** pulls volume, pool elevation, and releases for 118 major reservoirs from Colorado's Division of Water Resources (DWR/CDSS) and the federal Bureau of Reclamation's RISE platform, plus 20 federal reservoirs.
- **Streamflow** liberates daily mean discharge for 33 curated major-river gages spanning all eight of the state's river basins, from the U.S. Geological Survey's NWIS and DWR's surface-water service — which re-serves many USGS gages and often extends them past the point where federal monitoring cut off.
- **Snowpack** reaches the federal NRCS network for snow-water equivalent, snow depth, and water-year precipitation at 199 stations — both the automated SNOTEL sites (daily since about 1980) and the manual snow courses, some of whose records reach back to the 1930s and '40s.
- **Climate stations** federate twelve kinds of daily observation — temperature, precipitation, snowfall, evaporation, solar radiation, and more — through a single DWR API that itself aggregates five networks (NOAA, CoCoRaHS, SNOTEL, CoAgMet, and the Northern Colorado district), with a 40-station seed that can expand toward the full ~4,962-station catalog.

All four are built. And, importantly for the cost of keeping them alive, all four are thin domain-specific packages sitting on top of one shared engine — a common core that handles the parts every pipeline needs (fetching, provenance, cleaning, schema, and auditing), so a fix written once lands for all four at the same time.

## How it works

Each pipeline runs the same four stages: **retrieve, audit, cleanup, publish.** The retrieve stage fetches every raw API response once and saves it untouched, alongside a provenance record — the source URL, the time of retrieval, and a cryptographic checksum — so any number downstream can be traced to the exact bytes an agency served on a given day. The audit stage profiles what came back before anyone trusts it: how many stations, how many rows, any empty pulls. The cleanup stage reshapes incompatible source formats into one "tidy long" table, validated against a strict schema. The publish stage finalizes the file and reconciles it.

That reconciliation is the heart of the anti-hallucination design. Where two sources overlap — DWR re-serving a USGS gage, a SNOTEL site sitting beside a manual snow course — the pipeline compares them automatically, and the overlap doubles as a built-in accuracy check. Just as important is each pipeline's **concept catalog**, which writes down the caveats that quietly produce misinformation: reservoir elevations reported against different vertical datums, "percent of capacity" defined differently by each agency, SNOTEL and snow-course sites that are nearby but not identical, climate units that differ by measurement type. A number is trusted not because an AI produced it, but because it reconciles with the source of record and carries its caveats with it.

## The honest status

None of this is finished, and the honest status matters more than the announcement. The data is built and reproducible, but it is not yet *published* — because publication is gated by quality assurance. A QA audit in late June found the reservoir output not yet ready: its reconciliation step was still a stub, and the file carried some impossible values. That is exactly the kind of error the gate exists to catch, and exactly why the first public deposit is on hold. Each pipeline ships a deposit kit for **Harvard Dataverse**, which will give every dataset a permanent, citable DOI, and a monthly automated job rebuilds and re-audits the data — but by design that automation only ever *drafts* a deposit. Minting a permanent identifier always takes a human signature, and it won't happen until the QA checklists clear.

The APIs themselves remain the hard part. Colorado's CDSS treats a "404" as *zero records* rather than an error and hides its value in an oddly named field; Reclamation's RISE caps and paginates its results and only reveals its full catalog through indirect traversal; the climate API effectively requires a key or it silently throttles you. None of this is documented; all of it had to be discovered by probing. And a tidy CSV is not, by itself, accountability — open data is not the same as information justice. A dataset does not inform a drought response or check a water district; reporters and the public do that. What the architecture offers is narrower and, we think, durable: the speed of AI applied to the plumbing, with every fact kept answerable to its source.

## How to follow along — and help

Everything is open and in the repository today: [`github.com/CUPIDS-Lab/co-environmental-data`](https://github.com/CUPIDS-Lab/co-environmental-data). You can read the documented sources, and you can run any pipeline yourself — each is self-contained, installs a pinned environment, and will rebuild its dataset from the live APIs (or run offline in a demo mode) in a few commands.

We are deliberately **not** yet shipping the finished tables as downloadable deliverables. They are forthcoming, behind the QA gate, with the Harvard Dataverse DOIs as their planned permanent home; when a dataset clears review, this Dispatch will say so. In the meantime, if you are a journalist who wants a particular series, who spots a gage or station we've missed, or who finds a number that looks wrong, that is precisely the feedback the reconciliation gate is built to use — bring it to the lab's [help desk](/get-involved/#desk). The model writes the code. The code, the audits, and the people reading them keep the data honest.
