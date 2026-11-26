#!/usr/bin/env python3
"""Export the approved Marker artwork as Android and iOS launcher icons.

Reuses the same master art as the desktop icons (assets/branding/marker-*-master.png)
so every platform shows the same brand mark. Desktops ship separate light/dark
artwork; mobile platforms get the same treatment through their native mechanisms:

* Android: light icons in ``mipmap-*`` and dark icons in ``mipmap-night-*``
  (legacy bitmaps plus adaptive-icon layers for API 26+).
* iOS: an Xcode 16 single-size AppIcon set with default, dark and tinted
  appearances, selected by the system Home Screen appearance on iOS 18+.

Two mobile constraints are handled without altering the artwork itself:

* The default iOS icon is opaque; dark artwork uses a transparent background
  and tinted artwork is grayscale. The system applies the corner mask.
* Android launcher icons are drawn full-bleed; the adaptive foreground keeps the
  mark inside the 66% safe zone so nothing is clipped by the system mask.

The desktop artwork is a rounded card with an edge highlight and a drop shadow.
Scaling that card onto a flat square leaves a visible ring where its corners meet
the new background, so the mobile icons redraw the glyph alone on the card's flat
surface color instead. The glyph, its colors and its proportions are untouched.

Development only (run from the repo root):

    python3 -m pip install pillow
    python3 scripts/export_mobile_icons.py
"""
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
BRAND = ROOT / 'assets/branding'

# Android legacy launcher densities; night variants use the same sizes.
ANDROID_LEGACY = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}
ADAPTIVE_CANVAS = 432  # 108dp @ xxxhdpi full adaptive canvas.

# Xcode 16 single-size app icons: one 1024px image per appearance. iOS derives
# every smaller slot from these. (filename, appearance); None is the default icon.
IOS_ICONS = (
    ('Icon-1024-default.png', None),
    ('Icon-1024-dark.png', 'dark'),
    ('Icon-1024-tinted.png', 'tinted'),
)

# Glyph sizing as a share of the icon canvas, chosen to match the desktop card.
IOS_GLYPH_RATIO = 0.56
ANDROID_GLYPH_RATIO = 0.62
ADAPTIVE_GLYPH_RATIO = 0.42


def card_color(card, inset=0.06):
    """Return the card's flat surface color.

    The artwork's card carries a soft gradient and an edge highlight, and sampling
    a single pixel can land on either — or on the glyph, which fills most of the
    card. The mark is centered, so the four corner zones are always card surface;
    sample a grid inside each of them and take the median, which keeps any one
    stray pixel from changing the result.
    """
    surface = card.convert('RGB')
    width, height = surface.size
    depth = 0.22  # Keep samples clear of both the edge trim and the centered mark.
    regions = (
        (inset, inset, depth, depth),
        (1 - depth, inset, 1 - inset, depth),
        (inset, 1 - depth, depth, 1 - inset),
        (1 - depth, 1 - depth, 1 - inset, 1 - inset),
    )
    reds, greens, blues = [], [], []
    for left, top, right, bottom in regions:
        for iy in range(4):
            for ix in range(4):
                x = round(width * (left + (right - left) * (ix + 1) / 5))
                y = round(height * (top + (bottom - top) * (iy + 1) / 5))
                r, g, b = surface.getpixel((x, y))
                reds.append(r)
                greens.append(g)
                blues.append(b)
    median = lambda values: sorted(values)[len(values) // 2]
    return (median(reds), median(greens), median(blues), 255)


def glyph_mask(card, threshold=25):
    """Return a hard L-mode mask covering only the colored brand glyph.

    The card is neutral (warm white or charcoal) while the mark is saturated
    navy/teal, so chroma — max(R,G,B) minus min(R,G,B) — separates them cleanly and
    ignores the card's gradient and edge highlight, which a plain color difference
    would otherwise pick up as a faint arc.

    The two strokes differ a lot in saturation: the navy sits near 70 in the light
    artwork and near 134 in the dark one, teal near 100, and the card stays under
    10. A soft ramp from the navy value downward would make the navy stroke
    half-transparent, and blending a semi-transparent navy over a light card turns
    it grey. The mask is therefore binary, and edge smoothness comes from the
    alpha-only smoothing applied when the glyph is composited.
    """
    red, green, blue = card.convert('RGB').split()
    high, low = ImageChops.lighter, ImageChops.darker
    chroma = ImageChops.subtract(high(high(red, green), blue),
                                 low(low(red, green), blue))
    return chroma.point(lambda v: 255 if v >= threshold else 0)


def largest_component(mask):
    """Keep only the connected shape that covers the most pixels.

    The card's edge has a handful of saturated fringe pixels that survive the
    chroma test. The brand mark is one large connected shape, so retaining only
    the biggest component removes those specks without touching the glyph.
    """
    width, height = mask.size
    pixels = mask.load()
    seen = bytearray(width * height)
    best = []
    for start_y in range(height):
        for start_x in range(width):
            index = start_y * width + start_x
            if seen[index] or pixels[start_x, start_y] < 128:
                continue
            stack = [(start_x, start_y)]
            seen[index] = 1
            region = []
            while stack:
                x, y = stack.pop()
                region.append((x, y))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < width and 0 <= ny < height:
                        neighbour = ny * width + nx
                        if not seen[neighbour] and pixels[nx, ny] >= 128:
                            seen[neighbour] = 1
                            stack.append((nx, ny))
            if len(region) > len(best):
                best = region
    if not best:
        return mask
    clean = Image.new('L', mask.size, 0)
    target = clean.load()
    for x, y in best:
        target[x, y] = 255
    return clean


def glyph_layer(card, canvas_size, glyph_ratio):
    """Render the glyph alone on transparency, centered in a square canvas.

    The glyph keeps its original pixels; only the binary mask's edge is softened,
    so the mark does not pick up a grey fringe from blending with the card color it
    sits on. The mark is squared to the artwork's proportions, not stretched.
    """
    mask = glyph_mask(card)
    # Only the centered mark is wanted. The card's edge carries a few saturated
    # fringe pixels that pass the chroma test; drop them by keeping the largest
    # connected shape near the center instead of the raw mask.
    mask = largest_component(mask)
    bounds = mask.getbbox()
    if bounds is None:
        raise SystemExit('Could not isolate the brand glyph')
    # Soften only the mask edge: a small blur, re-thresholded, keeps the shape's
    # crisp edges while letting one pixel of anti-aliasing through.
    edge = mask.filter(ImageFilter.GaussianBlur(1.2))
    edge = edge.point(lambda v: 0 if v < 96 else 255 if v > 160 else v)
    glyph = card.convert('RGB').crop(bounds)
    glyph.putalpha(edge.crop(bounds))
    scale = (canvas_size * glyph_ratio) / max(glyph.size)
    resized = glyph.resize(
        (max(1, round(glyph.width * scale)), max(1, round(glyph.height * scale))),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    canvas.alpha_composite(
        resized,
        ((canvas_size - resized.width) // 2, (canvas_size - resized.height) // 2),
    )
    return canvas


def glyph_on_background(card, color, canvas_size, glyph_ratio):
    """Draw the glyph alone on the card's flat surface color, full-bleed."""
    mark = glyph_layer(card, canvas_size, glyph_ratio)
    canvas = Image.new('RGB', (canvas_size, canvas_size), color[:3])
    canvas.paste(mark, (0, 0), mark.getchannel('A'))
    return canvas


def export_android(variants):
    """Write legacy bitmaps plus adaptive-icon layers for light and night."""
    res = ROOT / 'android/app/src/main/res'
    for variant, qualifier in (('light', ''), ('dark', 'night-')):
        card, color = variants[variant]
        for folder, size in ANDROID_LEGACY.items():
            night_folder = folder.replace('mipmap-', f'mipmap-{qualifier}')
            target = res / night_folder / 'ic_launcher.png'
            target.parent.mkdir(parents=True, exist_ok=True)
            glyph_on_background(card, color, size, ANDROID_GLYPH_RATIO).save(target)

        layers = res / f'mipmap-{qualifier}anydpi-v26'
        layers.mkdir(parents=True, exist_ok=True)
        raster = res / f'mipmap-{qualifier}xxxhdpi'
        # PNGs carry xxxhdpi density; anydpi is reserved for the XML wrappers.
        for stale in layers.glob('*.png'):
            stale.unlink()
        # Full-bleed background: the flat card color, no transparency.
        Image.new('RGB', (ADAPTIVE_CANVAS, ADAPTIVE_CANVAS), color[:3]).save(
            raster / 'ic_launcher_background.png'
        )
        # Foreground: just the mark, kept inside the 66% safe zone so the launcher
        # mask never clips it.
        canvas = glyph_layer(card, ADAPTIVE_CANVAS, ADAPTIVE_GLYPH_RATIO)
        canvas.save(raster / 'ic_launcher_foreground.png')
        monochrome = Image.new('RGBA', canvas.size, 'white')
        monochrome.putalpha(canvas.getchannel('A'))
        monochrome.save(raster / 'ic_launcher_monochrome.png')
        (layers / 'ic_launcher.xml').write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '</adaptive-icon>\n',
            encoding='utf-8',
        )
        themed = res / f'mipmap-{qualifier}anydpi-v33'
        themed.mkdir(parents=True, exist_ok=True)
        xml = (layers / 'ic_launcher.xml').read_text(encoding='utf-8')
        (themed / 'ic_launcher.xml').write_text(
            xml.replace('</adaptive-icon>',
                        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n</adaptive-icon>'),
            encoding='utf-8',
        )
    print('Exported Android legacy, adaptive and monochrome launcher icons.')


def export_ios(variants):
    """Write the Xcode 16 single-size AppIcon set (default, dark, tinted).

    The old per-size PNGs are removed so the asset catalog only holds the slots
    declared in Contents.json; stray images trigger actool "unassigned child"
    warnings and would leave stale artwork in the build.
    """
    folder = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    folder.mkdir(parents=True, exist_ok=True)
    for stale in list(folder.glob('Icon-App-*.png')) + list(folder.glob('Icon-*.png')):
        stale.unlink()

    # Apple expects grayscale tinted artwork and a transparent dark background.
    sources = {None: 'light', 'dark': 'dark', 'tinted': 'dark'}
    images = []
    for filename, appearance in IOS_ICONS:
        card, color = variants[sources[appearance]]
        if appearance == 'dark':
            image = glyph_layer(card, 1024, IOS_GLYPH_RATIO)
        elif appearance == 'tinted':
            image = ImageOps.grayscale(
                glyph_on_background(card, (0, 0, 0, 255), 1024, IOS_GLYPH_RATIO)
            ).convert('RGB')
        else:
            image = glyph_on_background(card, color, 1024, IOS_GLYPH_RATIO)
        image.save(folder / filename)
        entry = {
            'filename': filename,
            'idiom': 'universal',
            'platform': 'ios',
            'size': '1024x1024',
        }
        if appearance is not None:
            entry['appearances'] = [{'appearance': 'luminosity', 'value': appearance}]
        images.append(entry)

    (folder / 'Contents.json').write_text(
        json.dumps({'images': images, 'info': {'author': 'xcode', 'version': 1}},
                   indent=2) + '\n',
        encoding='utf-8',
    )
    print('Exported iOS single-size AppIcon set (default + dark + tinted).')


def export_launch(variants):
    """Transparent glyphs: 120pt on iOS, 120dp within Android's 288dp canvas."""
    ios = ROOT / 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
    res = ROOT / 'android/app/src/main/res'
    for variant, qualifier in [('light', ''), ('dark', 'night-')]:
        card, _ = variants[variant]
        for scale in [1, 2, 3]:
            glyph_layer(card, 120 * scale, 1.0).save(
                ios / f'launch-{variant}-{scale}.png')
        for density, scale in [('mdpi', 1), ('hdpi', 1.5), ('xhdpi', 2),
                               ('xxhdpi', 3), ('xxxhdpi', 4)]:
            folder = res / f'drawable-{qualifier}{density}'
            folder.mkdir(parents=True, exist_ok=True)
            glyph_layer(card, round(288 * scale), 120 / 288).save(folder / 'splash_logo.png')


def main():
    variants = {}
    for variant in ('light', 'dark'):
        image = Image.open(BRAND / f'marker-{variant}-master.png').convert('RGBA')
        bounds = image.getchannel('A').point(lambda a: 255 if a > 200 else 0).getbbox()
        if bounds is None:
            raise SystemExit(f'Icon artwork is empty: marker-{variant}-master.png')
        card = image.crop(bounds)
        variants[variant] = (card, card_color(card))
    export_android(variants)
    export_ios(variants)
    export_launch(variants)


if __name__ == '__main__':
    main()
