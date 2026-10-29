"""Exploratory analysis of the HINDER clutter image sets.

HINDER-2025 is the training set and HINDER-2018 the cross-dataset test set. For each
set this script reports the class distribution over the nine-point Clutter Image
Rating (CIR) scale, image resolution, unreadable files, and duplicates (exact by
SHA-256, near by perceptual hash), both within each set and between the two.

Usage (from the repo root):
    python ml/eda/hinder_eda.py
    python ml/eda/hinder_eda.py --data ml/data --out ml/eda/output --workers 8

Outputs in --out:
    summary.json                 every number quoted in docs/DATA.md
    manifest.csv                 one row per image
    near_duplicate_pairs.csv     every pair at pHash distance <= --near
    class_distribution.png       images per CIR level, both sets
    resolution.png               width x height, both sets
    phash_distances.png          nearest-neighbour pHash distance
    test_overlap.png             HINDER-2018 images also present in HINDER-2025
    label_change.png             CIR of the same photo in each set
    images_samples_<set>.png     sample grid (dataset images: git-ignored)
    images_check_pairs.png       near pairs with different photo IDs, to check by eye
                                 (dataset images: git-ignored)
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import random
import re
import warnings
from collections import Counter, defaultdict
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import imagehash
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from PIL import Image, ImageOps  # noqa: E402

SETS = {"hinder-2025": "HINDER-2025 (train)", "hinder-2018": "HINDER-2018 (test)"}
LEVELS = list(range(1, 10))
SEED = 42

# Validated categorical slots 1-3 (dataviz reference palette), in fixed order.
BLUE, ORANGE, AQUA = "#2a78d6", "#eb6834", "#1baf7a"
INK, INK_2, GRID, SURFACE = "#0b0b0b", "#52514e", "#e4e3df", "#fcfcfb"
COLORS = {"hinder-2025": BLUE, "hinder-2018": ORANGE}

plt.rcParams.update({
    "figure.facecolor": SURFACE,
    "axes.facecolor": SURFACE,
    "axes.edgecolor": GRID,
    "axes.labelcolor": INK_2,
    "axes.titlecolor": INK,
    "axes.titlesize": 12,
    "axes.titleweight": "bold",
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.grid": True,
    "grid.color": GRID,
    "grid.linewidth": 1,
    "xtick.color": INK_2,
    "ytick.color": INK_2,
    "legend.frameon": False,
    "font.size": 10,
})


# Files are named CIR_<level>_<photo id>.<ext>; the ID is shared across both sets.
_NAME = re.compile(r"^CIR_(\d)_([0-9a-f]+)\.\w+$", re.IGNORECASE)


def photo_id(file: str) -> str:
    m = _NAME.match(file)
    return m.group(2).lower() if m else file


def inspect(path: Path) -> dict:
    """Fully decodes one file. Never raises; failures are recorded."""
    data = path.read_bytes()
    row = {
        "bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
        "ok": False,
        "error": "",
        "warnings": "",
        "format": "",
        "mode": "",
        "width": 0,
        "height": 0,
        "exif_orientation": 1,
        "phash": "",
    }
    with warnings.catch_warnings(record=True) as caught:
        warnings.simplefilter("always")
        try:
            with Image.open(path) as im:
                row["format"] = im.format or ""
                row["mode"] = im.mode
                row["exif_orientation"] = int(im.getexif().get(0x0112, 1) or 1)
                im.load()  # full decode: catches truncated or broken JPEGs
                upright = ImageOps.exif_transpose(im)
                row["width"], row["height"] = upright.size
                row["phash"] = str(imagehash.phash(upright))
                row["ok"] = True
        except Exception as e:  # noqa: BLE001 - any failure means unreadable
            row["error"] = f"{type(e).__name__}: {e}"
    row["warnings"] = " | ".join(sorted({str(w.message) for w in caught}))
    return row


def scan(data_root: Path, workers: int) -> list[dict]:
    jobs = []
    for name in SETS:
        for level in LEVELS:
            folder = data_root / name / f"CIR {level}"
            for p in sorted(folder.iterdir()):
                if p.is_file():
                    jobs.append({"set": name, "cir": level, "file": p.name,
                                 "image_id": photo_id(p.name), "path": p})
    with ProcessPoolExecutor(max_workers=workers) as pool:
        results = pool.map(inspect, [j["path"] for j in jobs], chunksize=8)
        rows = [j | r for j, r in zip(jobs, results)]
    return rows


def hamming_matrix(hashes: list[str]) -> np.ndarray:
    bits = np.array(
        [np.unpackbits(np.frombuffer(bytes.fromhex(h), dtype=np.uint8)) for h in hashes],
        dtype=np.int32,
    )
    return bits @ (1 - bits).T + (1 - bits) @ bits.T


def duplicates(rows: list[dict], near: int) -> tuple[dict, list[dict], np.ndarray]:
    ok = [r for r in rows if r["ok"]]
    for i, r in enumerate(ok):
        r["idx"] = i
    dist = hamming_matrix([r["phash"] for r in ok])
    np.fill_diagonal(dist, 999)

    out: dict = {}
    for name in SETS:
        members = [r for r in ok if r["set"] == name]
        by_sha = defaultdict(list)
        for r in members:
            by_sha[r["sha256"]].append(r)
        groups = [g for g in by_sha.values() if len(g) > 1]
        out[name] = {
            "exact_duplicate_groups": len(groups),
            "exact_duplicate_extra_files": sum(len(g) - 1 for g in groups),
            "exact_groups_with_conflicting_cir": sum(
                len({r["cir"] for r in g}) > 1 for g in groups
            ),
        }

    pairs = []
    ii, jj = np.where(np.triu(dist <= near, k=1))
    for i, j in zip(ii.tolist(), jj.tolist()):
        a, b = ok[i], ok[j]
        pairs.append({
            "set_a": a["set"], "cir_a": a["cir"], "file_a": a["file"],
            "set_b": b["set"], "cir_b": b["cir"], "file_b": b["file"],
            "phash_distance": int(dist[i, j]),
            "identical_bytes": a["sha256"] == b["sha256"],
        })
    for name in SETS:
        inside = [p for p in pairs if p["set_a"] == name and p["set_b"] == name]
        out[name]["near_pairs_within"] = len(inside)
        out[name]["near_pairs_within_not_identical"] = sum(
            not p["identical_bytes"] for p in inside
        )
        out[name]["near_pairs_within_conflicting_cir"] = sum(
            p["cir_a"] != p["cir_b"] for p in inside
        )
    return out, pairs, dist


STATUSES = ["identical file in 2025", "same photo, re-encoded, in 2025", "not in 2025"]


def test_overlap(rows: list[dict], dist: np.ndarray, near: int) -> dict:
    """Where each HINDER-2018 image stands relative to HINDER-2025.

    A test image counts as present in 2025 if its bytes match (SHA-256), its photo ID
    matches, or its pHash is within `near` bits of a 2025 image.
    """
    ok = [r for r in rows if r["ok"]]
    train = [r for r in ok if r["set"] == "hinder-2025"]
    test = [r for r in ok if r["set"] == "hinder-2018"]
    train_sha = {r["sha256"] for r in train}
    train_by_id = {r["image_id"]: r for r in train}
    train_idx = np.array([r["idx"] for r in train])

    per_cir = {lv: Counter() for lv in LEVELS}
    cir_change = Counter()
    id_but_far, near_other_id = [], []
    for r in test:
        row_d = dist[r["idx"], train_idx]
        nearest = int(row_d.min())
        twin = train_by_id.get(r["image_id"])
        if r["sha256"] in train_sha:
            status = STATUSES[0]
        elif twin is not None or nearest <= near:
            status = STATUSES[1]
        else:
            status = STATUSES[2]
        if twin is not None:
            cir_change[twin["cir"] - r["cir"]] += 1
            if dist[r["idx"], twin["idx"]] > near:
                id_but_far.append(f'{r["file"]} (pHash distance {int(dist[r["idx"], twin["idx"]])})')
        elif nearest <= near:
            match = train[int(row_d.argmin())]
            near_other_id.append(
                f'2018 CIR {r["cir"]}/{r["file"]} ~ 2025 CIR {match["cir"]}/{match["file"]} (d={nearest})'
            )
        r["in_2025"] = status
        r["nearest_2025_distance"] = nearest
        per_cir[r["cir"]][status] += 1

    independent = {lv: per_cir[lv][STATUSES[2]] for lv in LEVELS}
    test_idx = np.array([r["idx"] for r in test])
    test_ids = {r["image_id"] for r in test}
    train_clean = [
        r for r in train
        if r["image_id"] not in test_ids and dist[r["idx"], test_idx].min() > near
    ]
    return {
        "photo_ids_shared": sum(r["image_id"] in train_by_id for r in test),
        "by_status": {s: sum(c[s] for c in per_cir.values()) for s in STATUSES},
        "by_cir": {lv: {s: per_cir[lv][s] for s in STATUSES} for lv in LEVELS},
        "independent_test_images_by_cir": independent,
        "train_images_not_in_2018": len(train_clean),
        "shared_photos_cir_change_2025_minus_2018": {
            str(k): cir_change[k] for k in sorted(cir_change)
        },
        "shared_photo_id_but_phash_far": id_but_far,
        "near_duplicate_with_different_photo_id": near_other_id,
    }


def set_stats(rows: list[dict]) -> dict:
    out = {}
    for name in SETS:
        rs = [r for r in rows if r["set"] == name]
        good = [r for r in rs if r["ok"]]
        w = np.array([r["width"] for r in good])
        h = np.array([r["height"] for r in good])
        short = np.minimum(w, h)
        out[name] = {
            "files": len(rs),
            "per_cir": {lv: sum(r["cir"] == lv for r in rs) for lv in LEVELS},
            "unreadable": [f'CIR {r["cir"]}/{r["file"]}: {r["error"]}' for r in rs if not r["ok"]],
            "with_decoder_warnings": sum(bool(r["warnings"]) for r in rs),
            "formats": dict(Counter(r["format"] for r in good)),
            "modes": dict(Counter(r["mode"] for r in good)),
            "exif_rotated": sum(r["exif_orientation"] != 1 for r in good),
            "size_mb_total": round(sum(r["bytes"] for r in rs) / 1e6, 1),
            "width": _describe(w),
            "height": _describe(h),
            "short_side": _describe(short),
            "short_side_below_224": int((short < 224).sum()),
            "short_side_below_384": int((short < 384).sum()),
            "portrait": int((h > w).sum()),
            "landscape": int((w > h).sum()),
            "square": int((w == h).sum()),
            "distinct_resolutions": len({(a, b) for a, b in zip(w, h)}),
            "names_not_matching_pattern": sum(not _NAME.match(r["file"]) for r in rs),
            "name_level_differs_from_folder": sum(
                bool(_NAME.match(r["file"])) and int(_NAME.match(r["file"]).group(1)) != r["cir"]
                for r in rs
            ),
            "repeated_photo_ids": sum(
                c > 1 for c in Counter(r["image_id"] for r in rs).values()
            ),
            "extension_differs_from_format": sum(
                r["format"] not in ("JPEG", "MPO") for r in good
            ),
        }
    return out


def _describe(a: np.ndarray) -> dict:
    return {
        "min": int(a.min()),
        "p5": int(np.percentile(a, 5)),
        "median": int(np.median(a)),
        "p95": int(np.percentile(a, 95)),
        "max": int(a.max()),
    }


# ---------- plots ----------

def _bar(ax, x, heights, color, **kw):
    return ax.bar(x, heights, color=color, edgecolor=SURFACE, linewidth=2, **kw)


def plot_classes(stats: dict, out: Path) -> None:
    fig, ax = plt.subplots(figsize=(9, 4.2))
    width = 0.38
    x = np.arange(len(LEVELS))
    for k, name in enumerate(SETS):
        counts = [stats[name]["per_cir"][lv] for lv in LEVELS]
        bars = _bar(ax, x + (k - 0.5) * width, counts, COLORS[name], width=width,
                    label=f'{SETS[name]} - {sum(counts):,} images')
        ax.bar_label(bars, padding=2, fontsize=8, color=INK_2)
    ax.set_xticks(x, [f"CIR {lv}" for lv in LEVELS])
    ax.set_ylabel("Images")
    ax.set_title("Images per Clutter Image Rating level", loc="left")
    ax.grid(axis="x", visible=False)
    ax.legend(loc="upper left", ncols=2)
    ax.set_ylim(0, max(max(s["per_cir"].values()) for s in stats.values()) * 1.18)
    fig.tight_layout()
    fig.savefig(out / "class_distribution.png", dpi=150)
    plt.close(fig)


def plot_resolution(rows: list[dict], out: Path) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(10, 4.4), sharex=True, sharey=True)
    for ax, name in zip(axes, SETS):
        good = [r for r in rows if r["set"] == name and r["ok"]]
        ax.scatter([r["width"] for r in good], [r["height"] for r in good], s=12,
                   color=COLORS[name], alpha=0.45, edgecolors="none")
        ticks = [200, 500, 1000, 2000, 5000]
        ax.set_xscale("log")
        ax.set_yscale("log")
        ax.set_xticks(ticks, [f"{t:,}" for t in ticks])
        ax.set_yticks(ticks, [f"{t:,}" for t in ticks])
        ax.minorticks_off()
        ax.axvline(224, color=INK_2, linewidth=1)
        ax.axhline(224, color=INK_2, linewidth=1)
        ax.text(4000, 235, "224 px (ViT input)", color=INK_2, fontsize=8, ha="right",
                va="bottom")
        ax.set_title(f"{SETS[name]} - {len(good):,} images", loc="left")
        ax.set_xlabel("Width (px, after EXIF rotation)")
    axes[0].set_ylabel("Height (px)")
    fig.suptitle("Image resolution", x=0.01, ha="left", fontweight="bold", color=INK)
    fig.tight_layout()
    fig.savefig(out / "resolution.png", dpi=150)
    plt.close(fig)


def plot_phash(rows: list[dict], dist: np.ndarray, near: int, out: Path) -> None:
    ok = [r for r in rows if r["ok"]]
    idx = {name: np.array([r["idx"] for r in ok if r["set"] == name]) for name in SETS}
    series = {
        "Within HINDER-2025": dist[np.ix_(idx["hinder-2025"], idx["hinder-2025"])].min(1),
        "Within HINDER-2018": dist[np.ix_(idx["hinder-2018"], idx["hinder-2018"])].min(1),
        "HINDER-2018 to nearest HINDER-2025": dist[np.ix_(idx["hinder-2018"], idx["hinder-2025"])].min(1),
    }
    fig, axes = plt.subplots(1, 3, figsize=(12, 3.8), sharey=False)
    bins = np.arange(0, 41)
    for ax, (title, d), color in zip(axes, series.items(), [BLUE, ORANGE, AQUA]):
        ax.hist(np.minimum(d, 40), bins=bins, color=color, edgecolor=SURFACE, linewidth=1)
        ax.axvline(near + 0.5, color=INK_2, linewidth=1)
        ax.text(near + 1, ax.get_ylim()[1] * 0.92, f"near-duplicate\nthreshold <= {near}",
                fontsize=8, color=INK_2, va="top")
        ax.set_title(title, loc="left", fontsize=10)
        ax.set_xlabel("pHash distance to nearest other image (bits of 64)")
        ax.grid(axis="x", visible=False)
    axes[0].set_ylabel("Images")
    fig.tight_layout()
    fig.savefig(out / "phash_distances.png", dpi=150)
    plt.close(fig)


def plot_overlap(overlap: dict, out: Path) -> None:
    statuses = list(zip(STATUSES, [ORANGE, AQUA, BLUE]))
    fig, ax = plt.subplots(figsize=(9, 4.2))
    x = np.arange(len(LEVELS))
    bottom = np.zeros(len(LEVELS))
    for status, color in statuses:
        vals = np.array([overlap["by_cir"][lv][status] for lv in LEVELS])
        total = overlap["by_status"][status]
        _bar(ax, x, vals, color, width=0.6, bottom=bottom, label=f"{status} ({total:,})")
        bottom += vals
    for xi, b in zip(x, bottom):
        ax.text(xi, b + 2, f"{int(b)}", ha="center", fontsize=8, color=INK_2)
    ax.set_xticks(x, [f"CIR {lv}" for lv in LEVELS])
    ax.set_ylabel("HINDER-2018 images")
    ax.set_title("Is each HINDER-2018 test image also in HINDER-2025?", loc="left")
    ax.grid(axis="x", visible=False)
    ax.legend(loc="upper left")
    ax.set_ylim(0, bottom.max() * 1.25)
    fig.tight_layout()
    fig.savefig(out / "test_overlap.png", dpi=150)
    plt.close(fig)


def _thumb(path: Path, size: int = 220) -> Image.Image:
    with Image.open(path) as im:
        im.draft("RGB", (size * 2, size * 2))
        im = ImageOps.exif_transpose(im).convert("RGB")
        return ImageOps.fit(im, (size, size))


def plot_samples(rows: list[dict], name: str, out: Path, levels=(1, 3, 5, 7, 9), per=5) -> None:
    rng = random.Random(SEED)
    fig, axes = plt.subplots(len(levels), per, figsize=(per * 1.9, len(levels) * 2.0))
    for r_i, lv in enumerate(levels):
        pool = [r for r in rows if r["set"] == name and r["cir"] == lv and r["ok"]]
        for c_i, r in enumerate(rng.sample(pool, per)):
            ax = axes[r_i][c_i]
            ax.imshow(_thumb(r["path"]))
            ax.set_xticks([])
            ax.set_yticks([])
            ax.grid(False)
            for s in ax.spines.values():
                s.set_visible(False)
            if c_i == 0:
                ax.set_ylabel(f"CIR {lv}", rotation=0, ha="right", va="center",
                              fontsize=11, color=INK)
    fig.suptitle(f"{SETS[name]}: random samples (seed {SEED})", x=0.01, ha="left",
                 fontweight="bold", color=INK)
    fig.tight_layout()
    fig.savefig(out / f"images_samples_{name}.png", dpi=110)
    plt.close(fig)


def plot_label_change(overlap: dict, out: Path) -> None:
    change = {int(k): v for k, v in overlap["shared_photos_cir_change_2025_minus_2018"].items()}
    xs = list(range(min(change), max(change) + 1))
    vals = [change.get(x, 0) for x in xs]
    fig, ax = plt.subplots(figsize=(7, 3.8))
    bars = _bar(ax, xs, vals, BLUE, width=0.6)
    ax.bar_label(bars, padding=2, fontsize=8, color=INK_2)
    ax.set_xticks(xs, [f"{x:+d}" if x else "0" for x in xs])
    ax.set_xlabel("CIR in HINDER-2025 minus CIR in HINDER-2018")
    ax.set_ylabel("Photos in both sets")
    ax.set_title(f"Same photo, rating in each set ({sum(vals):,} shared photos)", loc="left")
    ax.grid(axis="x", visible=False)
    ax.set_ylim(0, max(vals) * 1.15)
    fig.tight_layout()
    fig.savefig(out / "label_change.png", dpi=150)
    plt.close(fig)


def plot_check_pairs(rows: list[dict], pairs: list[dict], out: Path) -> None:
    """Near pairs whose photo IDs differ, for checking the threshold by eye."""
    lookup = {(r["set"], r["cir"], r["file"]): r["path"] for r in rows}
    shown = sorted((p for p in pairs if photo_id(p["file_a"]) != photo_id(p["file_b"])),
                   key=lambda p: p["phash_distance"])
    if not shown:
        return
    fig, axes = plt.subplots(len(shown), 2, figsize=(5, len(shown) * 2.4))
    axes = np.atleast_2d(axes)
    for row_axes, p in zip(axes, shown):
        for ax, side in zip(row_axes, "ab"):
            key = (p[f"set_{side}"], p[f"cir_{side}"], p[f"file_{side}"])
            ax.imshow(_thumb(lookup[key]))
            ax.set_xticks([])
            ax.set_yticks([])
            ax.grid(False)
            ax.set_title(f"{key[0][-4:]} CIR {key[1]}\n{key[2]}", fontsize=7, color=INK_2)
        row_axes[0].set_ylabel(f"d={p['phash_distance']}", rotation=0, ha="right",
                               va="center", fontsize=10, color=INK)
    fig.tight_layout()
    fig.savefig(out / "images_check_pairs.png", dpi=100)
    plt.close(fig)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--data", type=Path, default=Path("ml/data"))
    ap.add_argument("--out", type=Path, default=Path("ml/eda/output"))
    ap.add_argument("--near", type=int, default=8,
                    help="pHash Hamming distance at or below which two images count as near duplicates")
    ap.add_argument("--workers", type=int, default=8)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    rows = scan(args.data, args.workers)
    stats = set_stats(rows)
    dupes, pairs, dist = duplicates(rows, args.near)
    overlap = test_overlap(rows, dist, args.near)

    summary = {
        "seed": SEED,
        "near_duplicate_threshold": args.near,
        "sets": {name: stats[name] | dupes[name] for name in SETS},
        "hinder_2018_vs_2025": overlap,
    }
    (args.out / "summary.json").write_text(json.dumps(summary, indent=2))

    fields = ["set", "cir", "file", "image_id", "bytes", "sha256", "ok", "error", "warnings", "format",
              "mode", "width", "height", "exif_orientation", "phash", "in_2025",
              "nearest_2025_distance"]
    with (args.out / "manifest.csv").open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    with (args.out / "near_duplicate_pairs.csv").open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(pairs[0]) if pairs else ["none"])
        w.writeheader()
        w.writerows(pairs)

    plot_classes(stats, args.out)
    plot_resolution(rows, args.out)
    plot_phash(rows, dist, args.near, args.out)
    plot_overlap(overlap, args.out)
    for name in SETS:
        plot_samples(rows, name, args.out)
    plot_label_change(overlap, args.out)
    plot_check_pairs(rows, pairs, args.out)

    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
