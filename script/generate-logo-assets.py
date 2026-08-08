#!/usr/bin/env python3
"""Regenerates every served logo asset from the masters in assets/brand/.

DESIGN §3.3 keeps brand colour in one place; this does the same for the
artwork. `assets/brand/` holds the four supplied masters and nothing else may
be hand-drawn — assets/logo.png, the favicon, the apple-touch icon and the
Open Graph card are all derived here so a future logo swap is one file drop
plus one command.

    python3 script/generate-logo-assets.py

Authoring-only, like tool/branding in the mobile repo: the outputs are
committed, so CI and the Pages build never run this. Needs Pillow
(`pip install pillow`).

MASTERS (assets/brand/, tight-cropped, never resized in place)
  logo-mark.png          mascot alone, transparent      -> icons
  logo-lockup.png        mascot + wordmark, transparent -> nothing yet
  logo-mark-pink.png     mascot alone, on brand pink    -> reference
  logo-lockup-pink.png   mascot + wordmark, on pink     -> Open Graph card

WHY THE ICONS ARE NOT TRANSPARENT
The mascot is outlined in --bread-base, a near-black navy. On a dark browser
tab strip or a dark iOS home screen a transparent icon is an invisible smudge,
so everything that renders at icon size gets the brand pink behind it — which
is how the logo is presented anyway. assets/logo.png stays transparent: it is
only ever drawn on --bread-base-dark panels in our own markup.

The pink is read out of src/input.css rather than written here, so it cannot
drift from --bread-sky. Same contract as script/sync-brand-data.rb.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:  # pragma: no cover - authoring tool
    sys.exit("error: Pillow is required — pip install pillow")

ROOT = Path(__file__).resolve().parent.parent
BRAND = ROOT / "assets" / "brand"
OUT = ROOT / "assets"

# assets/logo.png is referenced with width/height 40 and 96 in _includes, and
# with `w-24 h-24` on the coming-soon page. It has to stay square or the
# browser distorts it, so the mascot is padded to a square canvas rather than
# cropped to one.
LOGO_PX = 512
FAVICON_SIZES = (16, 32, 48, 64, 128)
APPLE_TOUCH_PX = 180
OG_SIZE = (1200, 630)

# Fraction of the canvas the artwork's longest edge spans. Icons get less
# breathing room than the inline logo because they are already inset by the
# platform that draws them.
LOGO_FILL = 0.92
ICON_FILL = 0.84
OG_FILL = 0.80


def brand_pink() -> tuple[int, int, int]:
    """The value of --bread-sky in src/input.css, as an RGB triple."""
    css = (ROOT / "src" / "input.css").read_text()
    root = re.search(r":root\s*\{(.*?)\}", css, re.S)
    if not root:
        sys.exit("error: no :root block found in src/input.css")
    match = re.search(r"--bread-sky\s*:\s*#([0-9a-fA-F]{6})\s*;", root.group(1))
    if not match:
        sys.exit("error: no --bread-sky token found in src/input.css")
    value = match.group(1)
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def load(name: str) -> Image.Image:
    path = BRAND / name
    if not path.exists():
        sys.exit(f"error: missing master {path.relative_to(ROOT)}")
    return Image.open(path).convert("RGBA")


def place(art: Image.Image, canvas: tuple[int, int], fill: float, background):
    """Scale `art` to `fill` of the canvas and centre it on `background`."""
    limit_w = canvas[0] * fill
    limit_h = canvas[1] * fill
    scale = min(limit_w / art.width, limit_h / art.height)
    art = art.resize(
        (max(1, round(art.width * scale)), max(1, round(art.height * scale))),
        Image.LANCZOS,
    )
    out = Image.new("RGBA", canvas, background)
    out.alpha_composite(art, ((canvas[0] - art.width) // 2, (canvas[1] - art.height) // 2))
    return out


def main() -> None:
    pink = brand_pink()
    opaque = pink + (255,)
    clear = (0, 0, 0, 0)

    mark = load("logo-mark.png")
    lockup_pink = load("logo-lockup-pink.png")
    written = []

    # Inline site logo — transparent, square, drawn on our own dark panels.
    logo = place(mark, (LOGO_PX, LOGO_PX), LOGO_FILL, clear)
    logo.save(OUT / "logo.png", optimize=True)
    written.append(f"logo.png ({LOGO_PX}x{LOGO_PX}, transparent)")

    # Favicon — one square master downscaled per size. Pillow writes every
    # requested size into the single .ico.
    icon = place(mark, (max(FAVICON_SIZES),) * 2, ICON_FILL, opaque)
    icon.save(
        OUT / "favicon.ico",
        format="ICO",
        sizes=[(s, s) for s in FAVICON_SIZES],
    )
    written.append("favicon.ico (" + ", ".join(f"{s}x{s}" for s in FAVICON_SIZES) + ")")

    # iOS strips alpha and composites the result on black, so this one has to
    # arrive already opaque.
    touch = place(mark, (APPLE_TOUCH_PX,) * 2, ICON_FILL, opaque)
    touch.convert("RGB").save(OUT / "apple-touch-icon.png", optimize=True)
    written.append(f"apple-touch-icon.png ({APPLE_TOUCH_PX}x{APPLE_TOUCH_PX}, opaque)")

    # Open Graph card. The wordmark is the point here — this is the one place
    # the logo renders large enough to read it.
    card = place(lockup_pink, OG_SIZE, OG_FILL, opaque)
    card.convert("RGB").save(OUT / "og-image.png", optimize=True)
    written.append(f"og-image.png ({OG_SIZE[0]}x{OG_SIZE[1]}, opaque)")

    print("brand pink: #%02x%02x%02x (--bread-sky)" % pink)
    for line in written:
        print(f"  wrote assets/{line}")


if __name__ == "__main__":
    main()
