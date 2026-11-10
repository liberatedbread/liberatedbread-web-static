---
layout: default
title: SPOTLED or LEDs2RAVE4 app won't install on your old Android?
heading: Your LED panel still works. The app is what's broken.
description: >-
  Can't install SPOTLED or LED CHORD for your LEDs2RAVE4 / Lunchbox Dream Skin
  panel on an older Android phone? Liberated Bread is a free, open-source app
  that talks to the panel over Bluetooth directly, on Android 7.0 and newer.
permalink: /spotled/
redirect_from:
  - /leds2rave4/
---

Google Play says *"Your device isn't compatible with this version"*, or the
SPOTLED app installs and then refuses to open, and your LEDs2RAVE4 / Lunchbox
Dream Skin backpack, LED hat, badge or banner is suddenly a very dark
accessory. That doesn't mean the panel is dead. Its maker's app just stopped
running on your phone.

These panels are plain Bluetooth Low Energy devices. There's no account, no
cloud server and no pairing PIN. Anything that speaks their protocol can
drive them, and that protocol is now
[documented in the open]({{ '/device-specs/' | relative_url }}).

**[Liberated Bread](https://github.com/liberatedbread/liberatedbread-mobile)**
is a free, open-source app (Apache-2.0) from Pigs Can Fly Labs that reads
those specs and talks to the panel itself. It runs on **Android 7.0 (Nougat)
or newer**, and on iPhone, without an account or a vendor app.

## Which panel do you have?

The app that came with your panel tells you which protocol it speaks. The
model name doesn't.

| Your panel | Its vendor app | Liberated Bread |
|---|---|---|
| Dream LED Skin v1 | LED CHORD | **Covered** (SP107E controller): power, colour, brightness |
| Dream LED Skin 2.0 | SPOTLED | **Covered** (SPOTLED panel): brightness, screen orientation |
| Dream Skin 3.0, earlier units | SPOTLED | **Covered**, same as 2.0 |
| Dream Skin 3.0, recent units (serial number reads sideways on the panel) | iLEDColor | **Not yet.** Its protocol isn't mapped |
| Other SPOTLED hats, badges, bags and banner signs | SPOTLED | **Covered**: they share the same Bluetooth service |

LEDs2RAVE4 switched controller boards partway through the Dream Skin 3.0 run.
Their own rule of thumb for telling the two apart: if the serial number shows
up horizontally on the panel, it's the newer iLEDColor board.

## Before you switch

- **One phone at a time.** These panels accept a single Bluetooth connection.
  If the panel doesn't show up, close the old app on every phone and tablet
  that has ever driven it, or switch the panel off and on again.
- **Forget it in Android's Bluetooth settings** if it's listed there. A
  remembered pairing can keep an old phone reconnecting and holding the only
  connection.
- **Anyone nearby can connect.** The panel has no password, so whatever
  Bluetooth app is in range can change what it shows. That's what makes this
  page possible, but keep it in mind before you display anything personal.

## Getting the app

Liberated Bread isn't in Google Play or the App Store yet. Leave your email
and we'll let you know when it is:

{% include subscribe-form.html id="spotled" label="Tell me when the Android app is out:" %}

Comfortable with a build toolchain? The [source is on
GitHub](https://github.com/liberatedbread/liberatedbread-mobile), and the
README walks through building it yourself.

## Honest caveats

The specs for these panels come from reverse engineering: decompiled vendor
apps, Bluetooth captures, and the independent
[python-spotled](https://github.com/iwalton3/python-spotled) library, which
agrees with them byte for byte. They haven't been checked on every panel yet.
If yours does something unexpected, the app shows an *"unexpected
response"* banner and you can send us a report. That's how support for a
panel gets fixed.

The raw specs are public, if you'd rather write your own client:
[SPOTLED panels]({{ '/device-specs/devices/spotled-led-panel.yaml' | relative_url }})
and
[LEDs2RAVE4 / Lunchbox Dream LED]({{ '/device-specs/devices/leds2rave4-lunchbox-led.yaml' | relative_url }}).

---

*Liberated Bread isn't affiliated with LEDs 2 RAVE 4, Lunchbox Packs, SPOTLED
or the makers of LED CHORD or iLEDColor; their names are used here only to
say which hardware this works with. These are guides for hardware you own.
See the [disclaimer]({{ '/disclaimer/' | relative_url }}).*
