"""Splits the HINDER training images into train and validation.

Reads the training rows of ml/splits/hinder_split.csv (the final train/test split) and
moves a share of them to validation, stratified by CIR level and grouped by group_id, so
no duplicate group is split across train and validation. Test images are never touched.

A group is assigned to the CIR level most of its images have. Within each level, groups
are shuffled with a fixed seed and moved to validation until the level reaches
round(val_frac * images in that level).

Usage (from the repo root):
    python ml/scripts/make_hinder_val_split.py
    python ml/scripts/make_hinder_val_split.py --val-frac 0.2 --seed 42
"""

from __future__ import annotations

import argparse
import csv
import random
from collections import Counter, defaultdict
from pathlib import Path

LEVELS = range(1, 10)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--split", type=Path, default=Path("ml/splits/hinder_split.csv"))
    ap.add_argument("--out", type=Path, default=Path("ml/splits/hinder_train_val_split.csv"))
    ap.add_argument("--val-frac", type=float, default=0.2)
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    with args.split.open(encoding="utf-8") as fh:
        all_rows = list(csv.DictReader(fh))
    rows = [r for r in all_rows if r["split"] == "train"]
    test_groups = {r["group_id"] for r in all_rows if r["split"] == "test"}
    for r in rows:
        r["cir"] = int(r["cir"])

    groups: dict[str, list[dict]] = defaultdict(list)
    for r in rows:
        groups[r["group_id"]].append(r)
    by_level: dict[int, list[str]] = defaultdict(list)
    for gid in sorted(groups):
        level = Counter(r["cir"] for r in groups[gid]).most_common(1)[0][0]
        by_level[level].append(gid)

    rng = random.Random(args.seed)
    val_groups: set[str] = set()
    for level in LEVELS:
        gids = by_level[level]
        rng.shuffle(gids)
        target = round(args.val_frac * sum(len(groups[g]) for g in gids))
        taken = 0
        for gid in gids:
            if taken >= target:
                break
            val_groups.add(gid)
            taken += len(groups[gid])

    out = []
    for r in rows:
        out.append({
            "split": "val" if r["group_id"] in val_groups else "train",
            "set": r["set"],
            "cir": r["cir"],
            "file": r["file"],
            "photo_id": r["photo_id"],
            "group_id": r["group_id"],
        })
    out.sort(key=lambda k: (k["split"] != "train", k["cir"], k["file"]))

    # Invariants.
    train = [k for k in out if k["split"] == "train"]
    val = [k for k in out if k["split"] == "val"]
    assert len(train) + len(val) == len(rows)
    assert not {k["group_id"] for k in train} & {k["group_id"] for k in val}
    assert not ({k["group_id"] for k in out} & test_groups), "a test group leaked into train/val"
    assert all(k["set"] == "hinder-2025" for k in out)
    vc = Counter(k["cir"] for k in val)
    assert all(vc[lv] > 0 for lv in LEVELS), "a CIR level has no validation images"

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(out[0]))
        w.writeheader()
        w.writerows(out)

    tc = Counter(k["cir"] for k in train)
    print(f"Wrote {args.out}  (val_frac {args.val_frac}, seed {args.seed})")
    print(f"train: {len(train)} images, {len({k['group_id'] for k in train})} groups")
    print(f"val:   {len(val)} images, {len({k['group_id'] for k in val})} groups")
    print("CIR    " + " ".join(f"{lv:>4}" for lv in LEVELS))
    print("train  " + " ".join(f"{tc[lv]:>4}" for lv in LEVELS))
    print("val    " + " ".join(f"{vc[lv]:>4}" for lv in LEVELS))


if __name__ == "__main__":
    main()
