"""Builds the HINDER train/test split (Option B in docs/DATA.md).

Every image in HINDER-2025 and HINDER-2018 is put in a duplicate group: two images share
a group if they have the same photo ID, the same file bytes, or perceptual hashes within
--near bits, applied transitively. A group that contains any HINDER-2018 image goes to
test; every other group (HINDER-2025 only) goes to train. All of HINDER-2018 is test, and
no group is split across train and test.

Reads the per-image hashes from ml/eda/output/manifest.csv, so run
ml/eda/hinder_eda.py first.

Usage (from the repo root):
    python ml/scripts/make_hinder_split.py
    python ml/scripts/make_hinder_split.py --manifest ml/eda/output/manifest.csv \
        --data ml/data --out ml/splits/hinder_split.csv
"""

from __future__ import annotations

import argparse
import csv
from collections import Counter
from pathlib import Path

import numpy as np

TRAIN_SET, TEST_SET = "hinder-2025", "hinder-2018"
LEVELS = range(1, 10)


class UnionFind:
    def __init__(self, n: int) -> None:
        self.parent = list(range(n))

    def find(self, i: int) -> int:
        while self.parent[i] != i:
            self.parent[i] = self.parent[self.parent[i]]
            i = self.parent[i]
        return i

    def union(self, a: int, b: int) -> None:
        ra, rb = self.find(a), self.find(b)
        if ra != rb:
            self.parent[max(ra, rb)] = min(ra, rb)


def phash_distances(hashes: list[str]) -> np.ndarray:
    bits = np.array(
        [np.unpackbits(np.frombuffer(bytes.fromhex(h), dtype=np.uint8)) for h in hashes],
        dtype=np.int32,
    )
    return bits @ (1 - bits).T + (1 - bits) @ bits.T


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--manifest", type=Path, default=Path("ml/eda/output/manifest.csv"))
    ap.add_argument("--data", type=Path, default=Path("ml/data"))
    ap.add_argument("--out", type=Path, default=Path("ml/splits/hinder_split.csv"))
    ap.add_argument("--near", type=int, default=8,
                    help="pHash Hamming distance at or below which two images are one group")
    args = ap.parse_args()

    with args.manifest.open(encoding="utf-8") as fh:
        rows = [r for r in csv.DictReader(fh) if r["set"] in (TRAIN_SET, TEST_SET)]
    for r in rows:
        r["cir"] = int(r["cir"])
        path = args.data / r["set"] / f'CIR {r["cir"]}' / r["file"]
        if not path.is_file() or path.stat().st_size != int(r["bytes"]):
            raise SystemExit(f"{path} is missing or changed since the manifest was built")
    if any(r["ok"] != "True" for r in rows):
        raise SystemExit("manifest lists unreadable images; resolve them first")

    # Group duplicates across both sets.
    uf = UnionFind(len(rows))
    for key in ("image_id", "sha256"):
        first: dict[str, int] = {}
        for i, r in enumerate(rows):
            j = first.setdefault(r[key], i)
            if j != i:
                uf.union(i, j)
    dist = phash_distances([r["phash"] for r in rows])
    for i, j in zip(*np.where(np.triu(dist <= args.near, k=1))):
        uf.union(int(i), int(j))

    members: dict[int, list[int]] = {}
    for i in range(len(rows)):
        members.setdefault(uf.find(i), []).append(i)
    for root, idx in members.items():
        group_id = min(rows[i]["image_id"] for i in idx)
        split = "test" if any(rows[i]["set"] == TEST_SET for i in idx) else "train"
        for i in idx:
            rows[i]["group_id"] = group_id
            rows[i]["group_size"] = len(idx)
            rows[i]["split"] = split

    # The same photo's rating in HINDER-2025, where it has one (test images only).
    cir_2025 = {r["image_id"]: r["cir"] for r in rows if r["set"] == TRAIN_SET}

    kept = []
    for r in rows:
        if r["set"] == TRAIN_SET and r["split"] == "test":
            continue  # a 2025 copy of a test photo: dropped from training
        kept.append({
            "split": r["split"],
            "set": r["set"],
            "cir": r["cir"],
            "cir_2025": cir_2025.get(r["image_id"], "") if r["set"] == TEST_SET else "",
            "file": f'{r["set"]}/CIR {r["cir"]}/{r["file"]}',
            "photo_id": r["image_id"],
            "group_id": r["group_id"],
            "group_size": r["group_size"],
        })
    kept.sort(key=lambda k: (k["split"] != "train", k["set"], k["cir"], k["file"]))

    # Invariants.
    train = [k for k in kept if k["split"] == "train"]
    test = [k for k in kept if k["split"] == "test"]
    assert all(k["set"] == TRAIN_SET for k in train)
    assert all(k["set"] == TEST_SET for k in test)
    assert len(test) == sum(r["set"] == TEST_SET for r in rows), "all of HINDER-2018 is test"
    assert not {k["group_id"] for k in train} & {k["group_id"] for k in test}
    assert not {k["photo_id"] for k in train} & {k["photo_id"] for k in test}
    by_file = {f'{r["set"]}/CIR {r["cir"]}/{r["file"]}': i for i, r in enumerate(rows)}
    tr = [by_file[k["file"]] for k in train]
    te = [by_file[k["file"]] for k in test]
    assert not {rows[i]["sha256"] for i in tr} & {rows[i]["sha256"] for i in te}
    closest = int(dist[np.ix_(tr, te)].min())
    assert closest > args.near, closest

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(kept[0]))
        w.writeheader()
        w.writerows(kept)

    dropped = sum(r["set"] == TRAIN_SET and r["split"] == "test" for r in rows)
    tc, sc = Counter(k["cir"] for k in train), Counter(k["cir"] for k in test)
    relabelled = [k for k in test if k["cir_2025"] != "" and k["cir_2025"] != k["cir"]]
    multi = Counter(k["group_size"] for k in test if k["group_size"] > 2)
    print(f"Wrote {args.out}")
    print(f"HINDER-2025 images dropped from training (copies of test photos): {dropped}")
    print(f"train: {len(train)} images, {len({k['group_id'] for k in train})} groups")
    print(f"test:  {len(test)} images, {len({k['group_id'] for k in test})} groups")
    print("CIR    " + " ".join(f"{lv:>4}" for lv in LEVELS))
    print("train  " + " ".join(f"{tc[lv]:>4}" for lv in LEVELS))
    print("test   " + " ".join(f"{sc[lv]:>4}" for lv in LEVELS))
    print(f"closest train-test pHash distance: {closest} bits (threshold {args.near})")
    print(f"test images whose photo has a different CIR in HINDER-2025: {len(relabelled)}")
    print(f"test groups holding more than one HINDER-2018 image: "
          f"{sum(1 for g, n in Counter(k['group_id'] for k in test).items() if n > 1)}")
    if multi:
        print(f"groups with more than 2 images (size: count): {dict(multi)}")


if __name__ == "__main__":
    main()
