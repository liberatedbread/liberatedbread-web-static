---
layout: default
title: FAQ
description: Frequently asked questions about Liberated Bread — local device liberation, Home Assistant integration, and community contributions.
permalink: /faq/
---

## What is Liberated Bread?

Liberated Bread publishes step-by-step guides for liberating abandoned IoT devices from dead cloud services. When a company shuts down its cloud, "smart" devices become paperweights. We show you how to keep them working — offline, local, and free.

## Is this legal?

Yes. These guides are for hardware **you own**. The techniques documented here (local network control, BLE direct communication, open firmware) are standard reverse-engineering and interoperability practices. We do not distribute proprietary code, encryption keys, or copyrighted firmware.

## Do I need to be technical?

Our guides range from difficulty level 1 (🍞 — basic router config and copy-paste YAML) to level 3 (🍞🍞🍞 — command-line tools, custom firmware, hardware mods). Start with a level-1 guide like the WeMo switch liberation and work up.

## What devices are supported?

{%- assign spec_count = site.static_files
   | where_exp: "f", "f.path contains '/device-specs/devices/'"
   | size -%}

See the [device catalogue](/devices/) for currently-documented devices. The [Home Assistant integration](/ha-plugins/) is driven by our **[{{ spec_count }} protocol specs]({{ '/device-specs/' | relative_url }})** covering sensors, switches, lights, climate devices, e-bikes, printers, and more.

## My device isn't listed. Can you add it?

Probably! If your device has an Android companion app, we can decompile it to extract the Bluetooth or WiFi protocol. [Open a GitHub Discussion](https://github.com/liberatedbread/liberatedbread-web-static/discussions) with the device name and model number. If you're technical, see the [contribution guide](/contribute/).

## Does this require jailbreaking or rooting?

**No.** Liberated Bread works entirely through standard protocols — connecting to devices over your local WiFi network or Bluetooth. No device modifications, no custom firmware, no rooting required. For WiFi devices, the only "modification" is a firewall rule on your router to block cloud access.

## Will my device lose features without the cloud?

Sometimes. Cloud-dependent features (voice assistants, remote-from-anywhere access, manufacturer analytics) won't work. But the core functionality — turning switches on/off, reading sensors, changing colors — works locally and usually faster without the cloud round-trip.

## How do I access my devices away from home?

Use Home Assistant's [remote access](https://www.home-assistant.io/docs/configuration/remote/) (Nabu Casa, VPN, or reverse proxy). Liberated Bread devices are regular Home Assistant entities, so they work with whatever remote access solution you already use.

## Can I help?

Absolutely. We need:
- **Device testing** — run a guide on your physical device and report back
- **New guides** — see the [contribution guide](/contribute/)
- **Protocol specs** — help reverse-engineer device protocols
- **Code** — improve the [Home Assistant integration](https://github.com/liberatedbread/ha-plugins)

Join the `#liberated-bread` channel on the [Pigs Can Fly Labs Discord](https://www.pigscanfly.ca/discord/).

## Is Liberated Bread free?

Yes. All guides, protocol specs, and the Home Assistant integration are free and open source (MIT licensed). Liberated Bread is a project of Pigs Can Fly Labs LLC — a small business, not a non-profit. We publish free content because we believe you should own your devices.

## What's with the name?

*Liberated Bread* is an homage to Cory Doctorow's novella [*Unauthorized Bread*](https://craphound.com/unauthorizedbread/), about refugees who jailbreak locked-down appliances. The ethos: you own your devices, not the manufacturer's cloud.
