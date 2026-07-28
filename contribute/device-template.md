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
firmware: "<exact firmware version you tested>"
ha_integration: "<Home Assistant integration name>"   # optional

# HARDWARE VERIFICATION — see the section below. A guide counts as verified
# only if BOTH of these are present; otherwise it renders a "Not yet
# hardware-verified" notice above its body and its firmware row reads "Written
# for firmware" instead of "Verified on firmware". Leaving them out is not how
# you get a clean page — it is how you get the notice.
hardware_verified: true
last_verified: 2026-07-26              # today, or within the last 30 days

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

opengreeniot_spec: "https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/device-specs/devices/<device>.yaml"
opengreeniot_docs: "https://github.com/PigsCanFlyLabs/opengreeniot-protocol-docs/blob/main/docs/devices/<device>.md"
---
```

## Hardware verification

Set `hardware_verified: true` with a `last_verified` date **once you have run
every step of the guide on the physical device**, on the exact firmware you
listed. That is the same bar the [review checklist]({{ '/contribute/' | relative_url }})
already applies to a contributed guide, so for a normal contribution both keys
belong in your front matter from the start.

The default is the other way round on purpose. A guide with neither key — or
with a date but no flag, or a flag but no date — is treated as unverified and
renders a "Not yet hardware-verified" notice above its body. Nothing can earn a
verification claim by leaving something out. That default exists for guides
drafted from a device specification before anyone has had the hardware in hand:
they stay honest without anyone having to remember to say so.

Do not set the flag because the steps look right, because they worked on a
similar model, or because the vendor documentation says they should. It means
one thing only: this was done, on this device, and it worked.

## Body — software-liberated devices

Start at `##`. The `<h1>`, the metadata bar and the safety block are rendered by
the layout; don't repeat them.

```markdown
## What You're Liberating From

Which cloud service died, what stopped working, and what still works.

## Prerequisites

- The exact hardware and firmware this guide was tested on
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

Link to the opengreeniot-protocol-docs spec for this device.
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
