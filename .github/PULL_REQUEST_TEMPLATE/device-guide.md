---
name: Device guide
about: Add or update a device liberation guide
labels: device-guide
---

<!--
  Use this template when adding or updating a device guide.
  Apply it by appending ?template=device-guide.md to the PR compare URL.
  Checklist source: DESIGN Appendix C.
-->

**Device:**
**Model / firmware this guide targets:**
**Liberation type:** software / hardware

## Device Guide PR Checklist

### Verification status — tick exactly ONE

Both are welcome submissions. Tick the one that is true; the checks that follow
depend on which.

- [ ] **Untested draft.** I have not run this on the device. `hardware_verified`
      and `last_verified` are both omitted, so the page shows the "Not yet
      verified on hardware" status block and the firmware row reads "Written for
      firmware". This is the normal way a guide arrives — nothing further in this
      section applies.
- [ ] **Verified on hardware.** I own the device and ran **every step** of this
      guide on it, on the **exact firmware version listed**. `hardware_verified:
      true` and `last_verified` are both set. Ticking this box is the claim; the
      three boxes below are what it commits me to.
  - [ ] Every step was run, in order, on the physical device
  - [ ] Device model number matches the unit I used, exactly
  - [ ] `last_verified` is today or within the past 30 days

### Accuracy
- [ ] The `firmware` field names the exact version this guide targets — the one I
      ran it on if verified, the one I wrote it against if not
- [ ] No steps require paid software or subscriptions
- [ ] No steps connect the device to a different cloud service

### Safety (hardware-liberated devices)
- [ ] `safety_block: true` is set in the front matter
- [ ] Mandatory safety block is the FIRST content after the metadata bar
- [ ] "De-energize / Unplug" is step zero
- [ ] Mains-voltage warning present if device plugs into a wall outlet
- [ ] Capacitor discharge warning present if device was recently powered

### Content
- [ ] Device added to `_data/devices.yml` with all required fields
- [ ] Device page created in `_devices/<slug>.md` with full front-matter
- [ ] `slug` matches in the filename, the front matter, and `_data/devices.yml`
- [ ] All guide sections completed per `/contribute/device-template/`
- [ ] Troubleshooting section covers at least 2 common failure modes
- [ ] Photos/screenshots are original (not pulled from the manufacturer's site)

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
- [ ] Video uses youtube-nocookie.com or a Peertube embed
- [ ] Lazy loading enabled on the iframe
- [ ] Direct link fallback present

### Affiliate Links (if any)
- [ ] Affiliate disclosure banner present at top of the links section
- [ ] All links use affiliate tags

### Build
- [ ] `bundle exec jekyll build` passes locally
- [ ] `npm run build:css` produces no diff (or the diff is committed)
- [ ] CI is green

### Meta
- [ ] I own the device this guide is for
- [ ] I have read the [contribution guide](https://liberatedbread.com/contribute/)
