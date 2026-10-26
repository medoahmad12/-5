#!/usr/bin/env python3
"""Generates Android launcher mipmaps from assets/icon.png.
Run AFTER `flutter create .` (needs the android/ folder).

Usage:  python3 tools/make_icons.py
"""
import os
import shutil
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets", "icon.png")
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")

SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def main():
    if not os.path.exists(SRC):
        raise SystemExit("assets/icon.png not found")
    if not os.path.isdir(RES):
        raise SystemExit("android/ folder not found — run `flutter create .` first")

    img = Image.open(SRC).convert("RGBA")
    for folder, size in SIZES.items():
        dst_dir = os.path.join(RES, folder)
        os.makedirs(dst_dir, exist_ok=True)
        out = img.resize((size, size), Image.LANCZOS)
        out.save(os.path.join(dst_dir, "ic_launcher.png"))
        # Flutter's default template also references a foreground layer
        out.save(os.path.join(dst_dir, "ic_launcher_foreground.png"))
        print(f"{folder}: {size}px written")
    print("done — rebuild the app to see the new icon")


if __name__ == "__main__":
    main()
