# liberatedbread-web-static

The static site behind **[liberatedbread.com](https://liberatedbread.com)** — a
[Pigs Can Fly Labs LLC](https://pigscanfly.ca) project publishing step-by-step
guides for liberating abandoned IoT devices from dead cloud services.

Jekyll, deployed by GitHub Pages on push to `main`. No backend: the only dynamic
piece is the newsletter form, which POSTs to pcfweb's mailing list
([DESIGN §6.3](DESIGN-finalized.md#63-pcfweb-mailing-list-integration)).

> **Phase 0:** `/` currently serves a coming-soon teaser by design, and the
> unlaunched site is not advertised to crawlers or feed readers. Everything is
> built and reachable by direct URL. All of it hangs off the single `phase0`
> flag in `_config.yml` — see **[PHASE0.md](PHASE0.md)** before launching.

## Local development

Requires Ruby (bundler) and Node 20+.

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
the launched site is link-checked continuously too. A stale stylesheet or a
half-flipped `phase0` fails the build.

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

## Adding a device guide

1. Copy the template at [`contribute/device-template.md`](contribute/device-template.md)
   (rendered at `/contribute/device-template/`) to `_devices/<slug>.md`.
2. Fill in the front matter. `slug` must match the filename.
   **Set `safety_block: true` for every hardware guide**, and for any software
   guide whose steps require opening the device — that renders the mandatory
   safety callout ([DESIGN §10.1](DESIGN-finalized.md#101-mandatory-safety-block)).
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
  ...                      head, header, footer, safety-block, device-card,
                           subscribe-form, social-links, video-embed
sitemap.xml                Phase 0-aware; jekyll-sitemap defers to it
_data/brand.yml            GENERATED from src/input.css — do not hand-edit
src/input.css              Brand tokens + component styles (source of truth)
tailwind.config.js         Maps bread-* utilities onto the tokens
assets/tailwind.css        Built, minified, committed — served in production
script/check-links.rb      Offline internal-link checker used by CI
script/check-phase0.rb     Asserts the built site matches the phase0 flag
script/sync-brand-data.rb  Regenerates _data/brand.yml from src/input.css
CNAME                      liberatedbread.com
DESIGN-finalized.md        Authoritative design document
PHASE0.md                  What's live at /, and how to go to Phase 1
```

## Licence

Site content is free to read and share. Guides are for hardware you own — see
[/disclaimer/](https://liberatedbread.com/disclaimer/).
