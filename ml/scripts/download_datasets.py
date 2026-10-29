"""
MindPath AI - dataset downloader
=================================
Downloads every openly available dataset the project needs, into ml/data/.

What this script CAN download automatically:
  - Reddit Mental Health Dataset (Zenodo record 3941387) - 11 selected files

What it CANNOT download (and why):
  - HINDER-2025 / HINDER-2018 ... behind a request form, already downloaded manually

The r/OCD class is not in this record. It comes from the Hugging Face archive fetched by
download_extras.py, and prepare_ocd_corpus.py builds the training corpora from both.

Usage:
    python download_datasets.py
    python download_datasets.py --out D:/Flutter Projects/mindpath_ai/ml/data

Safe to re-run: completed files are skipped, interrupted files resume.
"""

import argparse
import hashlib
import json
import os
import sys
import time
import urllib.error
import urllib.request

ZENODO_RECORD = "3941387"
ZENODO_API = f"https://zenodo.org/api/records/{ZENODO_RECORD}"
UA = {"User-Agent": "MindPathAI-FYP/1.0 (academic use)"}

# The 11 files we actually need. Everything else in the record is ignored.
WANTED = {
    # --- Module 5: OCD Linguistic - "other condition" class -----------------
    "anxiety_pre_features_tfidf_256.csv":        "other_condition",
    "depression_pre_features_tfidf_256.csv":     "other_condition",
    "ptsd_pre_features_tfidf_256.csv":           "other_condition",
    "bipolarreddit_pre_features_tfidf_256.csv":  "other_condition",
    "adhd_pre_features_tfidf_256.csv":           "other_condition",
    "autism_pre_features_tfidf_256.csv":         "other_condition",
    "socialanxiety_pre_features_tfidf_256.csv":  "other_condition",
    "EDAnonymous_pre_features_tfidf_256.csv":    "other_condition",
    # --- Modules 5 and 9: control / non-crisis class ------------------------
    "fitness_pre_features_tfidf_256.csv":        "control",
    "personalfinance_pre_features_tfidf_256.csv": "control",
    # --- Module 9: crisis class ---------------------------------------------
    "suicidewatch_pre_features_tfidf_256.csv":   "crisis",
}

# Smallest first, so a broken connection shows up in seconds rather than minutes.
ORDER = [
    "bipolarreddit_pre_features_tfidf_256.csv",
    "autism_pre_features_tfidf_256.csv",
    "ptsd_pre_features_tfidf_256.csv",
    "EDAnonymous_pre_features_tfidf_256.csv",
    "socialanxiety_pre_features_tfidf_256.csv",
    "adhd_pre_features_tfidf_256.csv",
    "fitness_pre_features_tfidf_256.csv",
    "suicidewatch_pre_features_tfidf_256.csv",
    "anxiety_pre_features_tfidf_256.csv",
    "depression_pre_features_tfidf_256.csv",
    "personalfinance_pre_features_tfidf_256.csv",
]


def human(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} TB"


def md5_of(path, chunk=1 << 20):
    h = hashlib.md5()
    with open(path, "rb") as fh:
        while True:
            b = fh.read(chunk)
            if not b:
                break
            h.update(b)
    return h.hexdigest()


def fetch_manifest():
    """Ask Zenodo for the record so we never have to guess a download URL."""
    print(f"Reading the Zenodo record {ZENODO_RECORD} ...")
    req = urllib.request.Request(ZENODO_API, headers=UA)
    with urllib.request.urlopen(req, timeout=60) as r:
        data = json.load(r)

    manifest = {}
    for entry in data.get("files", []):
        name = entry.get("key") or entry.get("filename")
        if name not in WANTED:
            continue
        url = (entry.get("links", {}).get("self")
               or entry.get("links", {}).get("download")
               or entry.get("links", {}).get("content"))
        checksum = (entry.get("checksum") or "").replace("md5:", "")
        manifest[name] = {
            "url": url,
            "size": entry.get("size") or entry.get("filesize") or 0,
            "md5": checksum,
        }
    return manifest


def download(name, info, out_dir, attempt=1, max_attempts=4):
    dest = os.path.join(out_dir, name)
    part = dest + ".part"
    total = info["size"]

    if os.path.exists(dest):
        if not info["md5"] or md5_of(dest) == info["md5"]:
            print(f"  [skip]  {name}  (already complete)")
            return True
        print(f"  [warn]  {name} failed its checksum, downloading again")
        os.remove(dest)

    have = os.path.getsize(part) if os.path.exists(part) else 0
    if have and total and have >= total:
        have = 0
        os.remove(part)

    headers = dict(UA)
    if have:
        headers["Range"] = f"bytes={have}-"
        print(f"  [resume] {name} from {human(have)}")
    else:
        print(f"  [get]   {name}  ({human(total) if total else 'size unknown'})")

    try:
        req = urllib.request.Request(info["url"], headers=headers)
        with urllib.request.urlopen(req, timeout=120) as resp, \
                open(part, "ab" if have else "wb") as fh:
            got = have
            last = time.time()
            while True:
                chunk = resp.read(1 << 18)
                if not chunk:
                    break
                fh.write(chunk)
                got += len(chunk)
                if total and time.time() - last > 1.0:
                    pct = got * 100 / total
                    bar = "#" * int(pct / 4)
                    sys.stdout.write(f"\r          [{bar:<25}] {pct:5.1f}%  {human(got)}")
                    sys.stdout.flush()
                    last = time.time()
        if total:
            sys.stdout.write("\r" + " " * 70 + "\r")

    except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
        print(f"\n  [fail]  {name}: {e}")
        if attempt < max_attempts:
            wait = 5 * attempt
            print(f"          retrying in {wait}s (attempt {attempt + 1}/{max_attempts})")
            time.sleep(wait)
            return download(name, info, out_dir, attempt + 1, max_attempts)
        print(f"          giving up on {name}. Re-run the script to resume it.")
        return False

    if info["md5"]:
        actual = md5_of(part)
        if actual != info["md5"]:
            print(f"  [fail]  {name}: checksum mismatch, file is corrupt. Deleting.")
            os.remove(part)
            return False

    os.replace(part, dest)
    print(f"  [done]  {name}")
    return True


def write_readme(out_dir, results):
    path = os.path.join(out_dir, "SOURCES.md")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("# Dataset sources\n\n")
        fh.write("## Reddit Mental Health Dataset\n\n")
        fh.write(f"Source: https://zenodo.org/records/{ZENODO_RECORD}\n\n")
        fh.write("Licence: ODC Public Domain Dedication and Licence 1.0. "
                 "Re-use is also subject to Reddit API terms.\n\n")
        fh.write("Cite: Low, D. M., Rumker, L., Torous, J., Cecchi, G., Ghosh, S. S., "
                 "& Talkar, T. (2020). Natural Language Processing Reveals Vulnerable "
                 "Mental Health Support Groups and Heightened Health Anxiety on Reddit "
                 "During COVID-19. Journal of Medical Internet Research, 22(10), e22635.\n\n")
        fh.write("| File | Class | Downloaded |\n|---|---|---|\n")
        for name in ORDER:
            fh.write(f"| {name} | {WANTED[name]} | "
                     f"{'yes' if results.get(name) else 'no'} |\n")
        fh.write("\n## Not downloadable by script\n\n")
        fh.write("- **HINDER-2025 / HINDER-2018** - request form at "
                 "https://vip.bu.edu/projects/social/hoarding-2025-dataset ; "
                 "non-commercial use; cite Sun, Muroff & Konrad (EUSIPCO 2025).\n")
        fh.write("- **r/OCD corpus** - not in this record. Taken from the Hugging Face "
                 "archive solomonk/reddit_mental_health_posts (see `download_extras.py`); "
                 "author columns are removed and the raw corpus is not redistributed.\n")
    print(f"\nWrote {path}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join("ml", "data", "reddit_mental_health"),
                    help="where to put the files")
    args = ap.parse_args()

    out_dir = os.path.abspath(args.out)
    os.makedirs(out_dir, exist_ok=True)
    print(f"Target folder: {out_dir}\n")

    try:
        manifest = fetch_manifest()
    except Exception as e:
        print(f"Could not read the Zenodo record: {e}")
        print("Check your internet connection and try again.")
        sys.exit(1)

    missing = [n for n in ORDER if n not in manifest]
    if missing:
        print("These files were not found in the record (the name may have changed):")
        for m in missing:
            print(f"  - {m}")
        print()

    todo = [n for n in ORDER if n in manifest]
    total_bytes = sum(manifest[n]["size"] for n in todo)
    print(f"{len(todo)} files to fetch, about {human(total_bytes)} in total.\n")

    results = {}
    for i, name in enumerate(todo, 1):
        print(f"[{i}/{len(todo)}]")
        results[name] = download(name, manifest[name], out_dir)

    ok = sum(1 for v in results.values() if v)
    print(f"\n{'=' * 52}")
    print(f"Finished: {ok}/{len(todo)} files downloaded.")
    if ok < len(todo):
        print("Run the script again to retry the ones that failed - it resumes.")
    write_readme(out_dir, results)

    print("\nStill to do by hand:")
    print("  - HINDER-2025 and HINDER-2018 (request form, you already have these)")
    print("\nNext: download_extras.py fetches the r/OCD archive, then prepare_ocd_corpus.py")
    print("builds the training corpora.")


if __name__ == "__main__":
    main()
