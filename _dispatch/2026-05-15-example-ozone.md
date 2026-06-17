---
# EXAMPLE dispatch / template. Copy this file, fill it in, and set
# `published: true` to publish. While unpublished, the Dispatch page shows
# placeholder tiles. Each file here is one issue.
title: "What the ozone data still shows — before it's gone"
# `kind` must be one of the controlled vocabulary keys in _data/dispatch.yml;
# `issue` is the optional issue number. Together they render the tag, e.g.
# "ISSUE 03 · INVESTIGATION" — don't hand-write a `tag:` string.
kind: investigation
issue: 3
date: 2026-05-15
# `authors` are _people slugs (the filename of the person's _people doc). The
# byline links them by slug, and an unknown slug fails the build.
authors:
  - brian-keegan
summary: "We reconstructed a decade of Front Range air quality from archived EPA monitors to map who breathes the worst of Denver's ozone — and what's at stake as the data disappears."
# Reading time is estimated automatically from the body length — no field needed.
published: false
---

This is a template for a CUPIDS Dispatch issue. Write the body in Markdown — it renders on the issue's own page at `/dispatch/<this-file>/`.

## What we found

Summarize the investigation, with the data and methods linked.

## Why it matters

Connect it back to the public-interest stakes.
