---
layout: default
title: Device Guide Template
heading: Device Guide Template
description: Copy-paste starting point for a new Liberated Bread device liberation guide.
permalink: /contribute/device-template/
sitemap: false
---

Copy this file to `_devices/<your-slug>.md` and fill it in. Delete the sections
that don't apply to your device, but do not delete the front matter — the
metadata bar, the safety block, and the device index all read from it.

See the [contribution guide]({{ '/contribute/' | relative_url }}) for the review
checklist, and remember to add a matching entry to `_data/devices.yml`.

## Front matter

```yaml
---
layout: device
slug: your-device-slug                 # must match the filename and devices.yml
title: "Liberate Your <Device Name>"
device_name: "<Full Device Name>"
model: "<Model Number>"
type: software                         # software | hardware
difficulty: 1                          # 1, 2 or 3
time_minutes: 30
firmware: "<exact firmware version this guide targets>"   # tested on, or written for
ha_integration: "<Home Assistant integration name>"   # optional

# HARDWARE VERIFICATION — ONLY IF YOU ACTUALLY VERIFIED IT. See the section
# below. These stay COMMENTED OUT unless you have run every step of the guide on
# the physical device: copying this template as-is must give you an UNVERIFIED
# guide, and that is a normal, expected guide, not a lesser one. Its page shows a
# "Not yet verified on hardware" status block and its firmware row reads "Written
# for firmware". Uncomment BOTH together, and only once you have genuinely done
# it. `hardware_verified` must be a real YAML boolean, unquoted.
# hardware_verified: true
# last_verified: 2026-07-26            # today, or within the last 30 days

# TRUE for every hardware guide. TRUE for a software guide only if any step
# requires opening the device or touching the PCB. This is what renders the
# mandatory safety block — see DESIGN §10.1.
safety_block: false

tags: [tag1, tag2]

# Optional — omit the whole block if there is no video.
video_embed:
  platform: youtube                    # youtube | peertube
  id: "VIDEO_ID"
  # instance: "https://your.peertube.instance"   # peertube only
  title: "<Walkthrough video title>"

# Optional — hardware guides that ship printable parts.
stl_files:
  - filename: "part-name.stl"
    description: "What it is (material, infill)"

opengreeniot_spec: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/device-specs/devices/<device>.yaml"
opengreeniot_docs: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/docs/devices/<device>.md"
---
```

## Hardware verification

**You may submit a guide you have not run on the hardware.** That is fine, it is
expected, and it is how most guides arrive. Research it properly, write it
carefully, and leave `hardware_verified` and `last_verified` out. The page then
carries a "Not yet verified on hardware" status block saying so plainly, and its
firmware row reads "Written for firmware" rather than "Verified on firmware".
Nothing about that marks the guide as second-rate — it is the ordinary state of
a new guide, and someone with the device can mark it verified later.

What you must not do is claim more than you did. Set `hardware_verified: true`
with a `last_verified` date **only once you have run every step of the guide on
the physical device**, on the exact firmware you listed. Making that claim is
what binds you to the strict version of the accuracy standard: you owned the
hardware, you followed your own steps, and they worked.

Both keys are needed together. A guide with neither — or with a date but no
flag, or a flag but no date — is treated as unverified. That direction is
deliberate: with most of the catalogue unverified at any given time, a scheme
where silence meant "verified" would mislabel nearly every page. Verification
is a claim you write down, never one a guide inherits by leaving a key out.

Do not set the flag because the steps look right, because they worked on a
similar model, or because the vendor documentation says they should. It means
one thing only: this was done, on this device, and it worked.

### Marking a guide verified later

One edit, one file. In `_devices/<slug>.md`, add the two keys to the front
matter:

```yaml
hardware_verified: true
last_verified: 2026-07-26
```

That is the whole change. The status block disappears, the metadata bar grows a
"Verified:" row, and the firmware label flips to "Verified on firmware" — all
from the same condition. There is no second file to remember: `_data/devices.yml`
holds card fields only and no verification state, and no guide's prose depends
on the flag.

## Body — software-liberated devices

Start at `##`. The `<h1>`, the metadata bar and the safety block are rendered by
the layout; don't repeat them.

```markdown
## What You're Liberating From

Which cloud service died, what stopped working, and what still works.

## Prerequisites

- The exact hardware and firmware this guide targets — the version you ran it on
  if you verified it, otherwise the version you wrote it against
- Any tools, accounts or network access the reader needs first

## Step 1: Lock It Down

Router-level firewall or VLAN rules that stop the device phoning home.

## Step 2: Adopt It Locally

Home Assistant (or other local controller) configuration.

## Step 3: Verify

How to prove it works with the internet unplugged.

## Troubleshooting

At least two realistic failure modes, each with a fix.

## Protocol Reference

Link to the liberatedbread-protocol-specs entry for this device.
```

## Body — hardware-liberated devices

```markdown
## What You're Building

## Parts List

| Part | Quantity | Notes |
|---|---|---|

## 3D Printed Parts

Print settings: material, layer height, infill, perimeters, supports.

## Step 0: De-energize / Unplug

Always the first step. Set `safety_block: true` so the mandatory callout renders.

## Assembly Guide

Numbered steps with original photos.

## Wiring Diagram

If applicable.

## Troubleshooting

## Protocol Reference
```
