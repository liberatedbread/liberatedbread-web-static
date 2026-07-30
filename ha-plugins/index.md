---
layout: default
title: Home Assistant Integration
description: Liberated Bread custom integration for Home Assistant — local control of liberated IoT devices via BLE, WiFi, and serial.
permalink: /ha-plugins/
---

The **Liberated Bread Home Assistant integration** (`liberated_bread`) connects liberated IoT devices to Home Assistant — fully local, no cloud dependencies. It reads machine-readable [protocol specs](/device-specs/) from the `liberatedbread-protocol-specs` repository and auto-discovers supported devices on your network.

## What It Does

- **Auto-discovers** BLE, WiFi (SSDP/mDNS), and serial devices that match a known protocol spec
- **Creates Home Assistant entities** — sensors, switches, lights, climate, fans, numbers, selects — mapped from each spec's capabilities
- **Runs entirely local** — no cloud calls, no telemetry, no internet required after setup
- **Protocol-driven** — device support is defined in YAML specs, not hardcoded Python. Adding a device = adding its spec YAML

## Supported Transport Layers

| Transport | Discovery | Examples |
|-----------|-----------|---------|
| **BLE** | Bluetooth advertisement scan | Ember Mug, SwitchBot, Govee sensors, LED strips, heated gear |
| **WiFi** | SSDP + mDNS | WeMo switches, Frigidaire AC, Vector Robot, Roku |
| **Serial / UART / CAN** | Manual config entry | Bafang BBS02, Fardriver, TSDZ2, Bosch eBike, BMW/Triumph motorcycle |

## Entity Types

The integration maps protocol-spec capabilities to these Home Assistant platforms:

`sensor` · `binary_sensor` · `switch` · `light` · `climate` · `fan` · `number` · `select`

## Installation

### HACS (recommended)

1. Add `https://github.com/liberatedbread/ha-plugins` as a custom repository in HACS
2. Install "Liberated Bread" from the HACS integrations list
3. Restart Home Assistant

### Manual

```bash
cd /path/to/homeassistant/config/custom_components
git clone https://github.com/liberatedbread/ha-plugins.git liberated_bread_tmp
mv liberated_bread_tmp/custom_components/liberated_bread .
rm -rf liberated_bread_tmp
```

Then restart Home Assistant.

### Requirements

- Home Assistant **2026.2** or later
- For BLE devices: a supported Bluetooth adapter with the `bluetooth` integration enabled
- For WiFi devices: devices must be on the same local network as Home Assistant

## Device Coverage

{%- comment -%}
  Counted from the files actually in the device-specs/ subtree, the same way
  device-specs.md counts them — never hardcoded. A hardcoded number here said
  58 while the subtree held 51 and upstream held 69, so all three disagreed.
  A subtree pull now moves this number with no edit to this file.
{%- endcomment -%}
{%- assign spec_count = site.static_files
   | where_exp: "f", "f.path contains '/device-specs/devices/'"
   | size -%}

The integration is driven by the protocol specs vendored from
`liberatedbread-protocol-specs` as a git subtree — the
[{{ spec_count }} specs published here]({{ '/device-specs/' | relative_url }}) —
covering:

- **Smart plugs & switches**: WeMo, Govee
- **Lighting**: LED strips, bulbs, panels, signs, masks, motorcycle LEDs
- **Climate**: Frigidaire AC, Gerbing ThermoGauge, Hotwired heated gear
- **Kitchen**: Ember Mug, Chef IQ, iBBQ meat thermometer, smart scales
- **E-bikes & vehicles**: Bafang, Tongsheng, Bosch, Fardriver, NIU scooter, BMW/Triumph diagnostics
- **Sensors**: Xiaomi thermometers/hygrometers/plant sensors, Govee thermo, SwitchBot, iTag tracker, pulse oximeter
- **Printers & displays**: Cat printer, Niimbot, Fichero, Divoom Pixoo, iDotMatrix, Magic Display
- **Hubs & bridges**: Hue, SmartThings, Rachio, Enphase, Dyson, Lutron

[Browse all device specs →](/device-specs/)

## Adding Support for New Devices

New devices are supported by adding a protocol spec YAML. See the [contribution guide](/contribute/) and the [protocol-specs README](https://github.com/liberatedbread/liberatedbread-protocol-specs).

---

> **⚠️ Pre-release status:** This integration is under active development. Device specs, discovery, and control paths are validated against decompiled APKs and protocol documentation but have **not been tested against physical hardware** for most devices. Do not deploy to production without testing your specific device first. [Report issues →](https://github.com/liberatedbread/ha-plugins/issues)
