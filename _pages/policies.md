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
- **No external requests.** Fonts are self-hosted and all JavaScript is first-party, so your browser doesn't call out to Google Fonts, CDNs, or other third parties that would see your IP address.
- **Open source.** The full source is public at [github.com/CUPIDS-Lab](https://github.com/CUPIDS-Lab), so anyone can verify these claims.
- **Encrypted transport.** Served over HTTPS.
- **A web form is not a secure channel.** The optional intake form, where enabled, posts to a third-party form handler. It's fine for routine requests and explicitly *not* for sensitive disclosures — see **Secure contact** on the [Get Involved](/get-involved/) page.

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

## Responsible disclosure

Found a security problem with this site or our infrastructure? Please tell us privately first via a secure channel on the [Get Involved](/get-involved/) page, and give us a reasonable window to fix it before disclosing publicly. We're grateful for the help.

*This is an initial draft policy and will evolve as the lab's infrastructure matures. Last reviewed: 2026-06.*
