"""Captures de la fiche Google Play, au format 1080 x 1920 (9:16).

Chaque capture brute est posée sur le fond bleu de l'appli, sous une légende
courte : le format exigé pour être mis en avant sur Google Play (au moins
quatre captures, 1080 px au minimum, 9:16), valable aussi pour les sections
tablette 7 et 10 pouces. Le texte reste bien sous la limite de 20 % de
l'image fixée par Google.

Usage (Python 3 et Pillow) :
    python tool/store_screenshots.py store/captures store/screenshots

Les captures brutes sont prises dans l'ordre alphabétique de leur nom ; les
légendes viennent de LEGENDES, dans le même ordre. Préfixer les fichiers
(1-accueil.png, 2-koi.png…) suffit à fixer l'ordre.
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1080, 1920
DEEP, MID = (20, 66, 90), (44, 110, 143)
WHITE = (248, 245, 240)
HI = (240, 113, 74)

# (titre, sous-titre) : sobres, sans superlatif ni classement (règles Play).
LEGENDES = [
    ("Votre bassin", "d'un coup d'œil"),
    ("Chaque koï", "sa fiche, sa lignée, sa croissance"),
    ("Vos plantes", "rangées par zone"),
    ("La qualité de l'eau", "relevé après relevé"),
    ("Toute votre collection", "en photos"),
    ("Les autres habitants", "du bassin"),
    ("Votre carnet", "en clair comme en sombre"),
    ("Vos données", "à vous seul"),
]


def font(size, bold=False):
    names = ["segoeuib.ttf", "seguisb.ttf"] if bold else ["segoeui.ttf"]
    for name in names:
        path = Path(r"C:\Windows\Fonts") / name
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default(size)


def background():
    img = Image.new("RGB", (W, H))
    px = img.load()
    for y in range(H):
        for x in range(W):
            t = (x / W) * 0.45 + (y / H) * 0.55
            px[x, y] = tuple(int(DEEP[i] + (MID[i] - DEEP[i]) * t) for i in range(3))
    waves = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(waves)
    for i in range(5):
        base = H * (0.08 + i * 0.21)
        pts = [(x, base + math.sin(x / W * 2 * math.pi * (1.2 + i * 0.3) + i) * 14)
               for x in range(0, W + 8, 8)]
        d.line(pts, fill=(255, 255, 255, 18), width=3)
    return Image.alpha_composite(img.convert("RGBA"), waves)


def compose(shot_path, title, subtitle):
    canvas = background()
    d = ImageDraw.Draw(canvas)

    # Légende : 15 % de la hauteur environ.
    f_title, f_sub = font(76, bold=True), font(44)
    y = 96
    tw = d.textlength(title, font=f_title)
    d.text(((W - tw) / 2, y), title, font=f_title, fill=WHITE)
    y += 100
    sw = d.textlength(subtitle, font=f_sub)
    d.text(((W - sw) / 2, y), subtitle, font=f_sub, fill=(248, 245, 240, 215))
    d.rounded_rectangle([(W - 64) / 2, y + 76, (W + 64) / 2, y + 82], 3, fill=HI)

    # Capture, ajustée dans la zone restante, coins arrondis et ombre douce.
    top, margin, bottom = 360, 50, 60
    shot = Image.open(shot_path).convert("RGB")
    scale = min((W - 2 * margin) / shot.width, (H - top - bottom) / shot.height)
    size = (round(shot.width * scale), round(shot.height * scale))
    shot = shot.resize(size, Image.LANCZOS)
    # Centrée dans la place qui reste sous la légende.
    x0, y0 = (W - size[0]) // 2, top + (H - top - bottom - size[1]) // 2
    radius = 40

    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius, fill=255)

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x0, y0 + 18, x0 + size[0], y0 + size[1] + 18], radius, fill=(0, 0, 0, 120))
    canvas = Image.alpha_composite(canvas, shadow.filter(ImageFilter.GaussianBlur(28)))
    canvas.paste(shot, (x0, y0), mask)
    return canvas.convert("RGB")


def main(src, dst):
    src, dst = Path(src), Path(dst)
    dst.mkdir(parents=True, exist_ok=True)
    shots = sorted(p for p in src.iterdir() if p.suffix.lower() in {".png", ".jpg", ".jpeg"})
    if not shots:
        sys.exit(f"Aucune capture dans {src}")
    for i, shot in enumerate(shots[: len(LEGENDES)]):
        title, subtitle = LEGENDES[i]
        # JPEG sans sous-échantillonnage des couleurs : le texte de l'interface
        # reste net, pour un fichier quatre fois plus léger qu'en PNG.
        out = dst / f"{i + 1:02d}-{shot.stem}.jpg"
        compose(shot, title, subtitle).save(out, quality=93, subsampling=0, optimize=True)
        print(out, Image.open(shot).size, "->", (W, H))


if __name__ == "__main__":
    main(*sys.argv[1:3])
