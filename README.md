# liberatedbread-web-static

The static site behind **[liberatedbread.com](https://liberatedbread.com)** — a
[Pigs Can Fly Labs LLC](https://pigscanfly.ca) project publishing step-by-step
guides for liberating abandoned IoT devices from dead cloud services.

Jekyll, built and deployed to GitHub Pages by
[`.github/workflows/pages.yml`](.github/workflows/pages.yml) on push to `main`.
The repo's Pages source is **GitHub Actions**, not Pages' own legacy Jekyll
build, so nothing reaches the live site unless that workflow uploads an
artifact and deploys it. No backend: the only dynamic piece is the newsletter
form, which POSTs to pcfweb's mailing list
([DESIGN §6.3](DESIGN-finalized.md#63-pcfweb-mailing-list-integration)).

> **Phase 0:** `/` currently serves a coming-soon teaser by design, and the
> unlaunched site is not advertised to crawlers or feed readers. Everything is
> built and reachable by direct URL. All of it hangs off the single `phase0`
> flag in `_config.yml` — see **[PHASE0.md](PHASE0.md)** before launching.

## Local development

Requires Ruby (see `.ruby-version` — the single source of truth, used by both
workflows and by a local `bundle install`; do not pin a Ruby version anywhere
else) and Node 20+.

```bash
bundle install          # installs the same gem set GitHub Pages runs
npm install             # Tailwind CLI only

bundle exec jekyll serve # http://127.0.0.1:4000
```

Run the CSS watcher in a second terminal if you're editing styles or classes:

```bash
npm run watch:css
```

### Before you push

```bash
npm run build:css                    # rebuild assets/tailwind.css + _data/brand.yml
bundle exec jekyll build --strict_front_matter
ruby script/check-links.rb  _site    # no broken internal links
ruby script/check-phase0.rb _site    # built site matches the phase0 flag
```

CI runs exactly these, plus a check that the committed `assets/tailwind.css` and
`_data/brand.yml` match `src/input.css`, plus a build of the *opposite* phase so
the launched site is link-checked continuously too, plus `actionlint` over the
workflow files. A stale stylesheet or a half-flipped `phase0` fails the build.

## How it deploys

```
push to main ──▶ .github/workflows/pages.yml
                   build job:  jekyll build --strict_front_matter
                               check-links.rb _site
                               check-phase0.rb _site      ← pre-deploy gate
                               verify _site/CNAME
                               upload-pages-artifact
                   deploy job: deploy-pages ──▶ liberatedbread.com
```

The gate runs against the exact `_site` that is about to be uploaded, so a
half-flipped `phase0` or a broken internal link fails the deploy instead of
going live. `ci.yml` runs the same build on pull requests — it never deploys.

The workflow takes Ruby from `.ruby-version`, builds with `JEKYLL_ENV=production`,
and never cancels a deploy in flight (`concurrency.cancel-in-progress: false`).
Watch a deploy at
[Actions → Deploy to GitHub Pages](https://github.com/liberatedbread/liberatedbread-web-static/actions/workflows/pages.yml).

## How the styling works

Every brand colour is a CSS custom property defined in **one place**,
[`src/input.css`](src/input.css), sampled from `assets/logo.png` and documented
there with the derivation. [`tailwind.config.js`](tailwind.config.js) maps the
`bread-*` utilities onto those properties — it contains no hex values, and
neither does any layout or page.

```
                                                    ┌─▶ tailwind.config.js ─┐
assets/logo.png ──sampled──▶ :root{--bread-*} ──────┤   (bread-* utilities) ├──▶ assets/tailwind.css
                              (src/input.css)       │                       │    (built, committed)
                                                    └─▶ _data/brand.yml ────┘
                                                        (generated; for markup
                                                         CSS can't reach, e.g.
                                                         <meta theme-color>)
```

If the logo changes, re-sample it (the command is in the comment at the top of
`src/input.css`), update those few lines, run `npm run build:css`, and the whole
site follows. `assets/tailwind.css` is committed on purpose — production loads
no CSS or JS from a third-party host
([DESIGN §9.5](DESIGN-finalized.md#95-tailwind-css-build), §15.1).

## How JavaScript is allowed to work here

There are two scripts on the site:

- `assets/js/device-filter.js`, loaded by `/devices/` directly — from the page,
  never from a layout.
- the header nav enhancement, inline in `_includes/header.html`.

**`/` ships zero JavaScript, in both phase positions.** Not just the Phase 0
teaser — the Phase 1 landing page too, because `/` is the one page whose whole
job is to load instantly for someone who has never heard of us. The teaser gets
this for free (`home-coming-soon.html` includes no header), but the landing page
*does* include the header, so `_includes/header.html` skips emitting its script
when `page.url == "/"`. `script/check-phase0.rb` asserts it unconditionally, so
CI's opposite-phase build catches a regression at PR time rather than at launch.
The cost is that `/` alone keeps the nav's no-JS fallback — an expanded,
wrapping link row instead of a disclosure button. That fallback is designed and
shipped anyway for anyone with scripting off.

Three rules apply to anything added next to them
([DESIGN §9.4](DESIGN-finalized.md#94-no-js-fallbacks)):

1. **Nothing script-shaped reaches `/`.** A script in a shared include is fine
   only if it is guarded out of the root page, as the header's is.
2. **The page is finished before the script runs.** Every device card is
   rendered and visible in the HTML; nothing is hidden at render time waiting
   to be revealed. Controls that only make sense with JavaScript live inside a
   `<template>`, which the parser leaves inert, so with scripting off they are
   not on the page at all rather than sitting there dead.
3. **Scripts do not apply Tailwind classes.** Tailwind only compiles classes it
   finds in the paths it scans and it never scans `.js`, so a class applied
   only at runtime is missing from `assets/tailwind.css` — invisible in review,
   broken in production. Drive state from an attribute instead, backed by
   hand-written CSS in `src/input.css`. The filter's rule, `[data-lb-hidden]`,
   is deliberately outside every `@layer` so it outranks the utilities on the
   element it hides — `script/check-unlayered-css.rb` fails the build if a
   refactor ever moves it into one, because the symptom otherwise is a filter
   that silently stops filtering.

## Adding a device guide

1. Copy the template at [`contribute/device-template.md`](contribute/device-template.md)
   (rendered at `/contribute/device-template/`) to `_devices/<slug>.md`.
2. Fill in the front matter. `slug` must match the filename.
   **Set `safety_block: true` for every hardware guide**, and for any software
   guide whose steps require opening the device — that renders the mandatory
   safety callout ([DESIGN §10.1](DESIGN-finalized.md#101-mandatory-safety-block)).
   **Leave `hardware_verified` and `last_verified` out unless you have run the
   guide on the device.** Submitting an unverified guide is normal and welcome —
   it is how most arrive. The page then shows a "Not yet verified on hardware"
   status block and its firmware row reads "Written for firmware". Set both keys
   together, and only once you have genuinely run every step on the physical
   device; that claim is what binds you to the strict accuracy standard. The
   default must not be inverted: with most of the catalogue unverified at any
   time, a scheme where silence meant "verified" would mislabel nearly every
   page. Verification is a claim you write down, never one a guide inherits by
   omitting a key. `hardware_verified` must be an unquoted YAML boolean —
   `_layouts/device.html` compares it against `true` rather than testing
   truthiness, because in Liquid every string including `"false"` is truthy, and
   `script/check-device-frontmatter.rb` rejects a non-boolean so a malformed
   claim is a loud build failure rather than a silently unverified page.

   **To mark a guide verified later:** add those two keys to
   `_devices/<slug>.md`. That is the entire change — one file, one edit. The
   status block, the metadata bar's "Verified:" row and the firmware label all
   follow from the same condition, `_data/devices.yml` carries no verification
   state, and no guide's prose depends on the flag.
3. Write the body starting at `##`. The `<h1>`, metadata bar, safety block,
   video embed, protocol links and disclaimer all come from the layout.
4. Add a matching entry to [`_data/devices.yml`](_data/devices.yml) so the guide
   appears at `/devices/`. Point `image` at a real photo in `assets/devices/`,
   or omit it and the card renders a placeholder tile.
5. Hardware guides: add STL files to
   [`liberatedbread-3d-files`](https://github.com/liberatedbread/liberatedbread-3d-files)
   with `SOURCE.txt` and `LICENSE.txt`.
6. Open a PR using the
   [device-guide template](.github/PULL_REQUEST_TEMPLATE/device-guide.md)
   (append `?template=device-guide.md` to the compare URL). Every guide is
   reviewed before merge.

## Layout of the repo

```
_config.yml                Jekyll + pcfweb mailing-list settings
_data/devices.yml          Device catalog (DESIGN Appendix B)
_devices/*.md              Device guides (Jekyll collection -> /devices/<slug>/)
_layouts/
  base.html                <html> shell only
  default.html             base + header/footer, for prose pages
  device.html              metadata bar, safety block, video, protocol links
  home.html                dispatches / on the phase0 flag
_includes/
  home-coming-soon.html    Phase 0 root page  <-- currently live at /
  home-landing.html        Phase 1 root page  <-- built and CI-checked, not live
  device-filter.html       /devices/ filter, as an inert <template>
  verification-status.html "Not yet verified on hardware" status block; renders
                           unless the guide explicitly claims otherwise
  ...                      head, header, footer, safety-block, device-card,
                           subscribe-form, social-links, video-embed
assets/js/
  device-filter.js         Loaded by /devices/ only. / ships no JS (PHASE0.md)
sitemap.xml                Phase 0-aware; jekyll-sitemap defers to it
_data/brand.yml            GENERATED from src/input.css — do not hand-edit
src/input.css              Brand tokens + component styles (source of truth)
tailwind.config.js         Maps bread-* utilities onto the tokens
assets/tailwind.css        Built, minified, committed — served in production
script/check-links.rb      Offline internal-link checker used by CI
script/check-phase0.rb     Asserts the built site matches the phase0 flag,
                           and that / ships no JS in EITHER phase
script/check-device-frontmatter.rb
                           Asserts hardware_verified is a real YAML boolean and
                           a true claim carries a last_verified date
script/check-tailwind-content.rb
                           Asserts Tailwind scans exactly the served pages
script/check-unlayered-css.rb
                           Asserts [data-lb-hidden] is emitted outside every
                           @layer AND still declares display:none, so the
                           /devices/ filter keeps working
script/sync-brand-data.rb  Regenerates _data/brand.yml from src/input.css
.github/workflows/
  ci.yml                   Verification on every PR — never deploys
  pages.yml                Build + gate + deploy to GitHub Pages, push to main
CNAME                      liberatedbread.com
DESIGN-finalized.md        Authoritative design document
PHASE0.md                  What's live at /, and how to go to Phase 1
```

## Licence

Site content is free to read and share. Guides are for hardware you own — see
[/disclaimer/](https://liberatedbread.com/disclaimer/).
