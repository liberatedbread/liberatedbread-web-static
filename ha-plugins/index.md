---
layout: default
title: Home Assistant Plugins
description: YAML configs and scripts for integrating liberated devices with Home Assistant.
permalink: /ha-plugins/
---

YAML configurations and override scripts for liberated devices. Copy these into your Home Assistant setup.

## WeMo Local Control

Drop this into your `configuration.yaml` to keep WeMo switches working without Belkin's cloud:

```yaml
# Home Assistant configuration.yaml
wemo:
  discovery: true
  static:
    - 192.168.1.50   # Replace with your WeMo's IP

# Block cloud access at the router level (firewall rule),
# NOT in Home Assistant — see the device guide for details.
```

## Coming Soon

- **Eufy Cam RTSP Config** — Stream directly to Frigate without the Eufy cloud
- **TP-Link Kasa Local** — Bypass the Kasa app entirely
- **Wyze Cam v3 RTSP** — Enable the hidden RTSP firmware

---

*All configs tested on Home Assistant 2026.7. File an issue if a config doesn't work with your setup.*
