"""
MindPath AI - supplementary dataset downloader
===============================================
Downloads every free dataset the project can still use, then INSPECTS each one and
prints its real columns and label values, so you know in one line whether it is useful.

The important find
------------------
solomonk/reddit_mental_health_posts on Hugging Face contains ocd.csv (29.8 MB) taken
from r/OCD, alongside adhd, aspergers, depression and ptsd. This is the only public
corpus found that carries an OCD class. It needs no account and no API key.

Caveat you must record in the report: that dataset card states no licence, and the
raw file contains an `author` column. This script drops `author` on load and writes a
cleaned copy. The Reddit API is not reachable from Pakistan, so this archive is the OCD
source for the thesis; prepare_ocd_corpus.py builds the training corpora from it.

Setup
-----
    pip install pandas huggingface_hub
    pip install kaggle          # only if you want the Kaggle candidates

Usage
-----
    python download_extras.py                 # everything that needs no credentials
    python download_extras.py --with-kaggle   # also the Kaggle candidates
    python download_extras.py --inspect-only  # re-read what is already on disk
"""

import argparse
import glob
import os
import subprocess
import sys

try:
    import pandas as pd
except ImportError:
    sys.exit("pandas is not installed.  Run:  pip install pandas")

# ---------------------------------------------------------------------------
# Hugging Face - no account, no API key
# ---------------------------------------------------------------------------
HUGGINGFACE = [
    ("solomonk/reddit_mental_health_posts",
     "*** HAS AN OCD CLASS *** ocd.csv (29.8 MB) from r/OCD, plus adhd, aspergers, "
     "depression and ptsd. 151,288 rows in total. Licence unstated on the card; "
     "contains an author column which this script removes."),
    ("ourafla/Mental-Health_Text-Classification_Dataset",
     "48,945 rows, CC BY 4.0. Classes: Suicidal, Depression, Anxiety, Normal. "
     "No OCD class, but good extra control and crisis data."),
]

# ---------------------------------------------------------------------------
# Kaggle - needs a free account token at ~/.kaggle/kaggle.json
# ---------------------------------------------------------------------------
KAGGLE = [
    ("neelghoshal/reddit-mental-health-data", "Multi-condition Reddit posts."),
    ("suchintikasarkar/sentiment-analysis-for-mental-health", "Multi-class statements."),
    ("entenam/reddit-mental-health-dataset", "Reddit mental health posts, 2019-2022."),
    ("nourmekkijj/stress-and-anxiety-posts-on-reddit", "Stress and anxiety posts."),
    ("infamouscoder/depression-reddit-cleaned", "Cleaned depression posts."),
]

# Columns that must never survive into your working copy.
PRIVACY_DROP = ["author", "username", "user", "author_fullname", "name"]

LABEL_HINTS = ["label", "class", "status", "target", "category", "subreddit",
               "condition", "disorder", "sentiment", "is_suicide", "suicidal"]


def human(n):
    for u in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f} {u}"
        n /= 1024
    return f"{n:.1f} TB"


def kaggle_ready():
    kaggle_dir = os.path.join(os.path.expanduser("~"), ".kaggle")
    return bool(
        os.environ.get("KAGGLE_API_TOKEN")
        or os.path.exists(os.path.join(kaggle_dir, "access_token"))
        or os.path.exists(os.path.join(kaggle_dir, "kaggle.json"))
        or (os.environ.get("KAGGLE_USERNAME") and os.environ.get("KAGGLE_KEY")))


def get_hf(repo, out_dir):
    try:
        from huggingface_hub import snapshot_download
    except ImportError:
        print("    huggingface_hub missing.  pip install huggingface_hub")
        return None
    target = os.path.join(out_dir, repo.split("/")[-1])
    if os.path.isdir(target) and glob.glob(os.path.join(target, "**", "*.*"), recursive=True):
        print("    already downloaded, skipping")
        return target
    try:
        print(f"    downloading {repo} ...")
        snapshot_download(repo_id=repo, repo_type="dataset",
                          local_dir=target, local_dir_use_symlinks=False)
        return target
    except Exception as e:
        print(f"    FAILED: {e}")
        return None


def get_kaggle(slug, out_dir):
    target = os.path.join(out_dir, slug.split("/")[-1])
    if os.path.isdir(target) and os.listdir(target):
        print("    already downloaded, skipping")
        return target
    os.makedirs(target, exist_ok=True)
    print(f"    downloading {slug} ...")
    r = subprocess.run(["kaggle", "datasets", "download", "-d", slug,
                        "-p", target, "--unzip"], capture_output=True, text=True)
    if r.returncode != 0:
        tail = (r.stderr or r.stdout or "").strip().splitlines()
        print(f"    FAILED: {tail[-1] if tail else 'unknown error'}")
        return None
    return target


def strip_identifiers(folder):
    """Remove author columns and write *_clean.csv next to each source file."""
    made = []
    for path in glob.glob(os.path.join(folder, "**", "*.csv"), recursive=True):
        if path.endswith("_clean.csv"):
            continue
        try:
            df = pd.read_csv(path, low_memory=False, on_bad_lines="skip")
        except Exception:
            continue
        drop = [c for c in df.columns if str(c).strip().lower() in PRIVACY_DROP]
        if not drop:
            continue
        out = path[:-4] + "_clean.csv"
        df.drop(columns=drop).to_csv(out, index=False)
        made.append((os.path.basename(out), drop, len(df)))
    for name, dropped, rows in made:
        print(f"      privacy: wrote {name} ({rows} rows, removed {', '.join(dropped)})")
    return made


def inspect(folder, name):
    print(f"\n  INSPECTING: {name}")
    files = glob.glob(os.path.join(folder, "**", "*.csv"), recursive=True)
    files += glob.glob(os.path.join(folder, "**", "*.tsv"), recursive=True)
    files = [f for f in files if not f.endswith("_clean.csv")]
    if not files:
        other = glob.glob(os.path.join(folder, "**", "*.*"), recursive=True)[:8]
        print("    no CSV found. Files present:")
        for o in other:
            print(f"      {os.path.relpath(o, folder)}  {human(os.path.getsize(o))}")
        return False

    has_ocd = False
    for path in sorted(files)[:8]:
        rel = os.path.relpath(path, folder)
        try:
            sep = "\t" if path.endswith(".tsv") else ","
            head = pd.read_csv(path, sep=sep, nrows=4000,
                               on_bad_lines="skip", low_memory=False)
        except Exception as e:
            print(f"    {rel}: could not read ({e})")
            continue
        try:
            rows = sum(1 for _ in open(path, encoding="utf-8", errors="ignore")) - 1
        except Exception:
            rows = "?"

        print(f"    {rel}  ~{rows} rows  {human(os.path.getsize(path))}")
        print(f"      columns: {', '.join(map(str, head.columns[:14]))}")

        risky = [c for c in head.columns if str(c).strip().lower() in PRIVACY_DROP]
        if risky:
            print(f"      WARNING: identifier column(s) present: {', '.join(risky)}")

        if "ocd" in rel.lower():
            has_ocd = True
            print("      *** THIS FILE IS THE OCD CLASS ***")

        for col in head.columns:
            if any(h in str(col).lower() for h in LABEL_HINTS):
                vals = head[col].dropna().astype(str).unique()
                if 1 < len(vals) <= 40:
                    print(f"      {col} -> {', '.join(sorted(vals)[:18])}")
                    if any("ocd" in v.lower() or "obsess" in v.lower() for v in vals):
                        has_ocd = True
                        print("      *** CONTAINS AN OCD CLASS ***")
    return has_ocd


def write_sources(out_dir, results):
    path = os.path.join(out_dir, "SOURCES_EXTRAS.md")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("# Supplementary dataset sources\n\n")
        fh.write("## Hugging Face\n\n")
        fh.write("- **solomonk/reddit_mental_health_posts** - "
                 "https://huggingface.co/datasets/solomonk/reddit_mental_health_posts  \n")
        fh.write("  Contains `ocd.csv` from r/OCD. 151,288 rows across five subreddits. "
                 "**Licence is not stated on the dataset card**, and the raw files contain "
                 "an `author` column, which is removed here. Record both facts as "
                 "limitations. This is the OCD source for the thesis, since the Reddit API "
                 "is not reachable from Pakistan; see docs/DATA.md.\n\n")
        fh.write("- **ourafla/Mental-Health_Text-Classification_Dataset** - "
                 "https://huggingface.co/datasets/ourafla/Mental-Health_Text-Classification_Dataset  \n")
        fh.write("  48,945 rows, CC BY 4.0, four classes.\n\n")
        fh.write("## Needs a browser (free, no payment)\n\n")
        fh.write("- **Suicidal Ideation Detection Reddit Dataset** (Mendeley Data, CC BY 4.0) - "
                 "https://data.mendeley.com/datasets/z8s6w86tr3/2  \n")
        fh.write("  15,477 posts. SuicideWatch versus CasualConversation, BenignExistence and "
                 "CongratsLikeImFive. Use as an independent test set for the crisis "
                 "classifier.\n\n")
        fh.write("- **Roboflow 'Hoarding Support' workspace** - "
                 "https://universe.roboflow.com/hoarding-support  \n")
        fh.write("  clean-vs-messy-room, clutter-dataset-labeled and clutter-classes. Free "
                 "account gives an API key and the site generates the exact download snippet. "
                 "Binary and object-level labels only; no Clutter Image Rating, so these "
                 "supplement HINDER rather than replace it.\n\n")
        fh.write("## Downloaded in this run\n\n")
        for k, v in results.items():
            fh.write(f"- {k}: {'ok' if v else 'failed'}\n")
    print(f"\nWrote {path}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join("ml", "data", "extras"))
    ap.add_argument("--with-kaggle", action="store_true")
    ap.add_argument("--inspect-only", action="store_true")
    args = ap.parse_args()

    out_dir = os.path.abspath(args.out)
    os.makedirs(out_dir, exist_ok=True)
    print(f"Target folder: {out_dir}\n")

    results, found_ocd = {}, []

    print("=" * 62)
    print("HUGGING FACE  (no account needed)")
    print("=" * 62)
    for repo, note in HUGGINGFACE:
        print(f"\n  {repo}\n    {note}")
        folder = (os.path.join(out_dir, repo.split('/')[-1])
                  if args.inspect_only else get_hf(repo, out_dir))
        ok = bool(folder and os.path.isdir(folder))
        results[repo] = ok
        if ok:
            if inspect(folder, repo):
                found_ocd.append(repo)
            strip_identifiers(folder)

    if args.with_kaggle:
        print("\n" + "=" * 62)
        print("KAGGLE  (needs ~/.kaggle/kaggle.json)")
        print("=" * 62)
        if not kaggle_ready() and not args.inspect_only:
            print("\n  Credentials not found. Get them at "
                  "https://www.kaggle.com/settings -> API -> Create New Token,")
            print("  then save kaggle.json to ~/.kaggle/kaggle.json and run this again.")
        else:
            for slug, note in KAGGLE:
                print(f"\n  {slug}\n    {note}")
                folder = (os.path.join(out_dir, slug.split('/')[-1])
                          if args.inspect_only else get_kaggle(slug, out_dir))
                ok = bool(folder and os.path.isdir(folder))
                results[slug] = ok
                if ok:
                    if inspect(folder, slug):
                        found_ocd.append(slug)
                    strip_identifiers(folder)

    print("\n" + "=" * 62)
    print("SUMMARY")
    print("=" * 62)
    if found_ocd:
        print("Datasets carrying an OCD class:")
        for f in found_ocd:
            print(f"  - {f}")
    else:
        print("No OCD class found in this run.")

    print("\nStill to fetch in a browser (both free):")
    print("  1. https://data.mendeley.com/datasets/z8s6w86tr3/2")
    print("     Suicidal Ideation Reddit Dataset, 15,477 posts, CC BY 4.0.")
    print("     Press Download All. Save to ml/data/extras/mendeley_suicide/")
    print("  2. https://universe.roboflow.com/hoarding-support")
    print("     clean-vs-messy-room and the clutter detection sets.")
    print("     Create a free account, then the site prints the exact download snippet.")

    write_sources(out_dir, results)


if __name__ == "__main__":
    main()
