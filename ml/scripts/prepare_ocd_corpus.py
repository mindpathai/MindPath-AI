"""
MindPath AI - OCD corpus builder
================================
Builds the three-class text corpus for the OCD linguistic module from data that is
already on disk (the Reddit API is not reachable from Pakistan, so nothing is fetched).

    ocd              r/OCD                     ml/data/extras/reddit_mental_health_posts/ocd_clean.csv
    other_condition  r/ADHD, r/aspergers,      ml/data/extras/reddit_mental_health_posts/*_clean.csv
                     r/depression, r/ptsd
    control          r/fitness,                ml/data/reddit_mental_health/*_pre_features_tfidf_256.csv
                     r/personalfinance

Cleaning, in order:
  - URLs, u/ mentions and r/ subreddit names are removed
  - self-report phrases ("I was diagnosed with OCD", "my OCD", "my therapist said" ...)
    are removed, then any remaining bare condition name (OCD, ROCD, ADHD, PTSD ...).
    Without this the model learns to spot the phrase and the reported accuracy is false.
  - [removed] / [deleted] posts, posts under 20 words and exact duplicates are dropped
  - no author / username column is ever carried over

Each corpus is then balanced by downsampling to its smallest class.

Outputs (post_id, label, text, word_count, source_subreddit), all in ml/data/:
    ocd_corpus_2class.csv         ocd vs other_condition. PRIMARY corpus for the thesis.
                                  Both classes come from the same Hugging Face archive and
                                  period, so there is no source confound.
    ocd_corpus_2class_sample.csv  8,000 per class drawn from the 2-class corpus, for quick
                                  iteration on Colab before the full run.
    ocd_corpus_3class.csv         adds control (Zenodo, 2018-19) for the app's
                                  "no indication" path. Secondary: control differs from the
                                  other two classes by source corpus as well as by content.

Usage:
    python ml/scripts/prepare_ocd_corpus.py
    python ml/scripts/prepare_ocd_corpus.py --min-words 30 --seed 7 --sample-per-class 4000
"""

import argparse
import math
import os
import re
import sys
from collections import Counter

try:
    import pandas as pd
except ImportError:
    sys.exit("pandas is not installed.  Run:  pip install pandas")

ML_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HF_DIR = os.path.join(ML_DIR, "data", "extras", "reddit_mental_health_posts")
ZENODO_DIR = os.path.join(ML_DIR, "data", "reddit_mental_health")
DEFAULT_OUT_DIR = os.path.join(ML_DIR, "data")
COLUMNS = ["post_id", "label", "text", "word_count", "source_subreddit"]

HF_SOURCES = {
    "ocd_clean.csv":        "ocd",
    "adhd_clean.csv":       "other_condition",
    "aspergers_clean.csv":  "other_condition",
    "depression_clean.csv": "other_condition",
    "ptsd_clean.csv":       "other_condition",
}
ZENODO_SOURCES = {
    "fitness_pre_features_tfidf_256.csv":         "control",
    "personalfinance_pre_features_tfidf_256.csv": "control",
}
LABELS = ["ocd", "other_condition", "control"]

PRIVACY_DROP = {"author", "username", "user", "author_fullname", "name"}
DEAD_POSTS = {"[removed]", "[deleted]", "[removed by reddit]", "removed", "deleted"}

# --- cleaning patterns -------------------------------------------------------
MD_LINK = re.compile(r"\[([^\]]*)\]\((?:https?://|www\.)[^)]*\)", re.I)
URL = re.compile(r"https?://\S+|www\.\S+", re.I)
APOSTROPHES = str.maketrans({"’": "'", "‘": "'", "ʼ": "'", "＇": "'"})
USER_MENTION = re.compile(r"(?<![\w/])/?u/[A-Za-z0-9_-]+", re.I)
SUB_MENTION = re.compile(r"(?<![\w/])/?r/[A-Za-z0-9_]+", re.I)

# Diagnostic labels. \w?ocd also covers the subtype labels ROCD, HOCD, POCD, SOCD ...
COND = (r"(?:\w?ocd|o\.c\.d\.?|obsessive[\s-]*compulsive(?:\s+disorder)?|pure[\s-]?o"
        r"|adhd|add/adhd|attention[\s-]*deficit(?:[\s/-]*hyperactivity)?(?:\s+disorder)?"
        r"|c-?ptsd|post[\s-]*traumatic\s+stress(?:\s+disorder)?"
        r"|asperger'?s?(?:\s+syndrome)?|aspies?|autism(?:\s+spectrum\s+disorder)?|autistic|asd"
        r"|major\s+depressive\s+disorder|mdd|clinical\s+depression|depression|anxiety)")
ADJ = r"(?:(?:severe|mild|moderate|bad|really\s+bad|chronic|diagnosed|undiagnosed|own)\s+)?"
CLINICIAN = r"(?:therapist|psychiatrist|psychologist|counsel+or|doctor|dr\.?|gp|psych|clinician)"

SELF_REPORT = [re.compile(p, re.I) for p in (
    # "I was / I've been / I got (officially) diagnosed with OCD"
    rf"\bi(?:'ve|\s+have|\s+had)?\s*(?:was|been|got|am|'m|just\s+got)?\s*"
    rf"(?:(?:officially|formally|recently|finally|just|also)\s+)?diagnosed\s+(?:with\s+)?{ADJ}{COND}\b",
    # "diagnosed with OCD", "an OCD diagnosis"
    rf"\b(?:recently\s+|officially\s+)?diagnosed\s+(?:with\s+)?{ADJ}{COND}\b",
    rf"\b(?:an?\s+)?{COND}\s+diagnosis\b",
    # "I have / suffer from / struggle with OCD"
    rf"\bi(?:'ve|\s+have|\s+had|\s+suffer\s+from|\s+struggle\s+with|\s+live\s+with|\s+deal\s+with"
    rf"|'m\s+dealing\s+with|\s+am\s+dealing\s+with)\s+(?:had\s+|got\s+)?{ADJ}{COND}\b",
    # "my OCD", "my own ADHD"
    rf"\bmy\s+{ADJ}{COND}\b",
    # "as someone with OCD", "people with OCD", "OCD sufferer", "I'm autistic"
    rf"\b(?:as\s+)?(?:someone|a\s+person|people|those|anyone|others)\s+(?:with|who\s+(?:have|has))\s+{COND}\b",
    rf"\b{COND}\s+(?:sufferers?|patients?|brain)\b",
    rf"\bi(?:'m|\s+am)\s+(?:also\s+)?(?:an?\s+)?{COND}\b",
    # "my therapist said / told me / thinks"
    rf"\bmy\s+(?:new\s+|old\s+|current\s+)?{CLINICIAN}\s+(?:said|says|told\s+me|tells\s+me|thinks"
    rf"|suggested|believes|diagnosed\s+me(?:\s+with)?)\b",
    # Self-reports that leave the condition unnamed: "I was diagnosed as having ...",
    # "I've had the diagnosis for 6 years", "I got diagnosed", "self-diagnosed"
    r"\bi(?:'m|\s+am|\s+was|'ve\s+been|\s+have\s+been|\s+had\s+been|\s+got|\s+just\s+got|\s+recently\s+got)"
    r"\s+(?:(?:officially|formally|recently|finally|just|also|first|only|eventually)\s+)?(?:self[\s-]*)?"
    r"diagnosed(?:\s+(?:with|as(?:\s+having)?))?\b",
    r"\b(?:(?:i\s+)?(?:have|had|got|get|getting|received)\s+)?(?:my|a|an|the)\s+"
    r"(?:(?:official|formal|recent|new|proper|actual)\s+)?diagnosis\b",
    r"\bget(?:ting)?\s+diagnosed\b",
    r"\bself[\s-]*diagnos\w*",
)]
# Anything left after the phrases above: a bare diagnostic label still names the class.
# "depression" is here because r/depression is one of the other_condition sources;
# "depressed" is kept, since it describes a mood rather than naming the class.
BARE_LABEL = re.compile(r"\b(?:\w?ocd|o\.c\.d\.?|obsessive[\s-]*compulsive(?:\s+disorder)?"
                        r"|adhd|c-?ptsd|ptsd|asperger'?s?|aspies?|autism|autistic|autists?"
                        r"|depression)\b", re.I)
WORD = re.compile(r"[A-Za-z][A-Za-z']*")


def clean(text):
    t = text.translate(APOSTROPHES)
    t = MD_LINK.sub(lambda m: m.group(1) or " ", t)
    t = URL.sub(" ", t)
    t = USER_MENTION.sub(" ", t)
    t = SUB_MENTION.sub(" ", t)
    for pat in SELF_REPORT:
        t = pat.sub(" ", t)
    t = BARE_LABEL.sub(" ", t)
    t = re.sub(r"&amp;", "&", t)
    t = re.sub(r"&\w+;|​", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def is_dead(s):
    return pd.isna(s) or str(s).strip().lower() in DEAD_POSTS or not str(s).strip()


def load_hf():
    frames = []
    for fname, label in HF_SOURCES.items():
        path = os.path.join(HF_DIR, fname)
        if not os.path.exists(path):
            sys.exit(f"Missing {path}\nRun download_extras.py first.")
        df = pd.read_csv(path, low_memory=False)
        df = df.drop(columns=[c for c in df.columns if str(c).lower() in PRIVACY_DROP])
        n = len(df)
        df = df[~df["body"].map(is_dead) & ~df["title"].map(is_dead)]
        print(f"  {fname:<28} {n:>7} rows, {n - len(df):>6} removed/deleted/empty dropped")
        frames.append(pd.DataFrame({
            "post_id": "hf_" + df["id"].astype(str),
            "label": label,
            "raw": df["title"].astype(str) + "\n" + df["body"].astype(str),
            "source_subreddit": df["subreddit"].astype(str),
        }))
    return frames


def load_zenodo():
    frames = []
    for fname, label in ZENODO_SOURCES.items():
        path = os.path.join(ZENODO_DIR, fname)
        if not os.path.exists(path):
            sys.exit(f"Missing {path}\nRun download_datasets.py first.")
        # The feature files already hold title + body joined in `post`; read only what
        # is needed so the author column never enters memory.
        df = pd.read_csv(path, usecols=["subreddit", "post"], low_memory=False)
        n = len(df)
        df = df[~df["post"].map(is_dead)].reset_index()
        print(f"  {fname:<28} {n:>7} rows, {n - len(df):>6} removed/deleted/empty dropped")
        sub = df["subreddit"].astype(str)
        frames.append(pd.DataFrame({
            "post_id": "zen_" + sub.str.lower() + "_" + df["index"].astype(str).str.zfill(6),
            "label": label,
            "raw": df["post"].astype(str),
            "source_subreddit": sub,
        }))
    return frames


STOP = set("""
a about above after again against all also am an and any are aren't as at be because been
before being below between both but by can can't cannot could couldn't did didn't do does
doesn't doing don't down during each even ever every few for from further get gets getting
got had hadn't has hasn't have haven't having he he'd he'll he's her here here's hers herself
him himself his how how's i i'd i'll i'm i've if in into is isn't it it's its itself just know
let's like ll me more most much mustn't my myself no nor not now of off on once one only or
other ought our ours ourselves out over own re really same shan't she she'd she'll she's should
shouldn't so some still such than that that's the their theirs them themselves then there
there's these they they'd they'll they're they've thing things this those through to too
under until up us ve very was wasn't way we we'd we'll we're we've were weren't what what's
when when's where where's which while who who's whom why why's will with won't would wouldn't
you you'd you'll you're you've your yours yourself yourselves im ive dont cant didnt doesnt
isnt wasnt wont youre thats theres s t d m re don also want go going
""".split())


def distinctive_words(df, labels, top=15, prior=0.01):
    """Weighted log-odds with an informative Dirichlet prior (Monroe et al., 2008),
    each class against the rest. Returns {label: [(word, z), ...]}."""
    counts = {lab: Counter() for lab in labels}
    for lab, text in zip(df["label"], df["text"]):
        counts[lab].update(w for w in (x.lower().strip("'") for x in WORD.findall(text))
                           if len(w) > 1 and w not in STOP)
    total = Counter()
    for c in counts.values():
        total.update(c)
    vocab = [w for w, n in total.items() if n >= 20]
    a0 = prior * sum(total[w] for w in vocab)
    out = {}
    for lab in labels:
        rest = total - counts[lab]
        n_i, n_j = sum(counts[lab].values()), sum(rest.values())
        scored = []
        for w in vocab:
            a_w = prior * total[w]
            y_i, y_j = counts[lab][w], rest[w]
            delta = (math.log((y_i + a_w) / (n_i + a0 - y_i - a_w))
                     - math.log((y_j + a_w) / (n_j + a0 - y_j - a_w)))
            var = 1.0 / (y_i + a_w) + 1.0 / (y_j + a_w)
            scored.append((delta / math.sqrt(var), w))
        scored.sort(reverse=True)
        out[lab] = [(w, z) for z, w in scored[:top]]
    return out


def balance(df, labels, n, seed):
    """n random rows per label, shuffled."""
    return (pd.concat([g.sample(n=n, random_state=seed)
                       for _, g in df[df["label"].isin(labels)].groupby("label")])
              .sample(frac=1, random_state=seed)
              .reset_index(drop=True))


def describe(df, labels, path):
    print(f"\n{os.path.basename(path)}  ({len(df)} rows)")
    print(f"  {'label':<16} {'rows':>6} {'avg words':>10} {'median':>7}   sources")
    for lab in labels:
        g = df[df["label"] == lab]
        src = ", ".join(f"{k} {v}" for k, v in g["source_subreddit"].value_counts().items())
        print(f"  {lab:<16} {len(g):>6} {g['word_count'].mean():>10.1f} "
              f"{g['word_count'].median():>7.0f}   {src}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", default=DEFAULT_OUT_DIR)
    ap.add_argument("--min-words", type=int, default=20)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--sample-per-class", type=int, default=8000)
    args = ap.parse_args()

    print("Reading sources")
    df = pd.concat(load_hf() + load_zenodo(), ignore_index=True)

    print("\nCleaning (URLs, u/ and r/ mentions, self-report phrases, condition names)")
    df["text"] = df["raw"].map(clean)
    df["word_count"] = df["text"].map(lambda t: len(WORD.findall(t)))
    before = len(df)
    df = df[df["word_count"] >= args.min_words]
    print(f"  dropped {before - len(df)} posts under {args.min_words} words")

    before = len(df)
    df = df.drop_duplicates(subset="text")
    df = df.drop_duplicates(subset="post_id")
    print(f"  dropped {before - len(df)} duplicate posts")

    assert not PRIVACY_DROP & {c.lower() for c in df.columns}, "identifier column survived"

    avail = df["label"].value_counts()
    print("\nAvailable after cleaning")
    for lab in LABELS:
        print(f"  {lab:<16} {int(avail.get(lab, 0)):>7}")

    two = ["ocd", "other_condition"]
    n2 = int(avail[two].min())
    n3 = int(avail[LABELS].min())
    if args.sample_per_class > n2:
        sys.exit(f"--sample-per-class {args.sample_per_class} exceeds the 2-class size {n2}")
    corpus2 = balance(df, two, n2, args.seed)
    sample2 = balance(corpus2, two, args.sample_per_class, args.seed)
    corpus3 = balance(df, LABELS, n3, args.seed)

    os.makedirs(args.out_dir, exist_ok=True)
    outputs = [
        ("ocd_corpus_2class.csv", corpus2, two),
        ("ocd_corpus_2class_sample.csv", sample2, two),
        ("ocd_corpus_3class.csv", corpus3, LABELS),
    ]
    print("\n" + "=" * 62)
    print("SUMMARY")
    print("=" * 62)
    for fname, corpus, labels in outputs:
        path = os.path.join(args.out_dir, fname)
        corpus[COLUMNS].to_csv(path, index=False)
        describe(corpus, labels, path)

    print("\nFifteen most distinctive words per class (weighted log-odds z-score, class vs rest).")
    print("Check by eye: none of these should name the condition or the subreddit.")
    for fname, corpus, labels in (outputs[0], outputs[2]):
        print(f"\n  {fname}")
        for lab, words in distinctive_words(corpus, labels).items():
            print(f"    {lab}")
            print("      " + ", ".join(f"{w} ({z:.0f})" for w, z in words))


if __name__ == "__main__":
    main()
