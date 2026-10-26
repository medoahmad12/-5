#!/usr/bin/env python3
"""Processes raw generated images into app-ready assets.

Cutout pipeline (characters & objects):
  1. Coarse background estimate: border flood-fill + row-wise gradient model.
  2. GrabCut refinement (OpenCV) initialized from that estimate.
  3. Despill (pink fringe removal) + edge feather + trim + resize.
Backgrounds -> JPEG. Icon -> PNG.
"""
import os
import numpy as np
import cv2

RAW = "/home/z/my-project/little_explorers/assets/images/raw"
OUT = "/home/z/my-project/little_explorers/assets/images"
os.makedirs(f"{OUT}/chars", exist_ok=True)
os.makedirs(f"{OUT}/objects", exist_ok=True)
os.makedirs(f"{OUT}/bg", exist_ok=True)


def row_bg_model(bgr):
    """Per-row background color estimated from the left/right border strips."""
    h, w = bgr.shape[:2]
    strips = np.concatenate([bgr[:, :8], bgr[:, -8:]], axis=1)  # h x 16 x 3
    return np.median(strips, axis=1)  # h x 3


def coarse_bg_mask(bgr, near=50, far=110):
    """Background estimate from a row-wise gradient color model:
    pixels close to their row's border color are bg, far ones are fg.
    (Flood-fill was abandoned: it crawls through smooth object edges.)"""
    model = row_bg_model(bgr)
    dist = np.linalg.norm(
        bgr.astype(np.int16) - model[:, None, :].astype(np.int16), axis=2)
    return dist < near, dist


def cutout(src, dst, target=640):
    bgr = cv2.imread(src)
    if bgr is None:
        print("  !! cannot read", src)
        return 0.0
    h, w = bgr.shape[:2]

    bg, dist = coarse_bg_mask(bgr)

    # guard: model collapsed (bg covered everything) -> relax thresholds
    if bg.mean() > 0.985:
        bg, dist = coarse_bg_mask(bgr, near=70, far=100)

    gc = np.full((h, w), cv2.GC_PR_FGD, np.uint8)  # default: probably FG

    # Border-connected low-distance field = certain background.
    # Interior low-distance blobs (e.g. a robot head reflecting the studio
    # background) are NOT connected to the border -> protected as foreground.
    bin_low = (dist < 30).astype(np.uint8)
    n, labels = cv2.connectedComponents(bin_low, 4)
    border_labels = set(labels[0, :]) | set(labels[-1, :]) \
        | set(labels[:, 0]) | set(labels[:, -1]) - {0}
    bg = np.isin(labels, list(border_labels - {0}))

    gc[bg] = cv2.GC_BGD                                   # certain bg
    gc[(dist >= 26) & (dist < 62) & (~bg)] = cv2.GC_PR_BGD  # probable bg
    gc[(dist > 110) & (~bg)] = cv2.GC_FGD                 # certain fg
    # interior low-dist pockets stay PR_FGD (protected)

    bgd = np.zeros((1, 65), np.float64)
    fgd = np.zeros((1, 65), np.float64)
    try:
        cv2.grabCut(bgr, gc, None, bgd, fgd, 4, cv2.GC_INIT_WITH_MASK)
    except cv2.error:
        fg = ~bg
    else:
        fg = (gc == cv2.GC_PR_FGD) | (gc == cv2.GC_FGD)

    # sanity guards: if grabcut collapsed, fall back to the coarse inverse
    frac = fg.mean()
    if frac < 0.02 or frac > 0.97:
        fg = ~bg

    # keep the largest foreground component (drop stray blobs)
    n, labels, stats, _ = cv2.connectedComponentsWithStats(
        fg.astype(np.uint8), 8)
    if n > 1:
        biggest = 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])
        fg = labels == biggest

    alpha = (fg * 255).astype(np.uint8)
    alpha = cv2.erode(alpha, np.ones((3, 3), np.uint8))
    alpha = cv2.GaussianBlur(alpha, (5, 5), 1.1)

    # despill: pink fringe -> pull r/b toward g (operate in RGB)
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB).astype(np.int16)
    a = alpha.astype(np.int16)
    spill = (a > 0) & (a < 250) & (rgb[..., 0] > rgb[..., 1] + 26) \
        & (rgb[..., 2] > rgb[..., 1] + 16)
    for c in (0, 2):
        rgb[..., c][spill] = (rgb[..., 1][spill] * 2 + rgb[..., c][spill]) // 3

    rgba = np.dstack([rgb.clip(0, 255).astype(np.uint8), alpha])
    # trim + resize
    ys, xs = np.where(alpha > 10)
    if len(xs) == 0:
        print("  !! empty cutout", src)
        return 0.0
    pad = 14
    l, t = max(0, xs.min() - pad), max(0, ys.min() - pad)
    r, b = min(w, xs.max() + pad), min(h, ys.max() + pad)
    out = rgba[t:b, l:r]
    scale = target / max(out.shape[:2])
    if scale < 1:
        nw, nh = max(1, int(out.shape[1] * scale)), max(1, int(out.shape[0] * scale))
        out = cv2.resize(out, (nw, nh), interpolation=cv2.INTER_AREA)
    cv2.imwrite(dst, cv2.cvtColor(out, cv2.COLOR_RGBA2BGRA))
    return (out[..., 3] > 40).mean()


def process_bg(src, dst):
    img = cv2.imread(src)
    img = cv2.resize(img, (720, 1260), interpolation=cv2.INTER_AREA)
    cv2.imwrite(dst, img, [cv2.IMWRITE_JPEG_QUALITY, 82])


def main():
    report = []
    for f in sorted(os.listdir(f"{RAW}/chars")):
        if f.endswith(".png"):
            cov = cutout(f"{RAW}/chars/{f}", f"{OUT}/chars/{f}", 720)
            report.append((f"chars/{f}", cov))
    for f in sorted(os.listdir(f"{RAW}/objects")):
        if f.endswith(".png"):
            cov = cutout(f"{RAW}/objects/{f}", f"{OUT}/objects/{f}", 520)
            report.append((f"objects/{f}", cov))
    for f in sorted(os.listdir(f"{RAW}/bg")):
        if f.endswith(".png"):
            process_bg(f"{RAW}/bg/{f}", f"{OUT}/bg/{f.replace('.png', '.jpg')}")
            report.append((f"bg/{f}", 1.0))
    icon = f"{RAW}/icon/icon_base.png"
    if os.path.exists(icon):
        img = cv2.imread(icon)
        img = cv2.resize(img, (512, 512), interpolation=cv2.INTER_AREA)
        cv2.imwrite("/home/z/my-project/little_explorers/assets/icon.png", img)
        report.append(("icon.png", 1.0))

    print(f"processed {len(report)} images")
    for name, cov in report:
        flag = "  <-- CHECK" if cov < 0.06 else ""
        print(f"  {name}: {cov:.2f}{flag}")


if __name__ == "__main__":
    main()
