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

Another thing you can do is grab a Bluetooth (BTLE) capture of the companion app talking to the device and send it along — often that trace is enough to work out the protocol. You can capture on [Android](https://source.android.com/docs/core/connect/bluetooth/verifying_debugging) (turn on the Bluetooth HCI snoop log in Developer Options), on [iOS](https://developer.apple.com/bug-reporting/profiles-and-logs/) (install Apple's Bluetooth logging profile and use PacketLogger), or with a dedicated sniffer like Nordic's [nRF Sniffer for Bluetooth LE](https://www.nordicsemi.com/Products/Development-tools/nRF-Sniffer-for-Bluetooth-LE).

> **Strip out accounts and private info first.** A Bluetooth capture can contain account credentials, tokens, email addresses, location, or other personal data. Scrub anything sensitive before you share it — and if the device or app requires an account, we recommend creating a temporary account with non-private info and pairing with that, so nothing personal ends up in the trace to begin with.

## Does this require jailbreaking or rooting?

**No.** Liberated Bread works entirely through standard protocols — connecting to devices over your local WiFi network or Bluetooth. No device modifications, no custom firmware, no rooting required. For WiFi devices, the only "modification" is a firewall rule on your router to block cloud access — see [Keep It Off the Internet](/firewall/) for how to write that rule on UniFi, MikroTik, OPNsense, OpenWrt and the rest.

## Why block a device from the internet at all?

Because an over-the-air firmware update is the most likely way local control disappears. It has already happened: TP-Link closed port 9999 on newer Kasa hardware, and iRobot's 2025 Roombas ship with no local MQTT broker at all. A device that can't reach the vendor keeps the protocol it shipped with. [Keep It Off the Internet](/firewall/) walks through doing that without breaking discovery or local control.

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

## Is this connected to the bread price-fixing case?

No. Liberated Bread is not affiliated with, party to, or in any way involved in the [Canadian bread price-fixing scandal](https://en.wikipedia.org/wiki/Bread_price-fixing_in_Canada) — the arrangement to inflate the price of packaged bread from roughly 2001 to 2015. We fix toasters, not prices.

We do think it rhymes, though. Canada Bread [pleaded guilty and was fined $50 million](https://www.ppsc-sppc.gc.ca/eng/nws-nvs/2023/21_06_23.html); Loblaw and George Weston admitted participating, got immunity for reporting it, and later agreed to a $500-million class-action settlement; the other companies named have denied wrongdoing, and those allegations remain allegations. Allegedly, then, that is how far companies will go to keep you from enjoying toast at a reasonable price — with no internet required. Add the internet and you get our beat instead: a working appliance bricked because a vendor turned off a server. See [About](/about/#not-that-bread-thing).
