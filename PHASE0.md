# Phase 0 — the coming-soon root page

The site is fully built. Every page in the [site map](DESIGN-finalized.md#92-site-map)
exists, builds, and is reachable by direct URL. Two things are different while
Phase 0 is on:

1. **`/` serves a single-purpose teaser** instead of the full landing page.
2. **The unlaunched site is not advertised to machines** — the sitemap lists
   only `/`, and the teaser does not carry autodiscovery for the device-guide
   feed.

Both are deliberate, per [DESIGN §9.6](DESIGN-finalized.md#96-coming-soon-landing-page-phase-0).
Phase 0 validates the domain, DNS, TLS and the pcfweb subscribe pipeline with
real traffic before we commit to the full landing page.

> **Point 2 is the easy one to get wrong.** A teaser that looks perfectly clean
> in a browser can still hand a crawler the whole unlaunched catalog through
> `sitemap.xml`, or hand a feed reader every guide title through
> `<link rel="alternate">`. Clean to a human, leaking to a machine. That is why
> all of it hangs off one flag and why CI asserts it.

## The master switch

Everything is gated by **one line** in [`_config.yml`](_config.yml):

```yaml
phase0: true
```

| It gates | Where | `phase0: true` | `phase0: false` |
|---|---|---|---|
| The root page | [`_layouts/home.html`](_layouts/home.html) | `_includes/home-coming-soon.html` | `_includes/home-landing.html` |
| Sitemap coverage | [`sitemap.xml`](sitemap.xml) | `/` only | all pages + all device guides |
| Devices-feed autodiscovery | [`_includes/head.html`](_includes/head.html) | omitted on `/` | present on `/`, as everywhere else |

There is nothing else to remember. No second file to edit, no plugin to
re-add, no front-matter defaults to delete.

### Why one flag and not three toggles

An earlier revision made the root page a layout swap in `index.md` and left the
sitemap and the feed link as separate concerns. That is three independent
things to remember at launch, and the two that are easy to forget are exactly
the two that are invisible in a browser — so the failure mode was "we launched
six weeks ago and Google has never indexed us," discovered late.

Front-matter `defaults` with `sitemap: false` were the obvious way to do the
sitemap half, but Jekyll defaults are static YAML and cannot read `phase0`,
which is why [`sitemap.xml`](sitemap.xml) is a source file instead. Read the
comment at the top of it before touching it — `jekyll-sitemap` is still
installed and still generates `robots.txt`, and it takes sitemap generation
back the moment that file disappears.

## Going live

1. **Check the pre-launch list below is green.**
2. Edit [`_config.yml`](_config.yml):
   ```diff
   -phase0: true
   +phase0: false
   ```
3. Rebuild and verify — all three must reverse together:
   ```bash
   bundle exec jekyll build --strict_front_matter
   ruby script/check-phase0.rb _site     # asserts the built site matches the flag
   ruby script/check-links.rb  _site     # no broken internal links
   ```
   `check-phase0.rb` fails the build if the flag and the emitted site disagree
   in either direction, so a half-flip cannot ship. `ci.yml` runs it against
   **both** settings on every PR, which also means the launched site is being
   built and link-checked continuously while Phase 0 is still on, and
   `pages.yml` runs it once more against the artifact it is about to deploy —
   a half-flip fails the deploy rather than going live.
4. Commit and push to `main`. That triggers
   [`.github/workflows/pages.yml`](.github/workflows/pages.yml), which builds
   the site, runs the checks above against `_site`, and deploys it. The repo's
   Pages source is **GitHub Actions** — there is no separate Pages Jekyll build,
   so if that workflow does not run or does not pass, nothing changes on the
   live site. Watch the run under Actions → *Deploy to GitHub Pages* before
   moving on.
5. **After the deploy job goes green**, confirm on the live site:
   - `https://liberatedbread.com/` is the full landing page
   - `https://liberatedbread.com/sitemap.xml` lists every page, not just `/`
   - `view-source:` on `/` shows `rel="alternate"` for `/feed/devices.xml`
   - Resubmit the sitemap in Google Search Console — it has been serving a
     one-URL sitemap and will not re-crawl promptly on its own.

To roll back, set the flag to `true` again. Nothing else moves.

### Preview before flipping

```bash
bundle exec jekyll serve
# flip phase0 to false in _config.yml, save, reload http://127.0.0.1:4000/
# revert when you're done — `git diff _config.yml` should be empty
```

## Pre-launch checklist

- [ ] `_data/devices.yml` has **5 or more** devices, each with a real guide in
      `_devices/` (DESIGN §9.6 gates launch on this; it currently has 2)
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
- [ ] The *Deploy to GitHub Pages* workflow has deployed at least once and
      `https://liberatedbread.com/` is serving the Phase 0 teaser — flipping the
      flag on a site that has never deployed changes nothing visible, and the
      real fault will be the deploy, not the flag

## What stays the same across the switch

`_includes/subscribe-form.html` is shared by both root-page bodies. Flipping
`phase0` does not change the form, the endpoint, the honeypot, or the `interest`
slug — no subscriber is lost and nothing needs re-testing on the pcfweb side.

The pages that are unlinked-but-reachable during Phase 0 do **not** change
either. They keep their devices-feed autodiscovery the whole time: someone
reading `/devices/` has already found the guides, and breaking the feed for
them would serve nobody. Only the teaser is quiet.
