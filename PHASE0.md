# Phase 0 — the coming-soon root page

The site is fully built. Every page in the [site map](DESIGN-finalized.md#92-site-map)
exists, builds, and is reachable by direct URL. Only **`/` is different**: it
serves a single-purpose teaser instead of the full landing page.

This is deliberate, per [DESIGN §9.6](DESIGN-finalized.md#96-coming-soon-landing-page-phase-0).
Phase 0 gets the domain, DNS, TLS and the pcfweb subscribe pipeline validated
with real traffic before we commit to the full landing page layout.

## What is live at `/`

Logo, serif wordmark, the tagline, one sentence of description, the subscribe
form, a social row, and a footer. No navigation bar, no device grid, no 3-step
plan, no "how it works", and no JavaScript.

## What is live everywhere else

Nothing is hidden — these are simply not linked from `/`:

| URL | Source |
|---|---|
| `/devices/` | `devices.md` (reads `_data/devices.yml`) |
| `/devices/<slug>/` | `_devices/<slug>.md` |
| `/ha-plugins/` | `ha-plugins/index.md` |
| `/about/` | `about.md` |
| `/contribute/` | `contribute/index.md` |
| `/contribute/device-template/` | `contribute/device-template.md` |
| `/thanks/` | `thanks.md` — where pcfweb redirects after signup |
| `/disclaimer/` | `disclaimer.md` |
| `/feed.xml` | jekyll-feed (site feed; empty until there are posts) |
| `/feed/devices.xml` | jekyll-feed (device guides) |
| `/rss/` | `rss.md` — redirects to `/feed.xml` |

## Going live: change one line

The full landing page is already written and already builds. It lives in
[`_layouts/landing.html`](_layouts/landing.html). Jekyll never emits a layout as
a page, so it is unreachable until something opts into it.

**To ship it, edit [`index.md`](index.md) and change exactly one line:**

```diff
-layout: coming-soon
+layout: landing
```

That is the entire switch. Commit, push to `main`, GitHub Pages rebuilds.

To go back, change the line back. Nothing else moves.

### Why it's a layout and not a config flag

A `site.coming_soon` boolean would mean the live page depends on config state
that is easy to flip by accident, easy to set differently in dev and prod, and
invisible in a diff that touches `_config.yml` for unrelated reasons. Pointing
`index.md` at a named layout makes the change explicit, atomic, and obvious in
review: if a PR does not touch `index.md`, it cannot change what `/` serves.

### Preview it before flipping

```bash
bundle exec jekyll serve
# edit index.md -> layout: landing, save, reload http://127.0.0.1:4000/
# revert index.md when you're done
```

## Before you flip the switch

- [ ] `_data/devices.yml` has **5 or more** devices, each with a real guide in
      `_devices/` (DESIGN §9.6 gates the flip on this; it currently has 2)
- [ ] Real device photos have replaced the generated placeholders in
      `assets/devices/` — see the note at the top of `_data/devices.yml`
- [ ] The subscribe form has been tested end-to-end against pcfweb: the
      `liberatedbread` InterestArea exists, and `liberatedbread.com` is on
      pcfweb's `MAILING_LIST_ALLOWED_NEXT_HOSTS` so `/thanks/` is reachable
      after signup (DESIGN §6.3)
- [ ] The YouTube slot in `_includes/social-links.html` is either a real channel
      link or still intentionally disabled
- [ ] The landing page has been reviewed at 320px, 768px and 1440px
- [ ] `bundle exec jekyll build` and `npm run build:css` are both clean, and CI
      is green

## The subscribe form is in both versions

`_includes/subscribe-form.html` is shared by `_layouts/coming-soon.html` and
`_layouts/landing.html`. Switching layouts does not change the form, the
endpoint, the honeypot, or the `interest` slug — so no subscriber is lost and
nothing needs re-testing on the pcfweb side.
