---
layout: default
title: Contribute
description: How to contribute device liberation guides to Liberated Bread.
heading: Contribute a Device Guide
permalink: /contribute/
---

Liberated Bread is community-driven. Device pages are contributed by people who own the hardware and have done the work. Here's how to add yours.

## Quick Start

1. **Read this page** (you're doing it!)
2. **Copy the template:** [`contribute/device-template.md`](/contribute/device-template/)
3. **Fill in all required sections** — including the safety block if your guide involves hardware
4. **Add front-matter** with all required fields
5. **Add the device** to [`_data/devices.yml`](https://github.com/liberatedbread/liberatedbread-web-static/blob/main/_data/devices.yml)
6. **If hardware-liberated:** add STL files to the [`liberatedbread-3d-files`](https://github.com/liberatedbread/liberatedbread-3d-files) repo with `SOURCE.txt`
7. **Open a PR** against [`liberatedbread-web-static`](https://github.com/liberatedbread/liberatedbread-web-static)

## Device Guide Template

Create a new file in `_devices/<slug>.md` with this front-matter:

```yaml
---
layout: device
slug: your-device-slug
title: "Liberate Your [Device Name]"
device_name: "[Full Device Name]"
model: "[Model Number]"
type: software          # "software" or "hardware"
difficulty: 1           # 1 (🍞), 2 (🍞🍞), or 3 (🍞🍞🍞)
time_minutes: 30
firmware: "[Firmware version this guide targets]"   # tested on, or written for

# ONLY IF YOU ACTUALLY VERIFIED IT. Leave these two commented out unless you
# have run every step of the guide on the physical device — copying this
# template as-is must give you an UNVERIFIED guide, which is the normal case.
# Uncomment BOTH together, and only then.
# hardware_verified: true
# last_verified: YYYY-MM-DD

ha_integration: "[Home Assistant integration name]"
safety_block: false     # true for hardware guides
tags: [tag1, tag2]
video_embed:            # Optional
  platform: youtube     # "youtube" or "peertube"
  id: "VIDEO_ID"
  title: "Walkthrough video title"
opengreeniot_spec: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/device-specs/devices/..."
opengreeniot_docs: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/docs/devices/..."
---
```

## Section Checklist

### Software-liberated devices
- [ ] Metadata bar (model, firmware, difficulty, time, and the verified date
      only if the guide claims verification)
- [ ] Safety block (if physical access required)
- [ ] What You're Liberating From
- [ ] Prerequisites
- [ ] Step 1: Lock It Down (router config)
- [ ] Step 2: Adopt It Locally (Home Assistant)
- [ ] Step 3: Verify (offline operation test)
- [ ] Troubleshooting (at least 2 common failure modes)
- [ ] Protocol reference → liberatedbread-protocol-specs

### Hardware-liberated devices
- [ ] ⚠️ Mandatory safety block FIRST
- [ ] What You're Building
- [ ] Parts List (with sourcing links)
- [ ] 3D Printed Parts (with local backup download buttons)
- [ ] Step 0: De-energize / Unplug
- [ ] Assembly Guide (numbered steps with photos)
- [ ] Wiring Diagram (if applicable)
- [ ] Troubleshooting
- [ ] Protocol reference

## Review Process

All device guides are reviewed by a maintainer before merging. We check for:

- Honest verification status — `hardware_verified` set only where the guide was
  genuinely run on the device. An unverified guide is a perfectly good submission;
  an unverified guide wearing a verified badge is not
- Accuracy — a verified guide's steps were run on the exact firmware listed; an
  unverified one names the firmware it was written against and does not claim more
- Safety (mandatory block present for hardware guides)
- Original content (no manufacturer stock photos, no proprietary code)
- Attribution (third-party code/configs credited with links)

## Device Packs

For devices we can't officially support, the community creates configurable **device packs** — YAML files following the [liberatedbread-protocol-specs schema](https://github.com/liberatedbread/liberatedbread-protocol-specs). Learn more in [Appendix D of the design document](https://github.com/liberatedbread/liberatedbread-web-static/blob/main/DESIGN-finalized.md#25-appendix-d-device-pack-yaml-spec).

---

*Not sure where to start? [Open a GitHub Discussion](https://github.com/liberatedbread/liberatedbread-web-static/discussions) and we'll help.*
