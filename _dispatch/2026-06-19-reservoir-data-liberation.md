---
title: "Generating code, not answers: how we liberated Colorado's reservoir records"
kind: report
issue: 2
date: 2026-06-19
authors:
  - brian-keegan
summary: "Using two open-source agent skills, we orchestrated an AI assistant to retrieve, audit, clean, and publish a century of Colorado reservoir storage from three government APIs — by writing code we could check, not interpretations we had to trust."
published: false
---

The fear about putting a large language model anywhere near data journalism is a reasonable one: these systems hallucinate. Ask a chatbot for the storage level of Blue Mesa Reservoir and it may hand you a confident, plausible, and entirely fabricated number. That failure mode is disqualifying for any newsroom whose credibility rests on being right.

But there is a different way to use the same technology — one that turns its weakness into a strength. Modern AI assistants are extraordinarily good at writing code. And code does not hallucinate. A Python function that fetches a record from a government API, parses it, and checks it against the agency's own published total either works or fails in ways you can see and test. The discipline, then, is to never let the model *interpret* the data. Let it **generate the machinery** that retrieves and cleans the data, and keep every actual value flowing through deterministic, inspectable code that a human — or another program — can audit.

Over the past month we put that principle to work on a real dataset: a complete, day-by-day history of Colorado reservoir storage, liberated from three public agencies and published as a single tidy file with a citable DOI. Here is how the orchestration worked, and where it strained.

## Two skills, composed

The work ran on two open-source "[agent skills](/projects/data-liberation/)" the lab maintains — plain-Markdown instruction sets, MIT-licensed, that any AI coding assistant (Claude Code, Copilot, Gemini) can follow. **`data-project`** stands up an accountable repository: documentation, a roadmap, a decision log, and governance sized to the project's actual sensitivity. **`data-liberation`** does the extraction: it orchestrates a four-stage pipeline — **retrieve, audit, cleanup, publish** — from a messy government source into a documented, reproducible dataset.

We used `data-project` first to build the [Colorado Environmental Data Hub](https://github.com/CUPIDS-Lab/co-environmental-data), a catalog of roughly 56 authoritative state and federal environmental data sources. Reservoir storage was the first source we chose to fully liberate. The result is visible in the repository's revision history: about two dozen pull requests to scaffold and govern the Hub, then roughly fourteen more to build and harden the reservoir pipeline itself — the large majority of them, tellingly, spent debugging live government APIs.

## Retrieve, audit, clean, publish

The reservoir data lives in three systems that do not agree with one another: Colorado's Division of Water Resources (DWR/CDSS), the federal Bureau of Reclamation's RISE platform, and Northern Water. The assistant wrote a dedicated client for each, fetched the full per-site history for 118 major reservoirs plus the federal RISE sites, and saved every raw API response **once**, untouched, alongside a provenance record — the source URL, the time it was retrieved, and a cryptographic checksum. Those originals are immutable. Everything downstream is regenerated from them, so any number in the final dataset can be traced back to the exact bytes an agency served on a given day.

The **audit** stage profiles what came back before anyone trusts it: did each source return rows? How many reservoirs? Any empty pulls? The **cleanup** stage reshapes three incompatible formats into one "tidy long" table — one row per source, reservoir, date, and variable — validated against a strict schema contract. The **publish** stage finalizes the CSV and runs a reconciliation: it compares the pipeline's numbers against each agency's *own* currently published storage totals. A mismatch beyond tolerance fails the build. This is the crux of the anti-hallucination design — the dataset is not believed because an AI produced it; it is believed because it reconciles with the source of record, automatically, every time it runs.

A small but important piece is the project's **concept catalog**, which documents the caveats that quietly produce misinformation. Reservoir *elevations*, for instance, may be reported against different vertical datums; *percent-of-capacity* depends on each agency's own definition of "full." The skill insists these be written down, and in at least one case that discipline caught an error before it became a published mistake.

The finished dataset is rebuilt and re-audited monthly by an automated workflow and can be deposited to Harvard Dataverse for a permanent, citable DOI — though, by design, the automation only ever creates a *draft*; minting a permanent identifier always requires a human to confirm.

## Where the architecture strained

Honesty about the limits is part of the method. Several are worth naming for anyone tempted to replicate this.

The APIs fought us. CDSS treats a "404" as *zero records* rather than an error, hides its value in a field called `measValue`, and demands both a start and end date or it silently returns nothing. RISE pages its results, caps them at 10,000 rows, and only reveals its full catalog through relationship traversal. None of this is in any documentation; all of it had to be discovered by probing. Our own retrospective concluded the skill's center of gravity — built for liberating PDFs and scraped pages — now lags behind a civic-data landscape that has moved behind quirky, undocumented REST APIs.

The cleaning logic bit us too. A validation rule meant to catch duplicate rows instead dropped several entire reservoirs when they reported multiple readings in a day — a reminder that a wrong granularity in an automated check fails silently and invisibly, exactly the kind of error that erodes trust. Caching raw responses, a virtue for reproducibility, became a liability when the extraction logic changed and stale files were never refreshed, leaving a partial dataset that *looked* complete. And the scaffolded instructions, written by experts, repeatedly assumed a level of expertise a student or journalist running the pipeline would not have.

None of these were catastrophic, because the architecture is built to surface them: failures are durable, not fatal; audits are loud; and the final reconciliation is a hard gate. But they are real, and they are why a human stays in the loop.

Open data is not the same as information justice. A tidy CSV does not, by itself, inform a drought response or hold a water district accountable — people and reporting do that. What this orchestration offers is narrower and, we think, durable: a way to put the speed of AI to work on the *plumbing* of data journalism while keeping every fact answerable to its source. The model writes the code. The code, and the people reading it, keep the data honest.
