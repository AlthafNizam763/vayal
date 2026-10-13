# Generate VAYAL brand assets (logo + app icon) for all platforms.
#
# Design: three golden paddy ears rising over terraced field arcs,
# against a deep-charcoal noir background with a burnt-orange sun.
#
# Usage:  python tool/gen_brand_assets.py
# Requires Pillow:  python -m pip install pillow

import math
import os
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    sys.exit("This script needs Pillow. Install it with:  python -m pip install pillow")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------------------------------------------------------------------------
# Palette (matches the main menu: Charcoal noir + burnt orange accent D97736)
# --------------------------------------------------------------------------
BG_TOP = (27, 35, 49)      # #1B2331 deep slate
BG_BOT = (11, 13, 18)      # #0B0D12 near black
GOLD = (233, 166, 60)      # #E9A63C paddy gold
GOLD_L = (246, 207, 122)   # #F6CF7A light gold
GOLD_D = (184, 115, 15)    # #B8730F deep gold
ORANGE = (217, 119, 54)    # #D97736 menu accent

# ---------------------------------------------------------------------------
# Design geometry (512 x 512 design space)
# --------------------------------------------------------------------------
BASE_X, BASE_Y = 256.0, 445.0          # paddy sheaf base point
SUN_C = (256.0, 236.0)
SUN_R = 120.0
TERR_C = (256.0, 40.0)                 # terrace arcs bulge down from here
TERR_RADII = (400.0, 460.0, 520.0)
TERR_ALPHA = (0.30, 0.55, 0.95)
TERR_SW = 10.0
EARS = [(-115.0, 0.86), (-90.0, 1.0), (-65.0, 0.86)]  # (dir angle, scale)
GRAIN_PAIRS = 7
GRAIN_Y0, GRAIN_DY = 158.0, 27.0
GRAIN_L, GRAIN_W = 66.0, 28.0
STEM_SW = 9.0
STEM_P0 = (0.0, 0.0)
STEM_C = (-6.0, -160.0)
STEM_P1 = (-2.0, -310.0)
LETTER_W, LETTER_H, ADVANCE = 56.0, 80.0, 80.0
WORD_SW = 13.0
LOGO_W, LOGO_H = 512.0, 700.0          # logo artboard (wordmark below emblem)
WORD_TOP = 588.0
ICON_RADIUS_FRAC = 0.19                # rounded-corner radius fraction

SS = 4                                  # supersampling factor


# ---------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
def quad_bezier(p0, c, p1, n=30):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1.0 - t
        pts.append((u * u * p0[0] + 2 * u * t * c[0] + t * t * p1[0],
                    u * u * p0[1] + 2 * u * t * c[1] + t * t * p1[1]))
    return pts


def grain_poly(cx, cy, gamma_deg, length, width):
    """Pointed rice-grain polygon (supersampled ellipse with tapered ends)."""
    r = math.radians(gamma_deg)
    ca, sa = math.cos(r), math.sin(r)
    n = 32
    side = []
    for u in [(i / n) for i in range(n + 1)]:
        hw = (width / 2.0) * math.sin(math.pi * u) ** 0.75
        side.append(((u - 0.5) * length, hw))
    outline = side + [(-x, -y) for (x, y) in reversed(side)]
    pts = [(cx + x * ca - y * sa, cy + x * sa + y * ca) for (x, y) in outline]
    return pts


def round_line(dd, pts, fill, width):
    dd.line([(x, y) for (x, y) in pts], fill=fill, width=width, joint="curve")
    r = width / 2.0
    for p in (pts[0], pts[-1]):
        dd.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=fill)


def rgba(c, a):
    return (c[0], c[1], c[2], a)


class Mapper:
    """Maps design-space -> raster coords (with optional radial shrink)."""

    def __init__(self, scale, shrink=1.0, center=(256.0, 256.0)):
        self.s = scale
        self.k = shrink
        self.cx, self.cy = center

    def p(self, x, y):
        x = self.cx + (x - self.cx) * self.k
        y = self.cy + (y - self.cy) * self.k
        return (self.cx + (x - self.cx) * self.s, self.cy + (y - self.cy) * self.s)

    def v(self, w):
        return max(1, int(round(w * self.k * self.s)))


def draw_ear(dd, m, angle_deg, scale):
    """One paddy ear: stem + alternating grains, rotated around the base."""
    beta = math.radians(angle_deg + 90.0)
    ca, sa = math.cos(beta), math.sin(beta)

    def l2g(x, y):
        x, y = x * scale, y * scale
        return (BASE_X + x * ca - y * sa, BASE_Y + x * sa + y * ca)

    def g(p):
        return m.p(*l2g(p[0], p[1]))

    # stem
    stem = [g(p) for p in quad_bezier(STEM_P0, STEM_C, STEM_P1)]
    round_line(dd, stem, rgba(GOLD, 255), m.v(STEM_SW * scale))

    # gamma (local grain axis angle) per side + rotated version
    gr = math.radians(34.0)
    gam = {}
    for s in (1, -1):
        dx, dy = s * math.sin(gr), -math.cos(gr)
        gam[s] = math.degrees(math.atan2(dy, dx))
    tip = STEM_P1

    for i in range(GRAIN_PAIRS):
        yy = -(GRAIN_Y0 + GRAIN_DY * i)
        f = 1.0 - 0.065 * i
        gl, gw = GRAIN_L * f, GRAIN_W * f
        d = gl / 2.0 - 8.0
        for s in (1, -1):
            ccx, ccy = 0.0 + math.sin(gr) * s * d, yy - math.cos(gr) * d
            lx, ly = l2g(ccx, ccy)
            gamma = gam[s]
            gamma_screen = gamma + math.degrees(beta)
            dd.polygon(grain_poly(*m.p(lx, ly), gamma_screen,
                                  gl * scale * m.k, gw * scale * m.k),
                       fill=rgba(GOLD_L, 255))

    # terminal grain along the stem tip
    gl, gw = GRAIN_L * 1.02, GRAIN_W * 1.05
    lx, ly = l2g(tip[0], tip[1] - gl / 2.0 + 10.0)
    gamma_screen = -90.0 + math.degrees(beta)
    dd.polygon(grain_poly(*m.p(lx, ly), gamma_screen,
                          gl * scale * m.k, gw * scale * m.k),
               fill=rgba(GOLD_L, 255))


def draw_terraces(dd, m):
    for r, a in zip(TERR_RADII, TERR_ALPHA):
        pts = []
        for i in range(73):
            phi = math.radians(-48.0 + 96.0 * i / 72.0)
            x = TERR_C[0] + r * math.sin(phi)
            y = TERR_C[1] + r * math.cos(phi)
            pts.append(m.p(x, y))
        round_line(dd, pts, rgba(GOLD, int(255 * a)), m.v(TERR_SW))


def draw_sun(dd, m):
    cx, cy = m.p(*SUN_C)
    r = SUN_R * m.s * m.k
    dd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=rgba(ORANGE, 52))
    dd.ellipse([cx - r, cy - r, cx + r, cy + r],
               outline=rgba(ORANGE, 150), width=m.v(6.0))


def draw_emblem(dd, m, draw_sun=True):
    if draw_sun:
        draw_sun(dd, m)
    draw_terraces(dd, m)
    for angle, scale in EARS:
        draw_ear(dd, m, angle, scale)


def letter_paths(letter, ox, oy):
    """Monoline uppercase glyphs, local box 0..56 x 0..80, y grows down."""
    def g(pts):
        return [(ox + x, oy + y) for (x, y) in pts]
    if letter == "V":
        return [g([(0, 0), (28, 80), (56, 0)])]
    if letter == "A":
        return [g([(8, 80), (28, 0), (48, 80)]), g([(15, 52), (41, 52)])]
    if letter == "Y":
        return [g([(0, 0), (28, 38), (56, 0)]), g([(28, 38), (28, 80)])]
    if letter == "L":
        return [g([(0, 0), (0, 80), (50, 80)])]
    raise ValueError(letter)


def draw_wordmark(layer, ox, oy):
    """VAYAL wordmark with a vertical gold gradient, on a transparent layer."""
    w, h = layer.size
    mask = Image.new("L", (w, h), 0)
    md = ImageDraw.Draw(mask)
    sw = max(2, int(round(WORD_SW * SS)))
    for idx, ch in enumerate("VAYAL"):
        for path in letter_paths(ch, ox + idx * ADVANCE * SS, oy):
            round_line(md, path, 255, sw)
    # gradient fill behind the letters
    grad = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    top, bot = int(oy), int(oy + LETTER_H * SS)
    gd = ImageDraw.Draw(grad)
    for y in range(max(0, top), min(h, bot + sw)):
        t = (y - top) / max(1.0, (bot + sw - top))
        c = tuple(int(GOLD_L[i] + (GOLD_D[i] - GOLD_L[i]) * t) for i in range(3))
        gd.line([(0, y), (w, y)], fill=c + (255,))
    layer.paste(grad, (0, 0), mask)


# ---------------------------------------------------------------------------
# Compositions
# --------------------------------------------------------------------------
def vertical_gradient(w, h, top, bot):
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1.0, h - 1.0)
        c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
        d.line([(0, y), (w, y)], fill=c)
    return img.convert("RGBA")


def build_background(w, h, m, glow=True):
    img = vertical_gradient(w, h, BG_TOP, BG_BOT)
    if glow:
        glow_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        gd = ImageDraw.Draw(glow_layer, "RGBA")
        gx, gy = m.p(*SUN_C)
        for i in range(40):
            rr = (SUN_R + 150.0 * (1.0 - i / 39.0)) * m.s * m.k
            a = int(26 * (1.0 - i / 39.0))
            gd.ellipse([gx - rr, gy - rr, gx + rr, gy + rr], fill=(217, 140, 40, a))
        img = Image.alpha_composite(img, glow_layer)
    return img


def render_logo():
    s = SS
    img = Image.new("RGBA", (int(LOGO_W * s), int(LOGO_H * s)), (0, 0, 0, 0))
    m = Mapper(s)
    dd = ImageDraw.Draw(img, "RGBA")
    draw_emblem(dd, m)
    draw_wordmark(img, (LOGO_W - 376.0) / 2.0 * s, WORD_TOP * s)
    return img.resize((1024, 1400), Image.LANCZOS)


def render_emblem():
    s = SS
    img = Image.new("RGBA", (512 * s, 512 * s), (0, 0, 0, 0))
    m = Mapper(s)
    draw_emblem(ImageDraw.Draw(img, "RGBA"), m)
    return img.resize((1024, 1024), Image.LANCZOS)


def render_icon(rounded, size_out=1024, shrink=1.0):
    s = SS
    img = Image.new("RGBA", (512 * s, 512 * s), (0, 0, 0, 0))
    if rounded:
        bg = build_background(512 * s, 512 * s, Mapper(s))
        mask = Image.new("L", (512 * s, 512 * s), 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            [0, 0, 512 * s - 1, 512 * s - 1], radius=int(512 * ICON_RADIUS_FRAC * s),
            fill=255)
        img.paste(bg, (0, 0), mask)
        m = Mapper(s)
        dd = ImageDraw.Draw(img, "RGBA")
        draw_emblem(dd, m)
        # thin gold inner border
        b = int(6 * s)
        ImageDraw.Draw(img, "RGBA").rounded_rectangle(
            [b, b, 512 * s - 1 - b, 512 * s - 1 - b],
            radius=int((512 * ICON_RADIUS_FRAC - 6) * s),
            outline=rgba(GOLD, 64), width=max(2, int(2.5 * s)))
    else:
        bg = build_background(512 * s, 512 * s, Mapper(s, shrink))
        img = bg
        draw_emblem(ImageDraw.Draw(img, "RGBA"), Mapper(s, shrink))
    out = img.resize((size_out, size_out), Image.LANCZOS)
    return out


# ---------------------------------------------------------------------------
# SVG output (vector source), generated from the same numbers
# --------------------------------------------------------------------------
def svg_n(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


def svg_terraces():
    out = []
    for r, a in zip(TERR_RADII, TERR_ALPHA):
        phi = math.radians(48.0)
        x1, y1 = TERR_C[0] - r * math.sin(phi), TERR_C[1] + r * math.cos(phi)
        x2, y2 = TERR_C[0] + r * math.sin(phi), TERR_C[1] + r * math.cos(phi)
        out.append(f'  <path d="M{svg_n(x1)} {svg_n(y1)} A{svg_n(r)} {svg_n(r)} 0 0 0 '
                   f'{svg_n(x2)} {svg_n(y2)}" stroke="#E9A63C" stroke-opacity="{a:.2f}" '
                   f'stroke-width="{TERR_SW:g}" fill="none" stroke-linecap="round"/>')
    return "\n".join(out)


def svg_ear(angle, scale):
    beta = math.radians(angle + 90.0)
    ca, sa = math.cos(beta), math.sin(beta)

    def l2g(x, y):
        x, y = x * scale, y * scale
        return (BASE_X + x * ca - y * sa, BASE_Y + x * sa + y * ca)
    out = [f' <g transform="translate({svg_n(l2g(0,0)[0])} {svg_n(l2g(0,0)[1])}) '
           f'rotate({svg_n(math.degrees(beta))}) scale({scale:.2f})">']
    out.append(f'  <path d="M{STEM_P0[0]:g} {STEM_P0[1]:g} '
               f'Q{STEM_C[0]:g} {STEM_C[1]:g} {STEM_P1[0]:g} {STEM_P1[1]:g}" '
               f'stroke="#E9A63C" stroke-width="{STEM_SW:g}" fill="none" '
               f'stroke-linecap="round"/>')
    gr = math.radians(34.0)
    for i in range(GRAIN_PAIRS):
        yy = -(GRAIN_Y0 + GRAIN_DY * i)
        f = 1.0 - 0.065 * i
        gl, gw = GRAIN_L * f, GRAIN_W * f
        d = gl / 2.0 - 8.0
        for s in (1, -1):
            ccx = math.sin(gr) * s * d
            ccy = yy - math.cos(gr) * d
            gamma = math.degrees(math.atan2(-math.cos(gr), s * math.sin(gr)))
            out.append(f'  <ellipse cx="{svg_n(ccx)}" cy="{svg_n(ccy)}" '
                       f'rx="{svg_n(gl/2)}" ry="{svg_n(gw/2)}" fill="#F6CF7A" '
                       f'transform="rotate({gamma:.1f} {svg_n(ccx)} {svg_n(ccy)})"/>')
    out.append(f'  <ellipse cx="{svg_n(STEM_P1[0])}" '
               f'cy="{svg_n(STEM_P1[1] - GRAIN_L*1.02/2 + 10):g}" '
               f'rx="{svg_n(GRAIN_L*1.02/2)}" ry="{svg_n(GRAIN_W*1.05/2)}" '
               f'fill="#F6CF7A" transform="rotate(-90 {svg_n(STEM_P1[0])} '
               f'{svg_n(STEM_P1[1] - GRAIN_L*1.02/2 + 10):g})"/>')
    out.append(" </g>")
    return "\n".join(out)


SVG_EMBLEM = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
 <defs>
  <linearGradient id="gGold" x1="0" y1="0" x2="0" y2="1">
   <stop offset="0" stop-color="#F6CF7A"/><stop offset="1" stop-color="#E9A63C"/>
  </linearGradient>
 </defs>
 <circle cx="{SUN_C[0]:g}" cy="{SUN_C[1]:g}" r="{SUN_R:g}" fill="#D97736" fill-opacity="0.20"/>
 <circle cx="{SUN_C[0]:g}" cy="{SUN_C[1]:g}" r="{SUN_R:g}" fill="none" stroke="#D97736" stroke-opacity="0.55" stroke-width="6"/>
{svg_terraces()}
{svg_ear(*EARS[0])}
{svg_ear(*EARS[1])}
{svg_ear(*EARS[2])}
</svg>
'''


SVG_LETTERS = {
    "V": ["M0 0 L28 80 L56 0"],
    "A": ["M8 80 L28 0 L48 80", "M15 52 H41"],
    "Y": ["M0 0 L28 38 L56 0", "M28 38 V80"],
    "L": ["M0 0 V80", "M0 80 H50"],
}


def svg_wordmark():
    out = [' <g stroke="url(#gGold)" stroke-width="%g" fill="none" '
           'stroke-linecap="round" stroke-linejoin="round">' % WORD_SW]
    x0 = (LOGO_W - 376.0) / 2.0
    for idx, ch in enumerate("VAYAL"):
        for pas in SVG_LETTERS[ch]:
            out.append(f'  <path transform="translate({svg_n(x0 + idx*ADVANCE)} '
                       f'{svg_n(WORD_TOP)})" d="{pas}"/>')
    out.append(" </g>")
    return "\n".join(out)


SVG_LOGO = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 700">
 <defs>
  <linearGradient id="gGold" x1="0" y1="0" x2="0" y2="1">
   <stop offset="0" stop-color="#F6CF7A"/><stop offset="1" stop-color="#E9A63C"/>
  </linearGradient>
 </defs>
 <circle cx="{SUN_C[0]:g}" cy="{SUN_C[1]:g}" r="{SUN_R:g}" fill="#D97736" fill-opacity="0.20"/>
 <circle cx="{SUN_C[0]:g}" cy="{SUN_C[1]:g}" r="{SUN_R:g}" fill="none" stroke="#D97736" stroke-opacity="0.55" stroke-width="6"/>
{svg_terraces()}
{svg_ear(*EARS[0])}
{svg_ear(*EARS[1])}
{svg_ear(*EARS[2])}
{svg_wordmark()}
</svg>
'''


# ---------------------------------------------------------------------------
# Main: write everything
# --------------------------------------------------------------------------
def save(img, rel, mode=None):
    path = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if mode == "RGB":
        img = img.convert("RGB")
    img.save(path)
    print("wrote", rel)


def main():
    icon_r = render_icon(rounded=True)
    icon_f = render_icon(rounded=False)         # full-bleed square (Android/iOS)
    icon_m = render_icon(rounded=False, shrink=0.80)  # maskable

    save(render_logo(), os.path.join("assets", "branding", "vayal_logo.png"))
    save(render_emblem(), os.path.join("assets", "branding", "vayal_emblem.png"))
    save(icon_r, os.path.join("assets", "branding", "vayal_icon.png"))

    # vector sources
    for rel, text in ((os.path.join("assets", "branding", "vayal_emblem.svg"), SVG_EMBLEM),
                      (os.path.join("assets", "branding", "vayal_logo.svg"), SVG_LOGO)):
        path = os.path.join(ROOT, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print("wrote", rel)

    # web
    save(icon_r.resize((16, 16), Image.LANCZOS), os.path.join("web", "favicon.png"))
    for s in (192, 512):
        save(icon_f.resize((s, s), Image.LANCZOS), os.path.join("web", "icons", f"Icon-{s}.png"))
    for s in (192, 512):
        save(icon_m.resize((s, s), Image.LANCZOS),
             os.path.join("web", "icons", f"Icon-maskable-{s}.png"))

    # android launcher mipmaps
    for dpi, s in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                   ("xxhdpi", 144), ("xxxhdpi", 192)):
        save(icon_f.resize((s, s), Image.LANCZOS),
             os.path.join("android", "app", "src", "main", "res",
                          f"mipmap-{dpi}", "ic_launcher.png"))

    # iOS AppIcon set (square corners)
    ios_sizes = {"Icon-App-20x20@1x.png": 20, "Icon-App-20x20@2x.png": 40,
                 "Icon-App-20x20@3x.png": 60, "Icon-App-29x29@1x.png": 29,
                 "Icon-App-29x29@2x.png": 58, "Icon-App-29x29@3x.png": 87,
                 "Icon-App-40x40@1x.png": 40, "Icon-App-40x40@2x.png": 80,
                 "Icon-App-40x40@3x.png": 120, "Icon-App-60x60@2x.png": 120,
                 "Icon-App-60x60@3x.png": 180, "Icon-App-76x76@1x.png": 76,
                 "Icon-App-76x76@2x.png": 152, "Icon-App-83.5x83.5@2x.png": 167,
                 "Icon-App-1024x1024@1x.png": 1024}
    for name, s in ios_sizes.items():
        save(icon_f.resize((s, s), Image.LANCZOS),
             os.path.join("ios", "Runner", "Assets.xcassets", "AppIcon.appiconset", name))

    # windows .ico
    ico_src = icon_f.resize((256, 256), Image.LANCZOS)
    ico_path = os.path.join(ROOT, "windows", "runner", "resources", "app_icon.ico")
    ico_src.save(ico_path, sizes=[(16, 16), (24, 24), (32, 32), (48, 48),
                                  (64, 64), (128, 128), (256, 256)])
    print("wrote windows/runner/resources/app_icon.ico")

    # preview sheet for quick visual check
    logo_small = render_logo().resize((375, 525), Image.LANCZOS)
    pv = Image.new("RGBA", (1100, 700), (20, 20, 22, 255))
    pv.paste(logo_small, (30, 30), logo_small)
    pv.paste(logo_small, (700, 30), logo_small)
    small_r = icon_r.resize((128, 128), Image.LANCZOS)
    small_f = icon_f.resize((128, 128), Image.LANCZOS)
    small_m = icon_m.resize((128, 128), Image.LANCZOS)
    for i, im in enumerate((small_r, small_f, small_m)):
        pv.paste(im, (470 + i * 145, 40), im)
    for i, s in enumerate((64, 48, 32, 16)):
        im = icon_f.resize((s, s), Image.LANCZOS)
        pv.paste(im, (470 + i * 80, 210), im)
    pv.save(os.path.join(ROOT, "tool", "preview.png"))
    print("wrote tool/preview.png")


if __name__ == "__main__":
    main()
