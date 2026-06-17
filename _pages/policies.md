---
layout: detail
permalink: /policies/
eyebrow: Policies
title: "Security, independence & source protection"
summary: "How this site is built — and how our disclosure infrastructure is kept separate from university systems — to protect the people who trust us with data."
---

## Why you don't have to take our word for it

A leak shouldn't require blind faith. So everything on this page is concrete and verifiable — how the site is built, what we will and won't do, and exactly where the limits are — checkable against [our open source](https://github.com/CUPIDS-Lab) rather than simply asserted.

And you aren't handing material to an anonymous form. CUPIDS is a *named*, accountable lab at CU Boulder with a public-interest mission: training students to preserve at-risk public data and to back the journalists, lawyers, and nonprofits who hold power to account. That work collapses if the people who come to us aren't safe — so protecting them is a design requirement here, not a footnote. Our incentives are to protect you, our methods are open to inspection, and where we can't promise something, we say so plainly below.

## Security by design

This website is deliberately minimal and auditable:

- **Static, server-less.** It's a static [Jekyll](https://jekyllrb.com) build served by GitHub Pages — no application server, database, or session store collecting visitor data.
- **No third-party tracking.** No analytics, advertising, social, or A/B-testing scripts; no tracking cookies or fingerprinting.
- **No third-party requests on page load.** Fonts are self-hosted and all JavaScript is first-party, so simply visiting the site doesn't call out to Google Fonts, CDNs, analytics, or other third parties that would see your IP address. (The one time data leaves to a third party is when *you* submit a form — see below.)
- **Open source.** The full source is public at [github.com/CUPIDS-Lab](https://github.com/CUPIDS-Lab), so anyone can verify these claims.
- **Encrypted transport.** Served over HTTPS.
- **A web form is not a secure channel.** Our intake and newsletter forms submit to [**Formspree**](https://formspree.io), a third-party form processor — your message and whatever you put in it are transmitted to and stored by Formspree under [its own privacy policy](https://formspree.io/legal/privacy-policy/), then emailed to us. That's fine for routine, non-sensitive requests; it is explicitly **not** for confidential sources, privileged material, or anything you need kept off third-party servers. For those, use **Secure contact** on the [Get Involved](/get-involved/) page.

## Built with AI — and accountable for it

We ask others to disclose how their tools work, so we disclose how this site is made. CUPIDS was **designed and built with AI assistance** — a combination of Claude Design (initial design exploration) and Claude Code (implementation) — and we continue to use AI tools to help maintain and extend it.

- **People are accountable, not the model.** AI assists; named members of the lab review, approve, and answer for everything that ships. Nothing reaches the site without human review.
- **Auditable in the open.** Because the [full source is public](https://github.com/CUPIDS-Lab), our use of AI is verifiable in the commit history rather than merely asserted — every change is attributable and reviewable, including the ones AI helped write.
- **No reader data feeds any model.** The static build above collects nothing about visitors, and we send nothing about you to any AI service. AI helps us *write the site*; it is never used to watch the people who read it.

## Our disclosure infrastructure stays off CU IT

CUPIDS is based at the University of Colorado, but the infrastructure we use to receive sensitive material and to communicate with sources is **kept deliberately separate from University of Colorado IT systems.**

- Secure channels — Signal, PGP-encrypted email on non-university keys, and our secure file drop — do **not** run on CU-operated servers, accounts, or networks.
- This site is hosted independently (GitHub Pages), not on university infrastructure.
- We avoid routing confidential source communications through university email, storage, or logging, which can be subject to institutional retention, monitoring, or legal process outside our control.

The goal is simple: people who help us hold power to account should not have their identity or materials exposed by the systems of any single institution — including our own. (Some routine, non-sensitive contact still uses university addresses; for anything sensitive, use the dedicated secure channels.)

## Protecting sources & whistleblowers

- **Data minimization.** We ask for only what we need and encourage you to share only what's necessary. Don't send identifying details you don't have to.
- **Use protected channels.** For sensitive material, reach us via Signal or our secure file drop rather than email or web forms. Consider using Tor and a device or account not tied to your identity or employer.
- **We don't unmask sources.** We will not voluntarily disclose the identity of a source or the existence of a confidential contact, and we will resist improper or overbroad demands to the fullest extent we are able.
- **Retention.** Sensitive materials are stored encrypted, access is limited to the people doing the work, and we delete what we no longer need.

## What we can — and can't — promise

We're a public-interest research lab, not a law firm, and this infrastructure is actively being built out. We'd rather be honest about the limits:

- No system is perfectly secure and no promise of anonymity is absolute — your own operational security matters.
- We cannot offer legal privilege, and we can't guarantee protection against every legal or technical adversary.
- Where a channel above says "on request" or "to be configured," it is still being stood up. Ask us for current, verified contact details before sending anything sensitive.

## Responsible AI in the tools we build

Preserving and analyzing public records increasingly means using AI — to read documents at scale, classify and cluster records, and search large corpora. We hold the tools we build, evaluate, and recommend to the same public-interest standard as the rest of our work, and we put the limits up front rather than burying them.

- **Models are instruments that need calibration.** We sample for accuracy, measure and report error rates, and document intended use and limits with [Model Cards](https://arxiv.org/abs/1810.03993), guided by the [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework). See our [evaluated tooling](/resources/evaluated-tooling/) for how we test a tool before we rely on — or recommend — it.
- **Humans stay in the loop.** AI output is a lead, not a finding. People verify before anything is published or relied on — especially in journalism, where a confident, wrong machine answer is a liability.
- **Sensitive material stays off third-party AI.** We do not paste confidential source material, privileged documents, or anything sent through a secure channel into external AI services that would transmit, store, or train on it.
- **No AI surveillance of sources.** We do not use AI to de-anonymize, re-identify, or profile sources, whistleblowers, or the people who appear in the records we handle.

## Responsible disclosure

Found a security problem with this site or our infrastructure? Please tell us privately first via a secure channel on the [Get Involved](/get-involved/) page, and give us a reasonable window to fix it before disclosing publicly. We're grateful for the help.

*This is an initial draft policy and will evolve as the lab's infrastructure matures. Last reviewed: 2026-06.*
