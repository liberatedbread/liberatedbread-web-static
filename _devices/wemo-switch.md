---
layout: device
slug: wemo-switch
title: "Liberate Your Belkin WeMo Insight Switch"
device_name: "Belkin WeMo Insight Switch"
model: "F7C029"
type: software
difficulty: 1
time_minutes: 15
firmware: "WeMo_WW_2.00.11426.PVT-OWRT-SNS"
ha_integration: pywemo
safety_block: false
tags: [wemo, belkin, smart-plug, wifi]
protocol_spec: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/device-specs/devices/wemo-devices.yaml"
protocol_docs: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/docs/devices/wemo-devices.md"
---

<!--
  Device metadata bar is rendered by _layouts/device.html from front-matter.
  Content below is the liberation guide body.
-->

## What You're Liberating From

In January 2026, Belkin shut down its WeMo cloud servers. The WeMo Insight Switch (model F7C029) — a Wi-Fi smart plug with energy monitoring — stopped responding to the WeMo app and cloud-dependent integrations. But the hardware is fine. The switch still works, still connects to Wi-Fi, and still responds to local UPnP commands. It just needs to be told to stop phoning home and start listening locally.

This guide locks your WeMo switch to LAN-only operation and connects it to Home Assistant via PyWeMo. No cloud. No app. No account.

## Prerequisites

- A Belkin WeMo Insight Switch (F7C029) on firmware `WeMo_WW_2.00.11426.PVT-OWRT-SNS`
- A router where you can configure firewall rules (most consumer routers can do this)
- Home Assistant (any recent version)
- The switch must already be connected to your Wi-Fi (if it's factory-reset, use the WeMo app one last time to get it on your network, then proceed)

## Step 1: Lock It Down

The goal is to block the switch from reaching Belkin's servers while allowing local traffic.

### Block WAN access for the WeMo

Log into your router's admin panel and create a firewall rule:

1. Find your WeMo switch's IP address (check your router's DHCP client list)
2. Create an **outbound firewall rule** that blocks all WAN (internet) traffic from that IP
3. Make sure the rule allows LAN traffic (otherwise Home Assistant can't reach it)

Alternative: if your router supports it, put the WeMo on a separate VLAN with no internet access.

### Verify the block

After applying the rule, confirm the switch can't reach the internet:

```bash
# From a computer on the same network, try to reach Belkin's old API through the switch:
# The switch should no longer respond to cloud pings
```

Your WeMo switch is now LAN-only. It can't phone home, but it's still reachable from within your network.

## Step 2: Adopt It Locally

### Add to Home Assistant

Home Assistant has built-in PyWeMo support. Add this to your `configuration.yaml`:

```yaml
# Home Assistant configuration.yaml
wemo:
  discovery: true
  static:
    - 192.168.1.50   # Replace with your WeMo's IP address
```

Restart Home Assistant. The WeMo switch should appear automatically as a `switch` entity.

### Verify entity

Check that the switch entity works:

```yaml
# Developer Tools → States
switch.wemo_insight_switch   # Should show current state
```

Toggle it on and off from Home Assistant. It should respond within 1–2 seconds — entirely local, no cloud delay.

## Step 3: Verify

### Test offline operation

1. Temporarily disconnect your internet (unplug WAN from router)
2. Toggle the WeMo switch from Home Assistant
3. It should still work — the switch and HA are communicating entirely within your LAN

### Test energy monitoring

The Insight model reports power usage. Check the `sensor.wemo_insight_switch_current_power_w` entity in Home Assistant.

### Reconnect internet

Plug WAN back in. The firewall rule still blocks the WeMo from phoning home, so nothing changes. Your switch is permanently liberated.

## Troubleshooting

### Switch not discovered

- Double-check the static IP address in `configuration.yaml`
- Verify the switch is on the same subnet as Home Assistant
- Check your firewall rule isn't blocking LAN traffic between HA and the WeMo

### Switch appears but won't toggle

- The WeMo may need a power cycle — unplug it for 10 seconds and plug it back in
- Check that the firmware version matches (`WeMo_WW_2.00.11426.PVT-OWRT-SNS`)
- If the switch was recently cloud-connected, it may take a few minutes to "give up" on the cloud and start responding locally

### Energy monitoring not showing

- The Insight's energy monitoring uses a separate UPnP service — verify your firewall isn't blocking UPnP multicast on the LAN (it shouldn't be)

## Going Further: ESP32 Hardware Replacement

This guide keeps your WeMo switch working with its original firmware. If you want to go further — replace the stock firmware entirely for full local control — an ESP32 hardware replacement is the next step. That involves opening the switch and flashing custom firmware, so it is a separate hardware-liberation guide carrying the full safety block. It has not been published yet — it will appear in the [device index](/devices/) when it lands.

## Protocol Reference

The WeMo Insight Switch communicates via UPnP over Wi-Fi. Full protocol specification:

- [WeMo Device Spec (liberatedbread-protocol-specs)](https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/device-specs/devices/wemo-devices.yaml)
- [WeMo Protocol Documentation](https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/docs/devices/wemo-devices.md)

---

*Written against firmware `WeMo_WW_2.00.11426.PVT-OWRT-SNS` and Home Assistant 2026.7, from
Belkin’s UPnP device documentation and the PyWeMo integration.*
