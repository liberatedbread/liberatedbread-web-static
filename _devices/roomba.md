---
layout: device
slug: roomba
title: "Liberate Your Wi-Fi Roomba"
device_name: "iRobot Roomba (Wi-Fi models)"
model: "690 / 890 / 960 / 980 / e5 / i3–i8 / j7 / j9 / s9"
type: software
difficulty: 2
time_minutes: 30
firmware: "2.x (900-series lineage) and 3.x (i/j/s lineage)"
ha_integration: roomba
safety_block: false
tags: [irobot, roomba, vacuum, wifi, mqtt, dorita980]
protocol_spec: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/device-specs/devices/irobot-roomba.yaml"
protocol_docs: "https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/docs/devices/irobot-roomba.md"
---

<!--
  Metadata bar and verification status come from _layouts/device.html.

  NOTE ON STEP ORDER: this guide deliberately does NOT follow the template's
  "Step 1: Lock It Down" ordering. Getting the robot's password can go through
  iRobot's servers, so blocking first would mean unblocking to finish. The
  reason is stated in the body rather than left for the reader to discover.
-->

## What You're Liberating From

Your Roomba already runs a full local API. It's an MQTT broker, on the robot,
on TCP 8883 — the same channel the iRobot app uses when your phone is on the
same Wi-Fi. It needs no account, no internet, and no permission. It has been
there since the 980.

So there's nothing to fix. What there is, is something to protect.

iRobot filed Chapter 11 in December 2025 and was bought by Picea Robotics in
January 2026. More to the point: the **2025 model line — Roomba 105, 205,
Combo 405 — ships with the local broker removed.** Connect to 8883 on one of
those and you get connection refused. Not a timeout. There is nothing there.

Your robot has something the new ones don't, and the delivery mechanism for
taking it away is a firmware update. This guide gets the credentials out of
your robot, gets the robot off the internet, and connects it to Home Assistant
— in that order, for a reason.

> **This is [dorita980](https://github.com/koalazak/dorita980)'s work.**
> [koalazak](https://github.com/koalazak) reverse-engineered every part of what
> follows: the discovery probe, the password handshake, the command vocabulary.
> [pschmitt/roombapy](https://github.com/pschmitt/roombapy) carried it into
> Python and is what Home Assistant actually runs. We wrote a guide around
> their work; they did the work.

## Prerequisites

- A **Wi-Fi Roomba from 2024 or earlier** — 690, 890, 960, 980, e5/e6, i3–i8,
  j7/j9, s9, or a Braava jet m6. If yours is a 105, 205 or Combo 405, stop
  here: there is no local broker to talk to.
- The robot already on your Wi-Fi (if it's factory-fresh, use the iRobot app
  once to get it on the network, then come back).
- A computer with Node.js, **or** the Liberated Bread app. Either can pull the
  password.
- A router where you can block one device from the internet — see
  [Keep It Off the Internet](/firewall/).
- Home Assistant, if that's where you want it to end up.

## Step 1: Get the Password First

**Do this before you touch the firewall.** One of the two routes below goes
through iRobot's servers, and if you block the robot first you'll be
temporarily unblocking it to finish this step. The other route is entirely
local, but it doesn't work on every robot, so you may end up needing the first
one anyway.

You are collecting two values:

- **BLID** — the robot's identity, and the MQTT username
- **Password** — a long per-robot secret that looks like
  `:1:1486937829:gktkDoYpWaDxCfGh`

**Write both down.** The password only changes on a factory reset, and it's
what Home Assistant, dorita980, and everything else will ask you for. The
Liberated Bread app shows you a screen built for exactly this — screenshot it.

### Route A: the HOME button (no account)

Works offline, needs nothing from iRobot.

1. Put the robot **on its dock**, powered on.
2. **Close the iRobot app** on every phone in the house. The robot serves one
   client at a time and the app will hold the slot.
3. **Hold the HOME button for about two seconds**, until the robot plays a
   series of tones. Release.
4. Immediately, on a computer on the same network:

```bash
npm install -g dorita980
get-roomba-password <robot-ip>
```

It prints the BLID and the password. In the Liberated Bread app, this is the
"Hold the HOME button" path in the Roomba adoption wizard — same handshake,
same result, and it retries for you.

If it fails, re-hold the button and try again before assuming it can't work.
j-series firmware is known to drop the first attempt or two.

### Route B: your iRobot account (extraction only)

If the button route won't complete, log in once and read the same values out of
iRobot's API:

```bash
get-roomba-password-cloud <your-irobot-email> <your-irobot-password>
```

This returns every robot on the account with its BLID and password. **That is
all it's for** — nothing about controlling the robot afterwards needs an
account, and the credentials are identical to what Route A would have given
you. The Liberated Bread app offers this too, and never stores your iRobot
account password; it uses it for the one login call and throws it away.

Once you have the credentials, you never need the account again. Which is
convenient, because in the next step you're going to make it unreachable.

## Step 2: Lock It Down

Now block the robot from the internet.

The full how-to, for UniFi, MikroTik, OPNsense/pfSense, OpenWrt, Firewalla and
consumer routers, is on [Keep It Off the Internet](/firewall/). The short
version:

1. Give the robot a **fixed IP** (a DHCP reservation is fine).
2. Add a firewall rule blocking that IP from the WAN, **leaving LAN traffic
   alone**.

What keeps working: everything in this guide. Local MQTT on 8883, discovery on
UDP 5678, all your commands and all your sensors.

What stops: the iRobot app from outside your house (it still works on your
Wi-Fi), cloud-stored schedules, map sync on the i/j/s series, and firmware
updates. That last one is the entire point.

> **Don't try to block only the update server.** Vendors move update traffic
> between hosts without announcing it, and a blocklist that's one host short is
> a firmware update that arrives anyway. Block outbound wholesale.

## Step 3: Adopt It Locally

> **One thing should hold the robot.** It accepts a single local connection at
> a time, and a new one evicts the old. Two things talking to it directly means
> both take turns being locked out — including your own iRobot app. So pick one
> owner and let everything else go through it. That is the thread running
> through this whole section.

### Home Assistant — start here

If you run Home Assistant, this is the answer, and it stays the answer even if
you also want the phone app.

**Settings → Devices & Services → Add Integration → iRobot Roomba and Braava**.
It asks for the host, the BLID and the password from Step 1. That's it —
Home Assistant's `roomba` integration is `local_polling`, so it talks to the
robot and nothing else.

You get a vacuum entity (start, pause, stop, return to base, locate), plus
battery and status sensors.

Three reasons to make it the owner rather than one option among several:

- **It settles the one-client problem.** HA holds the connection; everything
  else asks HA. Nothing gets evicted.
- **It survives the firewall.** If you put the robot on its own VLAN — the
  natural end of the [firewall guide]({{ '/firewall/' | relative_url }}) — HA
  can still be on a network that reaches it, while your phone roams elsewhere.
- **It works with old firmware.** Some robots only offer a cipher modern phone
  TLS stacks have dropped. HA's Python stack can still negotiate it.

### Liberated Bread app

Open the Wi-Fi tab and scan. The robot answers a broadcast probe on UDP 5678,
so it shows up by name without you typing an address. Tap it, run through the
adoption wizard, and the credentials go into your phone's keychain — not into
preferences, not into a file.

**If you already have Home Assistant, point the app at it instead** — on a
robot's screen, choose "How to reach this robot" and pick the Home Assistant
entity. You get the same panel, the same buttons and the same readings, but the
commands travel to HA and HA talks to the robot. Two things worth knowing:

- The app then needs **no BLID and no password at all** for that robot. HA
  holds them. There is nothing on your phone to leak.
- It works for robots the phone **cannot reach** — a separate VLAN, a
  guest SSID with client isolation. The panel does not care, because it is not
  the thing dialling the robot.

Straight-at-the-robot is the right choice when the app is the only thing
driving it. If anything else is, or might be, put that other thing in front.

### Command line

`get-roomba-password` above works straight from a global install — npm links
its binary onto your `PATH`. Using dorita980 as a *library* is different:
`require` does not look in npm's global directory, so the snippet below sets
`NODE_PATH` to it rather than making you install the package a second time.

```bash
# One-off, using dorita980 directly
BLID=<blid> PASSWORD=<password> ROBOT_IP=<ip> \
NODE_PATH="$(npm root -g)" \
  node -e "
    const d = require('dorita980');
    const r = new d.Local(process.env.BLID, process.env.PASSWORD, process.env.ROBOT_IP);
    r.on('connect', () => r.clean().then(() => r.end()));
  "
```

> **One client at a time.** The robot accepts a single local connection and a
> new one evicts the old. If the iRobot app stops working on your Wi-Fi the
> moment Home Assistant connects, that's why — and it's why anything
> long-running should connect, act, and disconnect rather than hold the socket
> open.

### Or: put rest980 in front of it

[rest980](https://github.com/koalazak/rest980) is koalazak's own HTTP wrapper
around dorita980 — same author as the protocol. It holds the robot connection
and answers plain HTTP, so everything else talks to *it* instead of fighting
over the robot:

```bash
docker run -p 3000:3000 \
  -e BLID=<blid> -e PASSWORD='<password>' -e ROBOT_IP=<ip> \
  koalazak/rest980
```

Then `GET /api/local/action/start`, `/dock`, `/pause`, and
`/api/local/info/state`. The Liberated Bread app can be pointed at a rest980
address per robot instead of talking to the robot directly.

This is worth doing in two cases:

- **More than one thing wants the robot.** One client at a time is the rule, so
  an app and a Home Assistant both connecting directly will keep evicting each
  other. One rest980, everything else pointed at it, and the problem goes away.
- **Old firmware the phone can't reach.** If your robot only offers the
  `AES128-SHA256` cipher (see Troubleshooting below), Node can speak to it and a
  phone genuinely cannot. Run rest980 on a computer and the app works again
  through it.

One gap worth knowing: rest980 publishes no endpoint for **locate**, so the
"make it beep" button isn't available in that mode. Everything else is.

## Step 4: Verify

The real test: **unplug your internet**. Not the router — the WAN.

1. With the internet down, send the robot a clean command from Home Assistant
   or the app. It should go.
2. Send it home. It should dock.
3. Check the battery sensor still updates.

Then plug the internet back in and confirm your firewall rule is actually doing
something — your router's firewall log should show blocked connection attempts
from the robot's IP. If it shows nothing at all, the rule may be matching the
wrong thing.

## Troubleshooting

### `get-roomba-password` returns nothing, or an error

The robot wasn't in disclosure mode. Re-hold HOME until you hear the tones —
about two seconds, and the tone is the confirmation, not the clock. Make sure
the robot is **on the dock** and **no phone has the iRobot app open**.

If it fails repeatedly on a j7 or j9, keep trying: that firmware resets the
first connection or two before answering. If it never works, use Route B.

### The password handshake fails before it starts, with a TLS error

Older robot firmware only offers a TLS cipher (`AES128-SHA256`) that modern TLS
libraries have retired. Node.js hits this too, which is why dorita980 ships the
`ROBOT_CIPHERS` and `ROBOT_TLS_LEGACY` environment variables:

```bash
ROBOT_TLS_LEGACY=1 ROBOT_CIPHERS=AES128-SHA256 get-roomba-password <robot-ip>
```

The Liberated Bread app **cannot** work around this directly — the phone TLS
stack it uses doesn't offer that cipher and gives no way to ask for it. If the
app tells you the robot needs a legacy cipher, that's honest, not a bug. Two
things do work:

- Pull the password with dorita980 or roombapy on a computer, then paste it
  into the app.
- Run [rest980](#or-put-rest980-in-front-of-it) on that computer and point the
  app at it. Node selects the old cipher happily, so the robot becomes
  reachable again — through the server rather than directly.

### Home Assistant connects, then drops

Something else took the connection slot. Close the iRobot app, and check you
don't have a second integration or a `rest980` container pointed at the same
robot.

### The robot vanished from discovery after I set up VLANs

Discovery is a UDP **broadcast** on port 5678, and broadcast doesn't cross
VLANs. Enabling mDNS reflection doesn't help — that's a different protocol.
Either keep whatever is controlling the robot on the same VLAN, or skip
discovery and configure it by its fixed IP, which works fine.

### It worked, then stopped after a factory reset

A factory reset mints a **new** password. Go back to Step 1.

## Going Further

- **Don't factory reset it casually.** Reset changes the password and, on the
  mapping models, loses your maps.
- **Keep the credentials somewhere you'll find them.** They outlive the app,
  the phone, and quite possibly the company.
- **Buying another one?** Used 2024-and-earlier robots are cheap and have a
  local API. The new ones don't. That asymmetry is unlikely to improve.
- **Rooms and maps** aren't covered here. dorita980 can drive per-room cleaning
  on the i/j/s series, but the map identifiers come out of the vendor app —
  see its README if that's what you're after.

## Protocol Reference

- Machine-readable spec:
  [`device-specs/devices/irobot-roomba.yaml`](https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/device-specs/devices/irobot-roomba.yaml)
- Protocol documentation:
  [`docs/devices/irobot-roomba.md`](https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/docs/devices/irobot-roomba.md)
- [koalazak/dorita980](https://github.com/koalazak/dorita980) — the reference
  implementation, and the source of everything above
- [koalazak/rest980](https://github.com/koalazak/rest980) — a REST API over it
- [pschmitt/roombapy](https://github.com/pschmitt/roombapy) — the Python
  implementation behind Home Assistant
- [Home Assistant Roomba integration](https://www.home-assistant.io/integrations/roomba/)

---

*Written against firmware 2.x and 3.x and Home Assistant 2026.7, from
[koalazak/dorita980](https://github.com/koalazak/dorita980) and
[pschmitt/roombapy](https://github.com/pschmitt/roombapy) — the projects that
worked this protocol out. Not yet run end to end on a robot by us.*
