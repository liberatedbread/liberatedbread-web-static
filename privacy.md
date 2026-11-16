---
layout: default
title: Privacy
description: How the Liberated Bread website, mobile app, and Home Assistant integration handle data.
permalink: /privacy/
---

## Our Policy in One Sentence

**Liberated Bread does not run analytics, advertising trackers, or a telemetry service.** The mobile app does not send us your device data or precise location. The optional requests it can make to third parties are listed below.

## What We Don't Do

- **No analytics.** No Google Analytics, no Plausible, no server-side analytics. We don't know how many people visit the site, which pages they read, or where they come from.
- **No cookies.** We don't set any cookies. There's nothing to consent to because there's nothing being tracked.
- **No third-party scripts.** Every script on this site is our own, served from our domain, and only exists to make the site work (mobile navigation menu, device catalogue filter).
- **No telemetry.** The mobile app and [Home Assistant integration](/ha-plugins/) do not send us device data, usage statistics, or error reports.

## What the Mobile App Does

The Liberated Bread mobile app needs no Liberated Bread account and has no analytics or advertising SDK. Device control happens directly over Bluetooth or your local network, not through a Liberated Bread server. Device settings and credentials stay on your phone, using the platform's secure storage where available.

The app is not offline-only. It makes these connections beyond your own devices, each optional or anonymous:

- An **anonymous request to liberatedbread.com** for the promotional banner configuration. Like this website, that file is served by GitHub Pages (see [Hosting](#hosting)). The banner links to our shop page, which carries affiliate links; it is not an advertising or tracking SDK.
- A **device-profile pack download**, only if you install one, from GitHub or a URL you enter.
- A connection to **your own Home Assistant server**, only if you configure it.
- A **one-time sign-in to iRobot's cloud**, only if you choose that route for a robot vacuum instead of entering its local details yourself. Your vendor account credentials go to iRobot so the app can retrieve the robot's local password; the app does not send them to Liberated Bread or retain your vendor account password.
- A **repeater search you start** on the Radio tab. The app reads your location once in the foreground and works out the US state or states in range on your phone. Only those state codes go to the directories you have enabled: myGMRS anonymously, and RepeaterBook with your own access token if you supplied one. Saving a RepeaterBook token also checks it with RepeaterBook once. Precise coordinates never leave your phone. The last position is stored only on your phone, rounded to about 1 km, until you tap **Forget location**.

These third-party services operate under their own privacy policies. The app does not send them your device-control history.

## What the Home Assistant Integration Does

The Liberated Bread custom integration for Home Assistant (`liberated_bread`):

- Communicates **only with devices on your local network** via BLE, WiFi (SSDP/mDNS), or serial
- Does **not** connect to any external server, cloud service, or telemetry endpoint
- Does **not** send device data, usage statistics, or error reports anywhere

## Hosting

This website is hosted on **GitHub Pages**. GitHub may collect [technical visitor data](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages#data-collection) as part of serving the site. We don't have access to that data and don't want it.

## Mailing List

If you subscribe to the mailing list via [pcfweb](https://www.pigscanfly.ca/), your email address is stored by Pigs Can Fly Labs LLC. See the [pcfweb privacy policy](https://www.pigscanfly.ca/privacy) for details. Unsubscribe any time.

## Changes

If this policy ever changes, we'll announce it. The point of Liberated Bread remains local-first control without a required cloud account.

*Last updated: 2026-10-31*
