---
layout: default
title: Disclaimer
description: Legal disclaimers for Liberated Bread — guides for hardware you own.
permalink: /disclaimer/
---

We're not lawyers and we're not trying to sound like them. Here's the deal in plain English:

> **Heads up:** These guides are for hardware you own. Use common sense. Don't do anything illegal. Pigs Can Fly Labs LLC isn't responsible for bricked devices, voided warranties, or angry IoT cloud providers. If you're not sure about something, ask someone who knows. Use caution with all of it, and don't rely on it for anything safety-critical — if a wrong reading or a missed command could hurt someone, this isn't the tool.

## What This Means

- These guides are written for **hardware you already own**. You bought it, it's yours.
- Guides come in two states and both are normal: **verified**, meaning someone ran every step on the device, and **not yet verified**, meaning it was written from specifications and documentation and is waiting for someone with the hardware to confirm it. Every guide says which it is at the top of its own page. An unverified one is a starting point to check rather than a result to rely on. Either way, your mileage may vary.
- Opening a device may void its warranty. We assume you're okay with that.
- Modifying firmware may have legal implications depending on where you live. Check your local laws.
- We don't host proprietary firmware, encryption keys, or copyrighted code.
- Some device guides link to community-created "device packs" for hardware we haven't tested. We don't host or endorse those packs — they're shared by community members for their own hardware.

## Use Caution, Especially for Anything Safety-Critical

This is the one we want to be extra clear about, so it gets its own section.

Everything Liberated Bread publishes — the guides, the protocol specs, the mobile app, the Home Assistant integration — deserves caution. It is hobbyist work, reverse-engineered from the outside, mostly unverified on hardware, and maintained in people's spare time. A spec can decode a byte wrong. The app can show a stale reading. A guide can carry a step nobody has run. We try hard to catch all of that, and we will still miss some. Check what you can, keep the device's own display and manual in reach, and treat a surprising number as a reason to look closer rather than a fact.

That caution turns into "don't rely on this at all" wherever being wrong could hurt someone. The glucose meter in the catalogue is the example we keep coming back to:

- **Using the readings it syncs to decide an insulin dose?** No. Don't trust this. Use the meter's own display and whatever your care team told you.
- **Using them to see which breakfast spikes you less?** Dealer's choice — with the usual caution that a number might be off. If it is, you eat a different sandwich.

The same line runs through everything else: a gas alarm's own buzzer, not a notification that came through our spec; a door you can see, not one you opened from a script; a blood-pressure monitor's screen and your doctor, not a chart we drew. If a mistake could cost a life, a limb or a house, this project is not the tool, and we would rather say so bluntly than have you find out.

The device specs flag medical and other safety-relevant hardware with a `safety_advisory`, and the apps built on them show it before the controls. That warning is a reminder of this section, not a promise that everything around it is safe.

## Affiliate Links

Some pages may include affiliate links to tools, parts, or services. We flag them where we can — usually with a note at the top of the links section — but we can't promise we catch every single one, so assume any link to a store could be an affiliate link:

> **Affiliate Disclosure:** Some links below are affiliate links. If you buy something through them, Liberated Bread may earn a small commission at no extra cost to you.

## Devices We Can't Officially Support

We may not be able to officially support some devices — legal gray areas, regional weirdness, or just not enough time. For those, the community maintains configurable device packs using our YAML specification. These packs are for devices you have permission to work with. See the [Device Pack System](/contribute/#device-packs) for details.

---

*Last updated: October 2026*
