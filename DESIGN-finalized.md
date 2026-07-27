# Liberated Bread — Design Document (Final)

> **Status:** Convergence draft — all planner disagreements resolved.
> **Date:** 2026-07-25
> **Key:** `[DECISION]` = resolved and locked; `[OPEN]` = still needs user input.

---

## Table of Contents

1. [Project Core Philosophy](#1-project-core-philosophy)
2. [Our Incentives](#2-our-incentives)
3. [Brand & Visual Identity](#3-brand--visual-identity)
4. [Repository Structure](#4-repository-structure)
5. [Technical Architecture](#5-technical-architecture)
6. [Deployment & Infrastructure](#6-deployment--infrastructure)
7. [Domain & DNS Layout](#7-domain--dns-layout)
8. [Django Backend Design](#8-django-backend-design)
9. [Static Frontend Design](#9-static-frontend-design)
    9.6 [Coming Soon Landing Page (Phase 0)](#96-coming-soon-landing-page-phase-0)
10. [Device Page Templates & Safety](#10-device-page-templates--safety)
11. [Configurable Device Pack System](#11-configurable-device-pack-system)
12. [Video Content Strategy](#12-video-content-strategy)
13. [3D Files & Git LFS Workflow](#13-3d-files--git-lfs-workflow)
14. [Website Prompt Blueprints](#14-website-prompt-blueprints)
15. [Security & Privacy](#15-security--privacy)
16. [Testing Strategy](#16-testing-strategy)
17. [Content Moderation & Legal](#17-content-moderation--legal)
18. [Contribution Pipeline](#18-contribution-pipeline)
19. [Community & Support](#19-community--support)
20. [Making Money (Maybe)](#20-making-money-maybe)
21. [Future Roadmap](#21-future-roadmap)
22. [Appendix A: Color Palette](#22-appendix-a-color-palette)
23. [Appendix B: Device Index Schema](#23-appendix-b-device-index-schema)
24. [Appendix C: Contribution Checklist](#24-appendix-c-contribution-checklist)
25. [Appendix D: Device Pack YAML Spec](#25-appendix-d-device-pack-yaml-spec)

---

## 1. Project Core Philosophy

Liberated Bread is a hands-on, community-driven effort to reclaim abandoned and "enshittified" IoT devices. The name is an homage to Cory Doctorow's novella *Unauthorized Bread*, where refugees jailbreak locked-down appliances to cook and survive.

**The Ethos:** "You own your own devices." It champions the concept of the **Human Centaur** — where technology is a tool chosen by humans to empower themselves — rather than a *Reverse Centaur*, where humans are conscripted to serve a machine or a corporate cloud API.

**The Vibe:** "Tactical Bakery" — warm amber bread-crust accents on a dark navy tactical background. Pragmatic, anti-corporate, retro-revolutionary, and highly tactical. The identity comes directly from the `bread.png` logo's pixel colors.

**Core Principles:**
- **Local-first:** Devices work on LAN without phoning home.
- **Documented, not obfuscated:** Every guide includes rationale, not just copy-paste commands.
- **Safety-first:** Hardware guides begin with de-energize/unplug. Mains-voltage warnings are mandatory.
- **Fail-safe:** Instructions are reversible where possible; warnings where not.
- **Community-driven:** Device pages are contributed by people who own the hardware.
- **Extensible:** Users can add support for unsupported devices via configurable device packs.

---

## 2. Our Incentives

Liberated Bread is a project by **Pigs Can Fly Labs LLC** — a small business, not a non-profit. We're not raising money or shooting for venture scale. Our incentives are simple:

1. **Do some cool shit.** Jailbreaking abandoned IoT devices is genuinely interesting engineering work, and we want to share what we learn.
2. **Keep ourselves out of too much trouble.** We're not lawyers. We write guides for hardware people already own. We're transparent about what we do and don't endorse.
3. **Maybe sell some devices.** If the project gains traction, we hope to sell ESP32-S3 voice satellites and maybe earn some affiliate commissions. We'd like to make money — that's why it's a business — but we're not betting the farm on it.

**[DECISION]** The content is and always will be free (open-source guides, no paywall, no premium tier). Operating costs (domain, cluster, LFS bandwidth) come out of pocket until the project sustains itself. If you want to throw a few bucks our way, Holden has a GitHub Sponsors link. Any affiliate links are clearly disclosed. The footer says something like: *"Liberated Bread is free. Some links may earn us a small commission — we'll tell you when they do."*

---

## 3. Brand & Visual Identity

**Logo source:** `bread.png` — 128×128 PNG with a stylized bread loaf.

### 3.1 Actual Pixel Colors (extracted from bread.png)

**[DECISION] Infer colors from the logo.** The logo (`bread.png`) is the source of truth for the brand palette. Rather than pinning specific hex values that may go stale when the logo is updated, the design system derives its colors from the logo at build time. CSS custom properties (`--bread-base`, `--bread-accent`, `--bread-sky`) are generated from the current logo file and consumed by Tailwind.

### 3.2 "Tactical Bakery" Identity

| Element | Identity | Guidance |
|---|---|---|
| **Dark base** | Tactical / terminal | Dark background derived from logo's darkest tone — not generic black |
| **Primary accent** | Warm / bakery | Warm tone from the bread/crust for links, buttons, headings |
| **Secondary accent** | Technical / cool | Cool tone from the logo background for code blocks, terminal elements |
| **Typography voice** | Bakery warmth | System serif for headings. Monospace for code/terminal blocks. System sans-serif for body. |

### 3.3 Design Tokens

Define `bread.*` color tokens as CSS custom properties consumed by Tailwind:

```css
:root {
  --bread-base:    /* sampled from logo darkest tone */;
  --bread-accent:  /* sampled from bread/crust tone */;
  --bread-sky:     /* sampled from logo background tone */;
}
```

```js
// tailwind.config.js
colors: {
  bread: {
    base:    'var(--bread-base)',
    accent:  'var(--bread-accent)',
    sky:     'var(--bread-sky)',
  }
}
```

Updating the logo means updating one color source — not searching the entire codebase.

---

## 4. Repository Structure

Two repositories under the `liberatedbread` GitHub organization:

```
liberatedbread/
├── liberatedbread-web-static     ← Static frontend (GitHub Pages via Jekyll)
├── liberatedbread-web-django     ← Django backend (dockerized, Kubernetes)
└── liberatedbread-3d-files       ← 3D models with Git LFS
```

| Repository | GitHub Pages? | Git LFS? | Deployment |
|---|---|---|---|
| `liberatedbread-web-static` | Yes — serves apex + www | No | Push to `main` = Jekyll builds and deploys |
| `liberatedbread-3d-files` | No | **Yes** (versioning only) | Distributed via GitHub Releases (no LFS bandwidth cap) |

**Home Assistant plugins:** YAML configs and PyWeMo override scripts live in `liberatedbread-web-static` under `/ha-plugins/`. [DECISION] No separate repo — these are small config files.

### 4.1 Data Source: opengreeniot-protocol-docs

Device pages draw protocol data from [opengreeniot-protocol-docs](https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs), a separate repository that contains:

- Machine-readable device specs in `device-specs/devices/*.yaml` (validated against `schema.json`)
- Per-device protocol documentation in `docs/devices/*.md`
- Discovery and reverse-engineering guides
- A generated JSON API (`site/api/v1/manifest.json` + per-device JSON)

Liberated Bread links to opengreeniot-protocol-docs as the authoritative protocol reference. The Liberated Bread device pages focus on the **user-facing liberation guide** (steps, safety, tools, troubleshooting) while opengreeniot-protocol-docs focuses on the **machine-readable protocol specification** (GATT services, characteristics, commands, HA entities).

---

## 5. Technical Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     END USERS                             │
│         Browsers, RSS readers, git clones                 │
└──────────────────────┬───────────────────────────────────┘
                       │
     ┌─────────────────┴──────────────────┐
     │  GitHub Pages                       │
     │  (Jekyll, push=deploy)              │
     │                                     │
     │  Serves:                            │
     │  liberatedbread.com                 │
     │  www.liberatedbread.com             │
     │                                     │
     │  Static assets:                     │
     │  • Markdown → HTML                  │
     │  • Device pages                     │
     │  • HA configs                       │
     │  • Images                           │
     │                                     │
     │  Plain <form> POST ────────────────►│
     │  (no JS required)                   │
     │                                     │
     └─────────────────────────────────────┘
                       │
                       │  HTTPS POST
                       ▼
     ┌─────────────────────────────────────┐
     │  PigsCanFly.ca (pcfweb)             │
     │                                     │
     │  POST /mailing-list/subscribe       │
     │  Fields: email, interest, name      │
     │  Honeypot: website                  │
     │  CSRF-exempt (by design)            │
     │  Rate-limited                       │
     │  Redirect: ?next=liberatedbread.com │
     │                                     │
     │  Liberated Bread has its own        │
     │  InterestArea ("liberatedbread")    │
     │  in pcfweb's mailing list system.   │
     └─────────────────────────────────────┘
                       │
     ┌─────────────────┴──────────────────┐
     │  GitHub Raw CDN                     │
     │  (liberatedbread-3d-files)          │
     │  Serves: .stl, .3mf                 │
     └─────────────────────────────────────┘
```

### 5.1 Key Architectural Decisions

1. **[DECISION] Static-only site. No dedicated backend.** Liberated Bread is a 100% static Jekyll site on GitHub Pages. There is no Django backend, no Kubernetes namespace, and no PostgreSQL cluster for Liberated Bread itself. All dynamic functionality (newsletter subscriptions, contact forms) delegates to pcfweb's existing infrastructure.

2. **[DECISION] Subscriptions via pcfweb mailing list.** The site's subscribe forms POST directly to `https://www.pigscanfly.ca/mailing-list/subscribe` with `interest=liberatedbread`. pcfweb's `MailingListSubscribeView` is `@csrf_exempt` by design — it accepts cross-origin form posts with no session dependency. Protection comes from rate limiting + a honeypot field (`website`). Subscribers get a confirmation email. The `?next=` parameter sends them back to `liberatedbread.com/thanks/` after signup.

3. **[DECISION] UPnP is local-only.** Nothing server-side. UPnP and network discovery live in Home Assistant integrations and the future `liberatedbread-cli` local tool.

4. **[DECISION] Cloudflare DNS-only for GitHub Pages.** No Cloudflare proxying (grey cloud). GitHub Pages handles its own TLS via Let's Encrypt. No dynamic subdomain exists, so there's nothing to proxy.

---

## 6. Deployment & Infrastructure

### 6.1 Static Site (GitHub Pages + Jekyll)

**[DECISION] Jekyll** — zero-config on GitHub Pages. Native markdown + front-matter. No CI build step needed for deployment.

**Repository structure:**

```
liberatedbread-web-static/
├── _config.yml                 ← Jekyll config
├── _layouts/
│   ├── default.html            ← Common page shell
│   └── device.html             ← Device page layout
├── _includes/
│   ├── header.html
│   ├── footer.html
│   ├── safety-block.html       ← Mandatory safety callout
│   └── device-card.html        ← Device grid card component
├── _data/
│   └── devices.yml             ← Device catalog (see Appendix B)
├── _devices/                   ← Jekyll collection: device pages
│   ├── wemo-switch.md
│   ├── eufy-mount.md
│   └── ...
├── assets/
│   ├── tailwind.css            ← Pre-built, purged, committed
│   ├── main.js
│   ├── logo.png
│   ├── favicon.ico
│   └── devices/                ← Device-specific images
├── ha-plugins/                 ← Home Assistant YAML configs
├── contribute/
│   ├── index.md                ← CONTRIBUTING guide
│   └── device-template.md      ← Template for new device pages
├── thanks.md                   ← Post-form redirect landing
├── about.md
├── disclaimer.md
└── index.md                    ← Landing page (front matter + HTML)
```

**CSS Build Pipeline:**

```bash
# Development (rapid iteration):
# Use Tailwind CDN in _layouts/default.html during local dev

# Production (committed to repo):
npx tailwindcss -i ./src/input.css -o ./assets/tailwind.css --minify
```

[DECISION] Production uses pre-built, purged Tailwind CSS committed to the repo. CI verifies it's up to date. No CDN dependency in production.

**Jekyll `_config.yml`:**

```yaml
title: Liberated Bread
description: Reclaim your household hardware.
url: https://liberatedbread.com
collections:
  devices:
    output: true
    permalink: /devices/:slug/
defaults:
  - scope:
      path: ""
      type: "devices"
    values:
      layout: device
```

### 6.2 DNS & TLS

**[DECISION]** Cloudflare DNS-only (grey cloud) for all Liberated Bread records. GitHub Pages handles TLS automatically via Let's Encrypt. No Cloudflare proxy, no custom TLS configuration needed.

```
liberatedbread.com.     CNAME  liberatedbread.github.io.
www.liberatedbread.com. CNAME  liberatedbread.github.io.
```

**GitHub Pages custom domain setup:**

1. In the `liberatedbread-web-static` repo: Settings → Pages → Custom domain → `liberatedbread.com`
2. Check "Enforce HTTPS"
3. GitHub provisions a Let's Encrypt certificate automatically
4. DNS records are set in Cloudflare (grey cloud / DNS-only)

That's it. No Kubernetes, no ingress controllers, no cert-manager. TLS and CDN are handled entirely by GitHub Pages.

### 6.3 pcfweb Mailing List Integration

The one dynamic dependency is the newsletter subscribe form. Liberated Bread does not run its own Django backend for this — it delegates to pcfweb's mailing list system.

**Setup required on pcfweb:**
1. Create an `InterestArea` with slug `liberatedbread` and name "Liberated Bread"
2. The `MailingListSubscribeView` at `/mailing-list/subscribe` already accepts cross-origin form posts
3. Add `liberatedbread.com` to the `MAILING_LIST_ALLOWED_NEXT_HOSTS` allowlist so the `?next=` redirect works

**Form submission flow:**
1. Visitor fills in email on `liberatedbread.com`
2. Form POSTs to `https://www.pigscanfly.ca/mailing-list/subscribe` with:
   - `email` (required)
   - `interest=liberatedbread`
   - `name` (optional, not collected on the coming-soon page)
   - `website` (honeypot — hidden, bots fill it in)
   - `next=https://liberatedbread.com/thanks/` (redirect after signup)
3. pcfweb records a PENDING subscription and sends a confirmation email
4. Visitor clicks the confirmation link → SUBSCRIBED
5. Visitor is redirected back to `/thanks/` on Liberated Bread

**Why this works:**
- pcfweb already has the mailing list infrastructure (PR #22)
- CSRF exemption is intentional and documented — no session/credential dependency
- Honeypot field catches bots silently
- Rate limiting prevents abuse
- Confirmation email ensures real addresses
- No additional infrastructure to maintain

---

## 7. Domain & DNS Layout## 7. Domain & DNS Layout

| Subdomain | Serves | Cloudflare Mode | TLS |
|---|---|---|---|
| `liberatedbread.com` (apex) | Static site (GitHub Pages) | **DNS-only** (grey cloud) | GitHub Pages auto |
| `www.liberatedbread.com` | Static site (GitHub Pages) | **DNS-only** (grey cloud) | GitHub Pages auto |
| `dynamic.liberatedbread.com` | N/A | N/A | No dedicated backend — subscriptions via pcfweb |

**[DECISION]** Cloudflare proxied only in front of the Django backend. GitHub Pages handles its own CDN and TLS — double-proxying through Cloudflare adds no value and creates TLS termination issues.

---

## 8. Backend Integration (pcfweb)

Liberated Bread has **no dedicated backend**. All dynamic functionality is delegated to pcfweb (Pigs Can Fly Labs' main site), which already runs a Django application with a mailing list system (see [pcfweb PR #22](https://github.com/PigsCanFlyLabs/pcfweb/pull/22)).

### 8.1 What pcfweb provides

| Feature | pcfweb Endpoint | Notes |
|---|---|---|
| Newsletter subscribe | `POST /mailing-list/subscribe` | CSRF-exempt, rate-limited, honeypot-protected |
| Email confirmation | `GET /mailing-list/confirm/<token>` | Token-based double opt-in |
| Unsubscribe | `GET /mailing-list/unsubscribe/<token>` | One-click, RFC 8058 compliant |
| Admin import/export | `/timbit/admin/mailing-list/import` | CSV import with column detection |
| Bulk sending | `/timbit/admin/mailing-list/send/<id>` | Per-interest-area targeting |
| Embed form | `/mailing-list/embed/<slug>` | iframe-friendly signup for external sites |

### 8.2 InterestArea Setup

pcfweb's mailing list organizes subscribers by `InterestArea`. For Liberated Bread:

```python
# Run once in pcfweb's Django shell or admin:
from mailing_list.models import InterestArea
InterestArea.objects.create(
    slug="liberatedbread",
    name="Liberated Bread",
    description="Reclaim your household hardware — IoT device liberation guides",
    active=True,
)
```

After setup, `interest=liberatedbread` in the subscribe form routes subscribers to the correct group.

### 8.3 Allowed Redirect Hosts

Add `liberatedbread.com` to pcfweb's `MAILING_LIST_ALLOWED_NEXT_HOSTS` setting so the `?next=` parameter can redirect subscribers back after signup.

### 8.4 What Liberated Bread does NOT need

- ❌ No Django project
- ❌ No PostgreSQL database
- ❌ No Kubernetes namespace
- ❌ No `dynamic.liberatedbread.com` subdomain
- ❌ No Stripe integration (deferred to Phase 3+)
- ❌ No contact form backend (can be added to pcfweb later if needed)

---

## 9. Static Frontend Design## 9. Static Frontend Design

### 9.1 Technology Stack

| Layer | Choice | Rationale |
|---|---|---|
| SSG | **Jekyll** | Zero-config on GitHub Pages, native markdown + front-matter, collections for device pages |
| CSS | Tailwind CLI build (committed) | Production: purged & minified. Dev: CDN for rapid iteration. |
| JS | Vanilla JavaScript | Only toggles, filters, form enhancement. Every path works without JS. |
| Templating | Jekyll Liquid + includes | Shared header/footer/safety-block via `_includes/` |
| Device data | `_data/devices.yml` | Drives device grid and /devices/ index |

### 9.2 Site Map

```
liberatedbread.com/
├── /                          ← Coming soon teaser + subscribe form (Phase 0)
├── /devices/                  ← Device index (from _data/devices.yml)
│   ├── /devices/wemo-switch/  ← Markdown device page (Jekyll collection)
│   ├── /devices/eufy-mount/   ← Markdown device page
│   └── ...                    ← One .md per device in _devices/
├── /ha-plugins/               ← Home Assistant YAML configs
├── /about/                    ← About Pigs Can Fly Labs + social links
├── /contribute/               ← How to add a device
├── /thanks/                   ← Post-form redirect landing
├── /disclaimer/               ← Legal disclaimers
├── /feed.xml                  ← RSS feed: newly freed devices + updates
└── /rss/                      ← Redirect to feed.xml (friendly URL)
```

### 9.3 Device Page Rendering Pipeline

```
opengreeniot-protocol-docs (upstream data)
    │
    ├── device-specs/devices/*.yaml  ← Machine-readable protocol specs
    └── docs/devices/*.md            ← Protocol documentation
                │
                ▼
    Liberated Bread _devices/*.md    ← User-facing liberation guides
    (Jekyll collection, front-matter + markdown)
                │
                ▼
    Jekyll build → static HTML
    (_layouts/device.html applies shell, header, footer, safety block)
                │
                ▼
    GitHub Pages (liberatedbread.com/devices/<slug>/)
```

### 9.4 No-JS Fallbacks

All interactive elements work without JavaScript:

| Feature | No-JS behavior |
|---|---|
| Mobile menu | `<noscript>` shows all nav links inline |
| Device filter | All cards rendered in DOM; filter is progressive enhancement |
| Newsletter form | Plain `<form>` POST with server redirect |
| Theme toggle | Dark mode only at launch; no toggle needed |

### 9.5 Tailwind CSS Build

```bash
# src/input.css
@import "tailwindcss";
@config "./tailwind.config.js";

# Build for production:
npx @tailwindcss/cli -i ./src/input.css -o ./assets/tailwind.css --minify
```

CI verifies `assets/tailwind.css` is up-to-date against `src/input.css`.

---

### 9.6 Coming Soon Landing Page (Phase 0)

**[DECISION]** The initial launch deploys a minimal "coming soon" teaser at the root (`/`). All other pages (device guides, about, contribute, RSS, etc.) exist and are fully built. The root page is a single-purpose teaser with no device grid, no 3-step plan, and no content beyond identity + subscribe.

**Why Phase 0 first:**
- Gets the site live immediately — domain, DNS, TLS, CI/CD all validated
- Builds the newsletter list before the full content launch
- Proves the static→Django subscription pipeline end-to-end
- Lets us iterate on the design with real traffic before committing to the full landing page layout

**What's on the page:**
1. Logo (bread.png, 96×96)
2. "Liberated Bread" — serif heading, amber accent
3. Tagline: "Reclaim your household hardware. Coming soon."
4. One-sentence description: "Step-by-step guides for liberating abandoned IoT devices from dead cloud services."
5. **Email subscribe form** — single input + button, POST to `https://www.pigscanfly.ca/mailing-list/subscribe` with `interest=liberatedbread`, honeypot field, no JS required
6. Social links row: GitHub · Discord · RSS · Mastodon · YouTube
7. Footer: PCF Labs LLC, disclaimer, affiliate disclosure

**What's NOT on the page:**
- No device grid
- No 3-step plan
- No "How it works" section
- No blog-like content
- No navigation bar (links are inline in footer/social row)

**When Phase 0 ends:** When the device catalog reaches 5+ guides and the full landing page design (Prompt B, §14.2) is validated, replace `index.md` with the full landing page. The subscribe form stays in both versions.

**RSS note:** The coming soon page links to `/feed.xml` even if the feed is initially empty — Jekyll generates a valid but empty feed, and readers will get content when the first device pages land.

---

## 10. Device Page Templates & Safety

### 10.1 Mandatory Safety Block

**[DECISION]** Every hardware device page includes a mandatory safety callout as the first content block. This is enforced by the `_layouts/device.html` template and the PR checklist.

```html
<!-- _includes/safety-block.html -->
<div class="safety-block" role="alert">
  <h2>⚠️ Safety First</h2>
  <ol>
    <li><strong>DE-ENERGIZE:</strong> Unplug the device from mains power
        before any disassembly. For battery-powered devices, remove the
        battery.</li>
    <li><strong>MAINS VOLTAGE:</strong> If the device plugs into a wall
        outlet, mains voltage may be present even when the device appears
        "off." Capacitors can retain charge after unplugging.</li>
    <li><strong>TOOLS:</strong> Use insulated tools when working near
        exposed circuitry.</li>
    <li><strong>WORKSPACE:</strong> Work on a non-conductive surface in a
        well-lit area.</li>
  </ol>
  <p>This guide assumes basic electronics safety knowledge. If you are
     unsure about any step, consult someone with experience before
     proceeding.</p>
</div>
```

**When the safety block appears:**
- **Hardware-liberated devices:** Always — these involve physical disassembly.
- **Software-liberated devices:** Conditional — only if the guide involves physical access (e.g., pressing a reset button on the PCB). Pure router-config guides (like WeMo WAN blocking) do not need it.

**Wemo-specific:** WeMo devices are software-liberation first (router-level WAN blocking + Home Assistant via PyWeMo). The software guide does not need the safety block. However, the device page includes a link to an **ESP32 hardware replacement technique** for users who want to go further. That linked page carries the full safety block.

### 10.2 Device Page Front-Matter

Every device page is a Jekyll collection document with front-matter:

```yaml
---
layout: device
slug: wemo-switch
title: "Liberate Your Belkin WeMo Insight Switch"
device_name: "Belkin WeMo Insight Switch"
model: "F7C029"
type: software          # "software" or "hardware"
difficulty: 1           # 1, 2, or 3
time_minutes: 15
firmware: "WeMo_WW_2.00.11426.PVT-OWRT-SNS"
last_verified: 2026-07-25
ha_integration: pywemo
safety_block: false     # true for hardware guides
tags: [wemo, belkin, smart-plug, wifi]
video_embed:            # Optional
  platform: youtube     # "youtube" or "peertube"
  id: "dQw4w9WgXcQ"
  title: "WeMo Liberation Walkthrough"
affiliate_tools: []     # Only populated when Associates account is active
opengreeniot_spec: "https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/device-specs/devices/wemo-devices.yaml"
opengreeniot_docs: "https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/docs/devices/wemo-devices.md"
---
```

### 10.3 Standard Device Page Sections

**Software-liberated devices:**
1. Metadata bar (model, firmware, difficulty, time, last verified)
2. **Safety block** (if applicable)
3. What You're Liberating From
4. Prerequisites
5. Step 1: Lock It Down (router config)
6. Step 2: Adopt It Locally (Home Assistant)
7. Step 3: Verify (offline operation test)
8. Troubleshooting
9. **Video walkthrough** (if available — see §12)
10. Protocol reference → opengreeniot-protocol-docs
11. Liberation Tools (affiliate links, when active)

**Hardware-liberated devices:**
1. Metadata bar
2. **⚠️ Mandatory safety block**
3. What You're Building
4. Parts List (with sourcing links)
5. 3D Printed Parts (with local backup download buttons)
6. Step 0: De-energize / Unplug
7. Assembly Guide (numbered steps with photos)
8. Wiring Diagram (if applicable)
9. **Video walkthrough** (if available)
10. Troubleshooting
11. Protocol reference → opengreeniot-protocol-docs
12. Liberation Tools

---

## 11. Configurable Device Pack System

**[DECISION]** For devices the project cannot officially support (legal, regional, or resource constraints), users may create and share their own **device packs** — YAML files following the opengreeniot-protocol-docs schema. These packs are community-contributed, not hosted in the main repositories.

### 11.1 Philosophy

> "We may not be able to officially support some devices, but you can add configurable packs to enable more devices following our YAML spec — for devices you have permission to work with."

This system separates the **curated, officially-supported** device guides (in `_devices/`) from **community-contributed device packs** that users create and share independently. It allows the project to cover more devices without taking on legal or quality-assurance responsibility for every one.

### 11.2 Device Pack Format

Device packs follow the [opengreeniot-protocol-docs schema](https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/device-specs/schema.json). A pack is a single YAML file describing a device's protocol.

```yaml
# my-wemo-alternative.yaml
# A community device pack for a Wemo variant not in the official catalog.
# This pack is for devices you have permission to work with.
#
# License: CC BY-SA 4.0
# Author: @community-user
# Compatible with: Liberated Bread device pack loader v1

device:
  name: "Wemo Custom Firmware Variant"
  manufacturer: "Belkin"
  manufacturer_status: "shutdown"
  protocol: "wifi"
  identification:
    ssdp:
      search_targets:
        - "urn:Belkin:device:custom:1"
  notes: >
    This pack covers a rare Wemo variant with custom firmware.
    Use only on your own hardware.

http_endpoints:
  - method: "POST"
    path: "/upnp/control/basicevent1"
    name: "SetBinaryState"
    # ... protocol details following the opengreeniot schema

entities:
  - platform: "switch"
    name: "Custom Wemo Switch"
    # ... Home Assistant entity mapping
```

### 11.3 How Packs Work

1. A community member reverse-engineers a device not in the official catalog
2. They create a YAML file following the opengreeniot schema
3. They share the pack (GitHub Gist, personal repo, forum post)
4. Other users download the pack and place it in their Home Assistant `custom_components/liberatedbread/packs/` directory
5. The Liberated Bread HA integration or local CLI tool loads the pack and applies the protocol
6. The device guide on the Liberated Bread site links to the community pack as an "unofficial extension"

### 11.4 Pack Directory Convention

```
liberatedbread-packs/          ← Community-maintained, NOT in the main repo
├── README.md                  ← Pack index and usage instructions
├── schema.json                ← Copy of opengreeniot schema for validation
└── packs/
    ├── wemo-custom.yaml
    ├── dyson-tp04.yaml
    └── ...
```

### 11.5 Legal Boundary

**[DECISION]** The official Liberated Bread repositories do not host community device packs. They are referenced but not distributed. The site says:

> "The devices listed here are ones we've tested and can support. For other devices, the community maintains configurable device packs using our YAML specification. These packs are created by community members for hardware they own and have permission to work with. Liberated Bread links to these packs but does not host or endorse them. **Use common sense — these are for hardware you own.**"

---

## 12. Video Content Strategy

**[DECISION]** Device pages may include embedded video walkthroughs. Videos are hosted on YouTube or Peertube and embedded responsively.

### 12.1 Embed Standards

```html
<!-- _includes/video-embed.html -->
<div class="video-embed">
  <div class="aspect-w-16 aspect-h-9">
    {% if include.platform == "youtube" %}
    <iframe
      src="https://www.youtube-nocookie.com/embed/{{ include.id }}"
      title="{{ include.title }}"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media;
             gyroscope; picture-in-picture"
      allowfullscreen
      loading="lazy">
    </iframe>
    {% elsif include.platform == "peertube" %}
    <iframe
      src="{{ include.instance }}/videos/embed/{{ include.id }}"
      title="{{ include.title }}"
      allowfullscreen
      sandbox="allow-same-origin allow-scripts allow-popups"
      loading="lazy">
    </iframe>
    {% endif %}
  </div>
  <p class="video-caption">{{ include.title }}</p>
</div>
```

### 12.2 Video Content Types

| Type | Example | Platform |
|---|---|---|
| Teardown / disassembly | Opening a Eufy cam, showing PCB | YouTube / Peertube |
| Assembly walkthrough | Installing a 3D-printed mount | YouTube / Peertube |
| Software setup screen recording | Home Assistant config, router setup | YouTube / Peertube |
| Before/after demonstration | Cloud-dependent vs. local control | YouTube / Peertube |

### 12.3 Guidelines

- **Privacy:** Use `youtube-nocookie.com` domain for YouTube embeds (no tracking cookies until user clicks play).
- **Lazy loading:** All video iframes use `loading="lazy"` to avoid blocking page render.
- **Fallback:** If the embed fails, show a direct link to the video.
- **Peertube preference:** When a Peertube version exists, prefer it over YouTube. List YouTube as the fallback.
- **No autoplay:** Videos never autoplay.

---

## 13. 3D Files & Git LFS Workflow

### 13.1 Repository Layout

```
liberatedbread-3d-files/
├── .gitattributes              ← LFS tracking rules
├── README.md                   ← Index with license + source attribution
├── LICENSE                     ← MIT
└── files/
    ├── eufy-camera/
    │   ├── wall-mount-v2.stl
    │   ├── wall-mount-v2.3mf
    │   ├── LICENSE.txt          ← File's original license
    │   └── SOURCE.txt           ← Attribution
    └── wemo-case/
        ├── wemo-wall-bracket.stl
        ├── LICENSE.txt
        └── SOURCE.txt
```

### 13.2 Git LFS Setup

```bash
cd liberatedbread-3d-files
git lfs install
git lfs track "files/**/*.stl" "files/**/*.3mf" "files/**/*.obj" "files/**/*.step"
git add .gitattributes
git commit -m "Configure Git LFS for 3D model files"
```

### 13.3 Adding a New File

1. Download from original source (Printables, Thingiverse, etc.)
2. Place in `files/<device-name>/`
3. Add `LICENSE.txt` with the file's license
4. Add `SOURCE.txt`:
   ```
   Original URL: https://www.printables.com/model/12345-eufy-camera-wall-mount
   Author: OriginalAuthor
   License: CC BY-SA 4.0
   Retrieved: 2026-07-25
   ```
5. Update `README.md` index
6. Commit and push

### 13.4 Serving

```html
<a href="https://raw.githubusercontent.com/liberatedbread/liberatedbread-3d-files/main/files/eufy-camera/wall-mount-v2.stl"
   download
   class="download-btn">
   ↓ Download Local Backup (STL, 1.2 MB)
</a>
```

---

## 14. Website Prompt Blueprints

### 14.1 Prompt A: Coming Soon Landing Page (Phase 0)

```
Act as an expert frontend engineer specializing in clean, ultra-responsive,
semantic HTML with Tailwind CSS. Build the COMING SOON teaser page for
"Liberated Bread" — an open-source project by Pigs Can Fly Labs LLC that
helps people rescue abandoned local IoT and Bluetooth devices.

THIS IS A SINGLE-PURPOSE TEASER PAGE, NOT THE FULL WEBSITE. The full landing
page (with device grid, 3-step plan, etc.) is deferred to Phase 1+. This
page exists to get the site live and start collecting newsletter subscribers.

DESIGN SYSTEM — "Tactical Bakery":
The site reconciles two aesthetics: the warmth of a bakery (amber bread-crust
accents, serif headings) and the tactical pragmatism of a hacker terminal
(dark navy backgrounds, monospace code blocks). Both come directly from the
bread.png logo's pixel colors.

COLORS (inferred from bread.png at build time — use CSS custom properties):
  Navy (page bg):                       var(--bread-base)
  Deep Navy (card/form bg):             darker variant of --bread-base
  Amber (heading, button bg):           var(--bread-accent)
  Orange (button hover):                saturated variant of --bread-accent
  Sky Blue (terminal, accents):         var(--bread-sky)
  Steel Blue (borders):                 desaturated --bread-sky at 70% opacity
  Khaki (body text on dark):            --bread-accent at 50% opacity

TYPOGRAPHY:
  Headings: Georgia, 'Times New Roman', serif
  Body: system-ui, -apple-system, sans-serif
  Code: 'Fira Code', 'Cascadia Code', 'SF Mono', monospace

LAYOUT:
  Dark mode only. Background is --bread-base (dark navy). Subtle dot pattern
  overlay using --bread-sky at 8% opacity at 20px spacing.

PAGE SECTIONS (single HTML file with Jekyll front-matter, serves as index.md):

1. CENTERED CARD (min-h-screen, flex, items-center, justify-center):
   Single centered card on the page — nothing else. No header nav, no footer
   links beyond a muted one-liner. The card has:
   - bg: --bread-base-dark (deep navy)
   - border: --bread-steel (steel blue), 1px
   - rounded-lg
   - max-w-lg, mx-auto
   - p-8 md:p-12

2. INSIDE THE CARD:
   a. Logo: 96×96 centered, from /assets/logo.png, alt="Liberated Bread logo"
   b. H1: "Liberated Bread" in serif, text-4xl, text-bread-amber, text-center
   c. Badge: "Coming Soon" — inline pill badge, bg --bread-sky (sky blue)/20,
      text --bread-sky (sky blue), text-sm, rounded-full, px-3 py-1, centered
   d. Tagline: "Reclaim your household hardware." in text-bread-khaki,
      text-lg, text-center, mt-4
   e. Description (text-bread-khaki, text-sm, text-center, max-w-md):
      "Step-by-step guides for liberating abandoned IoT devices from dead
       cloud services. By Pigs Can Fly Labs LLC."
   f. Divider line (border-t border-bread-steel, my-6)

3. SUBSCRIBE FORM:
   g. Label: "Get notified when we launch:" in text-bread-khaki, text-sm,
      text-center, block
   h. Form (flex, gap-2, mt-3):
      - Email input: type="email", name="email", required, placeholder="you@example.com"
        bg --bread-base-dark (deep navy), border --bread-steel (steel blue),
        text-bread-khaki, rounded-md, flex-1, px-3, py-2
      - Hidden field: <input type="hidden" name="interest" value="liberatedbread">
     - Hidden field: <input type="hidden" name="next" value="https://liberatedbread.com/thanks/">
     - Honeypot: hidden input name="website", style="display:none", tabindex="-1",
        autocomplete="off"
      - Submit button: "Notify Me →", bg --bread-accent (warm amber),
        hover: bg --bread-accent-bright (orange), text-white, rounded-md,
        px-4, py-2, font-semibold
      - Action: https://www.pigscanfly.ca/mailing-list/subscribe
      - Method: POST
      - NO JavaScript required — plain HTML form with server redirect to /thanks/
      - JS enhancement (optional): intercept submit, show inline "You're on
        the list! 🍞" success message without navigation, hide the form
   i. Privacy note (text-bread-khaki at 60% opacity, text-xs, text-center, mt-2):
      "No spam, ever. Unsubscribe anytime. Zero tracking."

4. SOCIAL LINKS ROW (below the divider, before the form or after — designer's
   choice, both valid):
   j. Centered row of inline SVG icons (20×20), gap-4:
      - GitHub: github.com/liberatedbread
      - Discord: Pigs Can Fly Labs server invite
      - RSS: /feed.xml
      - Mastodon: account TBD
      - YouTube: channel TBD
      All in text-bread-khaki, hover:text-bread-amber transition

5. FOOTER NOTE (below card, text-center, mt-8, text-bread-khaki/50, text-xs):
   k. "Liberated Bread is a project by Pigs Can Fly Labs LLC."
      → link to pigscanfly.ca (new tab, rel="noopener")
   l. "Some links may earn us a small commission. These guides are for
      hardware you own. Use common sense."
   m. "© 2026 Pigs Can Fly Labs LLC"

TECHNICAL REQUIREMENTS:
- Single index.md with Jekyll front-matter (layout: default)
- CSS via <link> to /assets/tailwind.css (pre-built, committed)
- Small inline <style> block for dot pattern background only
- Vanilla JS ONLY for the subscribe form enhancement (optional — page works
  without JS via plain form POST + server redirect)
- NO navigation bar, NO device grid, NO multi-section layout
- Semantic HTML: <main>, <section>, <footer>
- Accessible: alt text on logo, heading hierarchy, focus-visible on form,
  role="status" on success message
- Responsive: 320px min, card padding collapses to p-6 on mobile
- Performance: no external CSS/JS dependencies, lazy-load logo

DO NOT:
- Use any CSS/JS framework beyond Tailwind
- Add a navigation bar or multi-section layout
- Include AI-generated "synergy" copy
- Add animations >300ms or causing CLS
- Use emoji as the only visual indicator (always pair with text)
- Use generic black (#000) or white (#FFF) — always bread palette
- Make JS-only paths — the subscribe form works without JS
- Add a device grid, 3-step plan, or "How it works" section
- Reference unreleased features or timelines
```

---

### 14.2 Prompt B: Full Landing Page (Deferred — Phase 1+)

```
Act as an expert frontend engineer specializing in clean, ultra-responsive,
semantic HTML with Tailwind CSS. Build the complete landing page for
"Liberated Bread" — an open-source project by Pigs Can Fly Labs LLC that
helps people rescue abandoned local IoT and Bluetooth devices.

DESIGN SYSTEM — "Tactical Bakery":
The site reconciles two aesthetics: the warmth of a bakery (amber bread-crust
accents, serif headings) and the tactical pragmatism of a hacker terminal
(dark navy backgrounds, monospace code blocks). Both come directly from the
bread.png logo's pixel colors.

COLORS (inferred from bread.png at build time — use CSS custom properties):
  Navy (page bg, header, footer):       var(--bread-base)
  Deep Navy (darkest, card bg):         darker variant of --bread-base
  Amber (links, buttons, headings):     var(--bread-accent)
  Orange (hover/active states):         saturated variant of --bread-accent
  Sky Blue (code blocks, terminals):    var(--bread-sky)
  Steel Blue (borders, muted):          desaturated --bread-sky at 70% opacity
  Brown (subtle dark accents):          darkened --bread-accent
  Khaki (muted body text on dark):      --bread-accent at 50% opacity

TYPOGRAPHY:
  Headings: Georgia, 'Times New Roman', serif (warm, tactile, bakery)
  Body: system-ui, -apple-system, sans-serif (readable)
  Code/terminal: 'Fira Code', 'Cascadia Code', 'SF Mono', monospace

LAYOUT:
  Dark mode only. Background is --bread-base (dark navy). Subtle dot pattern
  overlay using --bread-sky at 8% opacity at 20px spacing.

PAGE SECTIONS (single HTML file with Jekyll front-matter, serves as a
page at /landing/ or replaces index.md in Phase 1+):

1. HEADER (sticky, backdrop-blur, bg --bread-base/90):
   - Logo: 40x40 from /assets/logo.png + "Liberated Bread" in serif, amber
   - Nav: Devices | GitHub | Contribute | Discord
   - Mobile: hamburger toggle (vanilla JS; <noscript> shows all links inline)

2. HERO:
   - H1 (serif, text-5xl, text-bread-amber): "Reclaim Your Household Hardware."
   - Subtitle (text-bread-khaki): "When corporate servers go dark, your
     devices shouldn't. We keep your smart home running — offline, local,
     and free."
   - Terminal block (bg deep navy, text-bread-sky, monospace,
     border border-bread-steel):
     Before: "$ ping api.belkin.com  ->  timeout"
     After:  "$ wemo switch living_room_lamp  ->  ON (2ms, local)"
   - CTA: "Start Liberating ->" button (bg --bread-accent, hover orange,
     white text) scrolls to #plan

3. 3-STEP LIBERATION PLAN (id="plan"):
   - Three horizontal cards (stack on mobile), bg deep navy,
     border steel blue:
     Step 1: Pick Your Device
     Step 2: Follow the Guide
     Step 3: Enjoy Freedom

4. SUPPORTED DEVICES GRID:
   - Filter: All | Software | Hardware (JS toggle; <noscript>: all visible)
   - Cards: bg deep navy, border steel blue, hover border sky blue
   - Each card: photo, name, type badge, difficulty bread-loaves, "View Guide ->"
   - Initial cards (hardcoded):
     * Belkin WeMo Insight Switch (Software)
     * Eufy Indoor Cam Mount (Hardware)
     * TP-Link Kasa Smart Bulb (Software)
     * Wyze Cam v3 RTSP (Software)

5. NEWSLETTER SIGNUP:
   - Email input (bg deep navy, border steel blue, text-bread-khaki)
   - Hidden honeypot field (style="display:none", name="website")
   - Submit button (bg --bread-accent)
   - <form action="https://www.pigscanfly.ca/mailing-list/subscribe"
           method="POST">
     NO JavaScript required — plain HTML form with server redirect.
   - JS enhancement: intercept submit, show inline success without navigation.
   - Privacy: "No spam, ever. Unsubscribe anytime."

6. FOOTER (bg dark navy, border-t border-steel-blue):
   - "Liberated Bread is a project by Pigs Can Fly Labs LLC"
     -> link to pigscanfly.ca (new tab, rel="noopener")
   - Nav: About | Contribute | Disclaimer | RSS | GitHub | Discord
   - Social icons (inline SVG, 20x20): GitHub, Discord, YouTube, Mastodon, RSS
     (Twitter/X if we bother — Mastodon preferred)
   - Banner: "Liberated Bread is free. Some links may earn us a small
     commission — we'll tell you when they do."
   - Legal: "These guides are for hardware you own. Use common sense.
     Pigs Can Fly Labs LLC isn't responsible for bricked devices, voided
     warranties, or angry IoT cloud providers."
   - (c) 2026 Pigs Can Fly Labs LLC

TECHNICAL REQUIREMENTS:
- Single index.md or landing.md with Jekyll front-matter (layout: default)
- CSS via <link> to /assets/tailwind.css (pre-built, committed)
- Small inline <style> block for dot pattern only
- Vanilla JS for mobile menu, device filter, form enhancement
- Every interactive feature works WITHOUT JavaScript
- Semantic HTML: <nav>, <main>, <section>, <article>, <footer>
- Accessible: heading hierarchy, alt text, focus-visible, aria-labels,
  role="alert" on form messages
- Responsive: 320px, 768px, 1024px, 1440px
- Performance: no external CSS/JS dependencies, lazy-load images

DO NOT:
- Use any CSS/JS framework beyond Tailwind
- Include AI-generated "synergy" copy
- Add animations >300ms or causing CLS
- Use emoji as the only visual indicator (always pair with text)
- Use generic black (#000) or white (#FFF) — always bread palette
- Make JS-only paths — every feature works without JS
```

---

### 14.3 Prompt C: Device Page Template

[To be written after Prompt A is validated. Same design system, optimized
for long-form guide pages with table-of-contents sidebar (desktop),
collapsible sections (mobile), safety block, video embeds, 3D file download
buttons, and parts/tools tables.]
```

---

## 15. Security & Privacy

### 15.1 Static Site

| Concern | Mitigation |
|---|---|
| Supply chain risk | No external CSS/JS at runtime. Tailwind is pre-built and committed. |
| HTTPS | GitHub Pages enforces HTTPS with HSTS. |
| XSS | No user-generated content. Jekyll markdown is server-rendered. |
| Link rot | 3D files mirrored. External links checked via `lychee` in CI. |

### 15.2 pcfweb Integration Security

| Concern | Mitigation |
|---|---|
| Secrets | No secrets stored in Liberated Bread repos — all handled by pcfweb |
| HTTPS | GitHub Pages enforces HTTPS. pcfweb enforces HTTPS. |
| CSRF | pcfweb's subscribe endpoint is `@csrf_exempt` by design — no authenticated state to protect |
| Rate limiting | pcfweb rate-limits subscribe endpoint (configurable) |
| Honeypot | `website` field catches bots — submission silently discarded |
| Email confirmation | Double opt-in via token-based confirmation link |
| Open redirect | pcfweb validates `?next=` against `MAILING_LIST_ALLOWED_NEXT_HOSTS` |

### 15.3 Privacy### 15.3 Privacy

| Data | Storage | Retention | Purpose |
|---|---|---|---|
| Newsletter email | PostgreSQL | Until unsubscribed | Newsletter delivery |
| Contact messages | PostgreSQL | 90 days | Support communication |
| Nginx logs | stdout → K8s logs | 30 days | Debugging, abuse prevention |
| Analytics | **None.** [DECISION] No tracking. If needed later, self-hosted Plausible. |
| Cookies | **None set by us.** No Django sessions, no analytics cookies. |

**Note on `@csrf_exempt` and cookies:** Because Django sets no cookies for unauthenticated form endpoints, there is no session to hijack. The honeypot field catches bots. This is the same pattern used by many static-site+API architectures (Netlify Forms, Formspree, etc.).

---

## 16. Testing Strategy

### 16.1 Static Site

| Layer | Tool | What |
|---|---|---|
| HTML validation | `html-validate` in CI | Valid HTML5, ARIA |
| Link checking | `lychee` in CI | No broken links |
| Tailwind build | CI verifies up-to-date | Prevents stale CSS |
| Jekyll build | `jekyll build` in CI | Site compiles without errors |
| Visual | Manual screenshot comparison | PR review |

### 16.2 Integration Tests

| Test | How |
|---|---|
| Newsletter form end-to-end | Submit static form → verify pcfweb stores subscription + sends confirmation email |
| Honeypot | Submit with `website` field populated → verify 200 OK, nothing stored (pcfweb-side) |
| Redirect | Submit with `?next=` → verify landing on `/thanks/` |
| Jekyll build | `jekyll build` in CI — site compiles without errors |
| RSS feed | Verify `feed.xml` is valid XML even when empty |

### 16.3 Pre-Launch Checklist### 16.3 Integration

| Test | How |
|---|---|
| Newsletter form end-to-end | Submit static form → verify Django stores + redirects |
| Honeypot | Submit with `website` field populated → verify 200 OK, nothing stored |
| Rate limiting | 6 rapid submissions → verify 429 on 6th |
| Health check | Verify GitHub Pages returns 200 for `liberatedbread.com` |

---

## 17. Content Moderation & Legal

### 17.1 Legal Disclaimer

We're not lawyers and we're not trying to sound like them. The standard disclaimer — on every device page and in the site footer — is:

> **Heads up:** These guides are for hardware you own. Use common sense. Don't do anything illegal. Pigs Can Fly Labs LLC isn't responsible for bricked devices, voided warranties, or angry IoT cloud providers. If you're not sure about something, ask someone who knows.

(If we ever need a real lawyer to review something, we'll hire one. Until then, plain English.)

### 17.2 Unsupported Devices & Device Packs

For devices we can't officially support (legal gray areas, regional weirdness, or just not enough time):

> "We may not be able to officially support some devices, but you can add configurable packs to enable more devices following our YAML spec — for devices you have permission to work with. See the [Device Pack System](/contribute/#device-packs) for details."

### 17.3 Affiliate Disclosure

Any page with affiliate links says, at the top of the links section:

> **Affiliate Disclosure:** Some links below are affiliate links. If you buy something through them, Liberated Bread may earn a small commission at no extra cost to you.

### 17.4 Contribution Model

PR-only contributions. A maintainer reviews every device page for accuracy, safety, and legal compliance before merging. No open wiki editing.

---

## 18. Contribution Pipeline

### 18.1 Adding a New Device Guide

1. Read `CONTRIBUTING.md`
2. Copy `contribute/device-template.md`
3. Fill in all required sections including safety block
4. Add front-matter with all required fields
5. Add the device to `_data/devices.yml`
6. If hardware-liberated: add STL files to `liberatedbread-3d-files` with `SOURCE.txt`
7. Open a PR against `liberatedbread-web-static`
8. Pass the PR checklist (Appendix C)

### 18.2 Creating a Device Pack

1. Reverse-engineer the device's protocol
2. Create a YAML file following the opengreeniot schema (Appendix D)
3. Validate against `schema.json`
4. Share as a GitHub Gist or personal repo
5. Optionally submit a link for inclusion on the community packs page

---

## 19. Community & Support

### 19.1 Channels

| Channel | Purpose | URL |
|---|---|---|
| **GitHub Discussions** | Durable Q&A, device requests, long-form discussion | `github.com/liberatedbread/liberatedbread-web-static/discussions` |
| **Discord (#liberated-bread)** | Real-time chat, quick help | Static invite to Pigs Can Fly Labs Discord |
| **GitHub Issues** | Bug reports, page corrections | `github.com/liberatedbread/liberatedbread-web-static/issues` |
| **Newsletter** | Project updates, new device guides | Signup on static site |
| **RSS Feed** | Newly freed devices, project updates | `liberatedbread.com/feed.xml` |

[DECISION] GitHub Discussions is the durable system of record. The site's "Community" nav links there first, with Discord as secondary.

### 19.2 RSS Feed

**[DECISION] Jekyll generates an RSS feed natively.** Every device page and blog-style update post is included in `feed.xml` automatically. The feed is linked from the site `<head>` (auto-discovery) and from the footer.

```xml
<!-- _includes/head.html -->
<link rel="alternate" type="application/rss+xml"
      title="Liberated Bread — Newly Freed Devices"
      href="/feed.xml">
```

Jekyll's `jekyll-feed` plugin (enabled by default on GitHub Pages) generates the feed. No additional build step required.

### 19.3 Social Links

Standard social link icons in the footer and on an `/about/` page. All links open in new tabs.

| Platform | URL | Notes |
|---|---|---|
| **GitHub** | `github.com/liberatedbread` | Org with all repos |
| **Discord** | Pigs Can Fly Labs server (stub) | Link to pcfweb Discord join page; fill in later |
| **YouTube** | Deferred | No channel at launch; add when video content exists |
| **Mastodon** | `hachyderm.io/@liberatedbread` | Federated alternative to Twitter/X |
| **Twitter/X** | N/A | Mastodon is the primary microblogging platform |

Icons use inline SVG (no external icon font). Footer shows GitHub + Discord + RSS as the primary three; full set on `/about/`.

---

## 20. Making Money (Maybe)

PCF Labs LLC is a business, not a non-profit. We hope the project makes some money, but we're not betting the farm on it.

| Channel | Status | Notes |
|---|---|---|
| **GitHub Sponsors** | Active at launch | Holden's sponsor link. Low-key — not a fundraising push, just there if people want it. |
| Out of pocket | Current | Covers infra until the project sustains itself |
| Affiliate links (Amazon, eBay) | Future, conditional | Only after the site has consistent traffic. Disclosed on every page. |
| ESP32-S3 voice satellite hardware | Phase 3+ | At-cost + margin. Stripe store on Django. |

No Amazon Associates account is created until the site demonstrates real traffic. GitHub Sponsors is the low-effort "if you want to" option from day one.

---

## 21. Future Roadmap

| Phase | Milestone | Details |
|---|---|---|
| **Phase 1: Launch** | Static site + Django backend | 5–10 device guides, newsletter, RSS feed |
| **Phase 2: Community** | Contribution pipeline active | PR template, review checklist, device packs taking off |
| **Phase 3: Hardware** | ESP32-S3 voice satellite | Custom PCB, firmware, documentation. **[DECISION] FCC (US) and CE (EU) compliance testing required before sale. Budget $5,000–$15,000 for testing lab fees. No hardware ships without certification.** |
| **Phase 4: Commerce** | Stripe store (via pcfweb) | Leverage pcfweb's existing e-commerce pattern for hardware + merchandise; no standalone store |
| **Phase 5: Local CLI** | `liberatedbread-cli` | Python CLI that scans LAN for liberatable devices using opengreeniot device specs. Fully local. |

---

## 22. Appendix A: Color Palette

**[DECISION] Colors are inferred from the logo at build time.** The `bread.png` logo is the single source of truth for the brand palette. CSS custom properties (`--bread-base`, `--bread-accent`, `--bread-sky`) are sampled from the current logo and consumed via Tailwind. See §3 for the design token architecture.

## 23. Appendix B: Device Index Schema

`_data/devices.yml` drives the device catalog on the static site.

```yaml
# _data/devices.yml
# Schema version: 1
devices:
  - slug: wemo-switch
    name: "Belkin WeMo Insight Switch"
    model: "F7C029"
    type: software
    difficulty: 1
    time_minutes: 15
    firmware: "WeMo_WW_2.00.11426.PVT-OWRT-SNS"
    last_verified: "2026-07-25"
    short_desc: >-
      Keep your WeMo switches working locally after Belkin's cloud goes dark.
    image: "/assets/devices/wemo-hero.webp"
    ha_integration: "pywemo"
    safety_block: false
    tags: ["wemo", "belkin", "smart-plug", "wifi"]
    opengreeniot_spec: "https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/device-specs/devices/wemo-devices.yaml"
    opengreeniot_docs: "https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/docs/devices/wemo-devices.md"

  - slug: eufy-mount
    name: "Eufy Indoor Cam Mount Replacement"
    model: "T8400"
    type: hardware
    difficulty: 2
    time_minutes: 45
    last_verified: "2026-07-25"
    short_desc: "Replace the flimsy stock mount with an articulating 3D-printed arm."
    image: "/assets/devices/eufy-mount.webp"
    safety_block: true
    stl_files:
      - filename: "wall-mount-v2.stl"
        description: "Articulating wall mount (PLA, 20% infill)"
      - filename: "ball-joint.stl"
        description: "Ball joint connector (PETG, 50% infill)"
    tags: ["eufy", "camera", "mount", "3d-print"]

last_updated: "2026-07-25"
total_devices: 2
```

---

## 24. Appendix C: Contribution Checklist

Located at `.github/PULL_REQUEST_TEMPLATE/device-guide.md`:

```markdown
## Device Guide PR Checklist

### Accuracy
- [ ] All steps tested on the **exact firmware version** listed
- [ ] Device model number matches the tested unit exactly
- [ ] `last_verified` date is today or within the past 30 days
- [ ] No steps require paid software or subscriptions
- [ ] No steps connect the device to a different cloud service

### Safety (hardware-liberated devices)
- [ ] Mandatory safety block is the FIRST content after the metadata bar
- [ ] "De-energize / Unplug" is step zero
- [ ] Mains-voltage warning present if device plugs into wall outlet
- [ ] Capacitor discharge warning present if device was recently powered

### Content
- [ ] Device added to `_data/devices.yml` with all required fields
- [ ] Device page created in `_devices/<slug>.md` with full front-matter
- [ ] All guide sections completed per device-template.md
- [ ] Troubleshooting section covers at least 2 common failure modes
- [ ] Photos/screenshots are original (not pulled from manufacturer's site)

### Legal
- [ ] Disclaimer callout visible (top of page or in standard footer position)
- [ ] "Use common sense — for hardware you own" language present
- [ ] No proprietary firmware blobs, keys, or copyrighted code included
- [ ] Third-party code/configs attributed with links to original source

### 3D Files (hardware-liberated devices only)
- [ ] STL files added to `liberatedbread-3d-files` repo
- [ ] `SOURCE.txt` present with original URL, author, license, retrieval date
- [ ] `LICENSE.txt` present with the file's original license
- [ ] Print settings documented (material, infill, supports, orientation)

### Video (if applicable)
- [ ] Video uses youtube-nocookie.com or Peertube embed
- [ ] Lazy loading enabled on iframe
- [ ] Direct link fallback present

### Affiliate Links (if any)
- [ ] Affiliate disclosure banner present at top of links section
- [ ] All links use affiliate tags

### Meta
- [ ] I own the device this guide is for
- [ ] I have read CONTRIBUTING.md
```

---

## 25. Appendix D: Device Pack YAML Spec

Community device packs follow the [opengreeniot-protocol-docs schema](https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/device-specs/schema.json). This appendix summarizes the minimum required fields for a Liberated Bread device pack.

### 25.1 Minimal Device Pack Template

```yaml
# liberatedbread-device-pack.yaml
# Schema: opengreeniot-protocol-docs device-spec schema v1
# License: CC BY-SA 4.0
# Author: @your-github-handle
# Compatible with: Liberated Bread device pack loader v1

device:
  name: "Device Name"
  manufacturer: "Manufacturer"
  manufacturer_status: "abandoned"    # abandoned | shutdown | unsupported | active
  protocol: "ble"                     # ble | wifi | zigbee | zwave
  identification:
    local_name_prefix: "DEV_"         # BLE: advertisement name prefix
    # OR for WiFi:
    # ssdp:
    #   search_targets: ["urn:example:device:1"]

  notes: >
    Describe the device and any special considerations.
    Include: "For use only on hardware you own and have permission to modify."

# For BLE devices:
services:
  - uuid: "0000fff0-0000-1000-8000-00805f9b34fb"
    name: "Control Service"
    characteristics:
      - uuid: "0000fff1-0000-1000-8000-00805f9b34fb"
        name: "Command"
        properties: ["write"]
        commands:
          power_on:
            description: "Turn the device on"
            value: [0x01, 0x01]

# For WiFi devices:
# http_endpoints:
#   - method: "POST"
#     path: "/api/control"
#     name: "Set Power State"
#     request_body:
#       content_type: "application/json"
#       fields:
#         - name: "power"
#           type: "boolean"
#           required: true

# Home Assistant entity mapping:
entities:
  - platform: "switch"
    name: "Device Switch"
    state_characteristic: "0000fff2-0000-1000-8000-00805f9b34fb"
```

### 25.2 Validation

```bash
# Validate a device pack against the schema
pip install jsonschema pyyaml
python -c "
import json, yaml, jsonschema
schema = json.load(open('schema.json'))
pack = yaml.safe_load(open('my-pack.yaml'))
jsonschema.validate(pack, schema)
print('PASS')
"
```

### 25.3 Where Packs Live

Community packs are NOT hosted in the Liberated Bread repositories. They are shared via:
- GitHub Gists
- Personal repositories
- The Liberated Bread community forum (GitHub Discussions)

The official site links to the pack specification and validation tools but does not host or endorse individual packs. This maintains the legal boundary: the project provides the format and tooling; the community creates and shares the content.

---

## Document History

| Version | Date | Notes |
|---|---|---|
| v0.1 | 2026-07-25 | Initial DESIGN.md |
| v0.2 | 2026-07-25 | DESIGN-updated.md (LFS notes, pcfweb reference) |
| v1.0-draft | 2026-07-25 | First pass: consolidated repos, added security/privacy/testing sections |
| v2.0-draft | 2026-07-25 | Round-1 refinement: 16 planner critique issues, corrected bread.png colors |
| **v3.0-final** | 2026-07-25 | **[THIS DOCUMENT]** Convergence draft. Applied all 6 resolved disagreements: mandatory safety blocks, rewritten legal disclaimer, configurable device pack system, pcfweb PRIMARY/secondary deployment, @csrf_exempt + honeypot, Cloudflare DNS-only for Pages, Jekyll SSG with markdown+front-matter, video content strategy, opengreeniot-protocol-docs integration. |

---

## Open Questions [OPEN]

1. **Light mode:** The site is dark-mode-only for Phase 1. Should a light mode toggle be added at launch or deferred?

2. **ESP32-S3 timeline:** Is the voice satellite Phase 3 a near-term goal or aspirational?

3. **Kubernetes cluster:** Confirming the `liberatedbread` namespace will be created in the existing pcfweb cluster. Is there capacity?

4. **GitHub Sponsors:** Use Holden's existing GitHub Sponsors link. [DECISION] Exact URL TBD — drop it in when ready.

5. **Domain:** Is `liberatedbread.com` registered and ready for GitHub Pages custom domain setup?

6. **3D file default license:** For files where the original source license cannot be determined, what default license applies? (Proposal: CC BY-SA 4.0.)

7. **CloudNativePG:** N/A — Liberated Bread has no dedicated database. [REMOVED]

8. **Email backend:** Resolved — via pcfweb mailing list system. [DECISION]

9. **Prompt C (Device Page Template):** Should the device page template prompt be written now, or deferred until the landing page is validated with the actual bread palette?
