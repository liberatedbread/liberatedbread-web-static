---
layout: device
slug: eufy-mount
title: "Replace Your Eufy Indoor Cam Mount (3D Printed)"
device_name: "Eufy Indoor Cam 2K Pan & Tilt"
model: "T8400"
type: hardware
difficulty: 2
time_minutes: 45
safety_block: true
stl_files:
  - filename: "wall-mount-v2.stl"
    description: "Articulating wall mount (PLA, 20% infill)"
  - filename: "ball-joint.stl"
    description: "Ball joint connector (PETG, 50% infill)"
tags: [eufy, camera, mount, 3d-print]
---

<!--
  Device metadata bar is rendered by _layouts/device.html from front-matter.
  Content below is the liberation guide body.
-->

## What You're Building

The stock Eufy Indoor Cam mount is flimsy, and a common complaint is that the pan-and-tilt mechanism works loose over a few months until the camera sags. This guide walks you through replacing it with a 3D-printed articulating wall mount — more stable, more adjustable, and entirely under your control.

This is a physical modification. No firmware changes, no software liberation — just better hardware.

## Parts List

| Part | Quantity | Notes |
|---|---|---|
| PLA filament | ~15g | For the wall mount body |
| PETG filament | ~5g | For the ball joint (more flexible, won't creep under load) |
| M3×12mm screws | 2 | Stainless recommended |
| M3 nuts | 2 | Nylon lock nuts preferred |
| Wall anchors (drywall) | 2 | Standard #6 anchors |
| Wood screws | 2 | #6 × 1" |

**Sourcing:** Filament and hardware are available from any 3D printing supplier. No affiliate links yet — we'll add them when we get our Associates account set up.

## 3D Printed Parts

{% if page.stl_files %}
<div class="space-y-4 my-6">
{% for file in page.stl_files %}
  <div class="flex flex-wrap items-center justify-between gap-3 bg-bread-base-dark border border-bread-steel/30 rounded-lg p-4">
    <div>
      <span class="font-mono text-sm text-bread-accent">{{ file.filename }}</span>
      <p class="text-sm text-bread-khaki/70 m-0">{{ file.description }}</p>
    </div>
    <a href="https://github.com/liberatedbread/liberatedbread-3d-files/raw/main/files/eufy-camera/{{ file.filename }}"
       download
       class="px-3 py-1 text-sm rounded bg-bread-accent/20 text-bread-accent hover:bg-bread-accent/35 no-underline whitespace-nowrap transition-colors">
      <span aria-hidden="true">&darr;</span> Download {{ file.filename }}
    </a>
  </div>
{% endfor %}
</div>
{% endif %}

**Print settings:**
- **Wall mount:** PLA, 0.2mm layers, 20% infill, 3 perimeters, no supports needed
- **Ball joint:** PETG, 0.15mm layers, 50% infill, 4 perimeters. PETG is essential here — PLA will creep under the constant load and the joint will loosen

## Step 0: De-energize / Unplug

The Eufy Indoor Cam is low-voltage (5V USB), so there's no mains voltage risk inside the camera itself. But you're drilling into your wall — **check for electrical wiring behind the mounting location** before drilling. If you're unsure, use a stud/wire finder or mount on a stud.

1. Unplug the camera's USB power cable
2. Remove the camera from its existing mount
3. Remove the existing mount from the wall (if any)

## Assembly Guide

### 1. Mount the wall plate

1. Hold the printed wall plate against the wall at your chosen location
2. Mark the two screw holes with a pencil
3. Drill pilot holes (1/8" for drywall anchors)
4. Insert wall anchors and screw the plate to the wall

### 2. Assemble the ball joint

1. Press the ball joint into the wall plate socket — it should snap in with firm pressure
2. Insert the two M3 screws through the ball joint clamp
3. Thread the M3 nuts loosely — you'll tighten after positioning

### 3. Attach the camera

1. Slide the camera onto the ball joint mount (it uses the same mounting slot as the stock mount)
2. Adjust the camera to your desired angle
3. Tighten the M3 nuts to lock the position — don't overtighten, PETG will crack if forced
4. Plug in the USB power cable

### 4. Test

The camera should hold position firmly. Pan and tilt it manually to verify the ball joint has full range of motion. PETG can settle slightly under a constant load, so check the screws again after 24 hours and retighten a little if needed.

## Troubleshooting

### Ball joint too loose
- Reprint at 55% infill (instead of 50%)
- Or add a thin rubber washer between the ball and clamp

### Wall plate sags under camera weight
- Check that you used PLA with 3 perimeters — single-perimeter prints will flex
- If it still sags, reprint with 25% infill and add a small support brace underneath

### Camera won't stay at desired angle
- The M3 screws may have loosened — check and retighten
- If PETG was printed too hot, it may have warped — reprint at 240°C with the part cooling fan at 50%

## Going Further

This guide covers the physical mount. If you want to liberate the camera's software (RTSP streaming without the Eufy cloud), check the Eufy Cam RTSP guide (coming soon). That route locks the camera to LAN-only and streams directly to Home Assistant or Frigate.

---

*Designed for the Eufy Indoor Cam 2K Pan & Tilt (T8400). The mount geometry and the print
settings come from the part design, not from a printed and installed sample. See the
verification notice at the top of this guide.*
