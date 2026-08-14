---
layout: default
title: Block the Cloud, Keep the Device
heading: Keep It Off the Internet
description: How to stop a smart device phoning home — and taking a firmware update that removes local control — without breaking it on your own network. UniFi, MikroTik, OPNsense, OpenWrt, Firewalla and DNS sinkholes, with a Roomba worked example.
permalink: /firewall/
---

Most of the guides on this site end up in the same place: the device speaks a
perfectly good local protocol, and the only thing that can take it away is a
firmware update pushed from a server you don't control.

So don't let it reach the server.

This page is the shared how-to. Every device guide links here instead of
re-explaining it, and the worked example at the bottom is the
[Roomba](/devices/roomba/), because it's the case where getting the order
wrong actually costs you something.

## What you're blocking, and what you're not

You are blocking one thing: **the device's ability to open connections to the
internet.** That's what carries over-the-air firmware updates, telemetry, and
the vendor's remote-access path.

You are *not* blocking your own LAN. Local control — the whole point — is your
phone or your Home Assistant box talking to the device across your own network.
None of that leaves the house, and none of it should be touched.

Three things have to keep working:

| | Why |
|---|---|
| **Unicast traffic on your LAN** | The actual control channel. HTTP, MQTT, whatever the device speaks. |
| **Multicast and broadcast on the device's subnet** | mDNS (5353), SSDP (1900) and vendor discovery probes are how anything finds the device in the first place. |
| **DHCP, and often DNS** | A device that can't get a lease falls off the network entirely. Let it resolve names; it just won't be able to connect to them. |

> **The honest limit of DNS-only blocking.** Sinkholing hostnames in Pi-hole is
> the easiest thing on this page and the weakest. A device that ignores your
> DHCP-supplied resolver, hardcodes `8.8.8.8`, or uses DNS-over-HTTPS walks
> straight past it. It's a fine belt; the firewall rule is the braces.

### Blocking "just the update server" mostly doesn't work

The tempting version of this is to block one hostname and leave everything else
alone, so the vendor app keeps working from outside the house. In practice:

- Vendors move update traffic between hosts and CDNs without telling you.
- Most of these devices fetch updates from the *same* endpoint they use for
  everything else.
- A blocklist that's one host short is a firmware update that arrives anyway,
  and you find out when local control stops.

Block outbound wholesale. Then decide, per device, whether you actually miss
anything.

## Pick a lever

| Lever | Strength | Cost |
|---|---|---|
| **Block WAN by IP or MAC** | Strong. The device simply can't route out. | Needs a fixed address. Per-device bookkeeping. |
| **Isolate a whole VLAN** | Strongest, and scales to every IoT device at once. | Discovery stops crossing VLANs unless you fix it. Real work. |
| **DNS sinkhole** | Weak on its own. | Trivial. Good as a second layer or a first experiment. |

If you have one Roomba, block by IP. If you have a house full of this stuff,
build the VLAN — you'll do it once instead of thirty times.

Whichever you pick, **give the device a fixed address first**. A DHCP
reservation is fine and is what every recipe below assumes; the point is that a
rule targeting `192.168.1.50` is worthless if tomorrow the device is
`192.168.1.83`.

---

## UniFi (Cloud Gateway, Dream Machine, UXG)

UniFi has moved this UI around repeatedly across Network 7, 8 and 9 releases,
so what follows describes **what the rule has to say**, with the current
setting names. If a menu has moved, you're looking for the rule, not the path.

### 1. Pin the address

Find the device under **Client Devices**, open it, and set a **Fixed IP
Address**. UniFi writes a DHCP reservation.

### 2a. The simple version — one client, one rule

**Settings → Security → Traffic & Firewall Rules → Traffic Rules → Create
Entry**

- **Action**: Block
- **Category / Target Type**: Internet — not "Local Network", which would break
  the thing you're trying to keep
- **Source / Target**: the specific client (or its IP)

That's it. The device keeps its lease, keeps answering on the LAN, and gets
nothing out of the WAN.

### 2b. The scalable version — a zone

UniFi Network 9 replaced the old rule list with **zone-based firewalling**:
interfaces get grouped into zones and you write policies between zones.

1. **Settings → Networks** — create an IoT VLAN and put the device on it.
2. **Settings → Security → Zone-Based Firewall** — create an **IoT** zone and
   assign that network to it.
3. Policy: **Source** IoT zone → **Destination** External (WAN) → **Block**.
4. Policy: **Source** your trusted/internal zone → **Destination** IoT zone →
   **Allow**. This is stateful, so replies come back without a second rule —
   your phone and Home Assistant can reach in, the IoT zone can't reach out.

New zones block everything between themselves by default, so expect to add
allows rather than blocks once you're in this mode.

> **The gotcha that catches everyone.** Putting devices on their own VLAN
> stops discovery dead. Turn on **Multicast DNS** for the IoT network
> (**Settings → Networks → <the network> → Advanced**) so mDNS crosses the
> boundary.
>
> That fixes mDNS and *only* mDNS. UniFi's reflector does not relay plain UDP
> broadcast, so a device found by a broadcast probe — a Roomba on UDP 5678, a
> TP-Link Kasa plug on 9999 — will not be discovered from another VLAN no
> matter what you enable. Either keep the controller on the same VLAN as the
> device, or skip discovery and configure it by its fixed IP.

---

## MikroTik (RouterOS 7)

An address list plus two forward rules. Add devices to the list later and
nothing else changes — this is the nice thing about doing it MikroTik's way.

```
# 1. Pin the address (adjust the server name to yours; defconf is the default)
/ip dhcp-server lease
add address=192.168.88.50 mac-address=AC:F4:73:AA:BB:CC server=defconf \
    comment="Roomba"

# 2. One list, however many devices
/ip firewall address-list
add list=no-internet address=192.168.88.50 comment="Roomba"

# 3. Drop anything from the list heading out of the WAN...
/ip firewall filter
add chain=forward action=drop src-address-list=no-internet \
    out-interface-list=WAN comment="no-internet: block outbound"

# 4. ...and anything from the WAN heading to it.
add chain=forward action=drop dst-address-list=no-internet \
    in-interface-list=WAN comment="no-internet: block inbound"
```

Two things to check:

- **`WAN` must be a real interface list** containing your uplink. RouterOS's
  default configuration ships one; if you built the config by hand, confirm
  with `/interface list member print`.
- **Rule order.** The forward chain's default policy is accept, and the stock
  `accept established,related,untracked` rule at the top only matches return
  traffic — a new outbound connection still reaches your drop. But if you've
  added your own `accept` rules for LAN→WAN, these two have to sit **above**
  them. `/ip firewall filter print` and `move` as needed.

Use `chain=forward`, not `chain=input`. `input` is traffic to the router
itself, and dropping that takes away the device's DHCP and DNS.

Sinkholing a hostname as a second layer:

```
/ip dns static
add name=disc-prod.iot.irobotapi.com address=127.0.0.1 type=A
```

---

## OPNsense and pfSense

Same shape on both. Order matters — firewall rules are evaluated top down and
the first match wins, so the allow has to come first.

1. **Services → DHCPv4 → <interface>** — add a static mapping.
2. **Firewall → Aliases** — make a Host alias, e.g. `roomba`, holding that IP.
   (Do this even for one device. When there are five, you edit the alias
   instead of the rules.)
3. **Firewall → Rules → LAN**, in this order:
   - **Pass** — Source `roomba`, Destination `LAN net`. Keeps local control.
   - **Block** — Source `roomba`, Destination `any`. Everything else, including
     the internet.

If you have several internal subnets, use an RFC1918 alias as the pass
destination instead of `LAN net`.

---

## OpenWrt

```sh
uci add firewall rule
uci set firewall.@rule[-1].name='Block Roomba WAN'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].dest='wan'
uci set firewall.@rule[-1].src_ip='192.168.1.50'
uci set firewall.@rule[-1].target='REJECT'
uci commit firewall
service firewall restart
```

`REJECT` rather than `DROP` on purpose: the device gets an immediate refusal
instead of retrying a dead connection for minutes on end, which is easier on
its battery and much easier to read in a packet capture.

Pin the lease in **Network → DHCP and DNS → Static Leases**, or in
`/etc/config/dhcp`.

---

## Firewalla

Open the device in the app, then **Rules → Block → Internet**. Firewalla
understands the difference between internet and LAN traffic natively, so
there's nothing else to get right.

---

## A generic consumer router

Look for **Access Control**, **Parental Controls**, or **Device Blocking**.
Most will block a device by MAC address.

Two caveats worth knowing before you rely on it:

- Some of these only block on a *schedule*. "All day, every day" is usually
  available but you may have to set it explicitly.
- A few block the device from the network entirely rather than from the
  internet, which takes local control with it. If the device disappears from
  Home Assistant the moment you enable the rule, that's what happened — and
  this router can't do what you need.

If neither works, the DNS sinkhole below is your remaining option on that
hardware.

---

## DNS sinkholing (Pi-hole, AdGuard Home)

Add the vendor's hostnames to a blocklist and they resolve to nothing.

This is a fine second layer and a bad only layer, for the reason in the box
near the top: it works exactly as long as the device uses the resolver you gave
it. To make it harder to escape:

- **Redirect port 53** at the router — NAT any outbound TCP/UDP 53 back to your
  own resolver, so a hardcoded `8.8.8.8` lands on Pi-hole anyway.
- **Block 853** (DNS-over-TLS) outbound.
- DNS-over-HTTPS is port 443 and indistinguishable from ordinary traffic
  without deep inspection. If a device does that, only a firewall rule stops
  it.

---

## Check that it worked

**Watch the drops.** Every platform above logs them: UniFi under Insights,
MikroTik with `/log print` if you add `log=yes` to the rules, OPNsense/pfSense
under Firewall → Log Files. Seeing the device try and fail is the confirmation.

**Watch the wire.** From any machine on the same subnet:

```bash
# Everything the device sends that isn't staying on the LAN.
sudo tcpdump -ni eth0 host 192.168.1.50 and not net 192.168.1.0/24
```

Retries with no replies is a working block. Silence usually means the device
gave up, which is also fine.

**Then use the thing.** Open Home Assistant, or the Liberated Bread app, and
send a command. If it works, you're done: the device is alive, local, and can't
be updated out from under you.

---

## Worked example: an iRobot Roomba

Wi-Fi Roombas run an MQTT broker on the robot itself, which keeps working with
no internet at all. The 2025 model line ships without that broker — which is a
fairly direct demonstration of why you'd want to freeze the firmware on the one
you have.

> **Do this in the right order.** Get the robot's password *first*, block it
> *second*. One of the two ways to get that password goes through iRobot's
> servers, and a firewall rule added first turns a five-minute job into
> temporarily undoing your own work. The [Roomba
> guide](/devices/roomba/) walks through both routes.

### What the robot talks to

| Port / protocol | Where | Blocking it |
|---|---|---|
| TCP 8883 (MQTT over TLS) | **The robot, on your LAN** | **Leave alone.** This is local control. |
| UDP 5678 (broadcast) | Your LAN | **Leave alone.** Discovery. |
| TCP 443 | iRobot / AWS IoT | Block. Cloud control, telemetry, firmware. |
| UDP 123 (NTP) | Time servers | See below. |

The published hostnames — `disc-prod.iot.irobotapi.com`,
`unauth2.prod.iot.irobotapi.com`, and the AWS IoT endpoint the robot's cloud
side uses — are listed in our
[protocol spec](https://github.com/liberatedbread/liberatedbread-protocol-specs/blob/main/device-specs/devices/irobot-roomba.yaml)
as `reported`, not confirmed: nobody here has captured a robot's DNS traffic.
If you're building a sinkhole list rather than a firewall rule, log the robot's
own lookups for a day and use those. If you're doing it with a firewall rule,
you don't need the list at all — which is the better reason to prefer one.

### What you keep

- Start, pause, stop, dock and locate
- Battery level, mission phase, bin-full
- Discovery on your own network
- Everything in the Liberated Bread app and Home Assistant's `roomba`
  integration

### What you lose

- The iRobot app from outside the house (it still works on your Wi-Fi)
- Cloud-stored schedules
- Map sync on the i / j / s series
- Firmware updates — the point

### Two Roomba-specific notes

**Time.** iRobot lists NTP among the ports the robot uses, and local commands
carry a timestamp from the *sender*. We haven't tested what a robot with no
time source does. If yours starts behaving oddly after you block it, allow
outbound UDP 123, or hand it your gateway's own NTP server via DHCP option 42,
before you go looking for anything more exotic.

**One client at a time.** This isn't about the firewall, but it's the next
thing that will confuse you: the robot accepts a single local connection, and a
new one evicts the old. If the iRobot app stops working locally the moment
Home Assistant connects, that's why — and it's why Home Assistant polls rather
than holding the socket open.

---

*The advice to firewall a Roomba so an over-the-air update can't take the local
API away is [koalazak](https://github.com/koalazak)'s, from
[dorita980](https://github.com/koalazak/dorita980) — as is the local protocol
that makes it worth doing. This page generalises it to the rest of the devices
we cover.*

*Router UIs change. If a menu path here is wrong, the rule description above it
still tells you what to build — and please [open an
issue](https://github.com/liberatedbread/liberatedbread-web-static/issues).*
