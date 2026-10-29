# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Adults (18+) in Pakistan who suspect they may have OCD or Hoarding Disorder and want to check privately, before seeing a clinician or instead of seeing one. They usually open the app alone, often uncertain and anxious about what the result will say. Their job is to answer a short screening honestly, understand what the result means, and find a manageable next step.

Secondary audience, for now: the SZABIST FYP evaluation panel and supervisor (Mr. Syed Muhammad Muslim Rizvi), who judge the mid and final demos. The app is built to pass that review, but it is meant to be released to real users afterwards, so it must hold up outside a demo: no demo-only shortcuts in the user-facing experience.

## Product Purpose

MindPath AI offers preliminary screening and self-support for two conditions: OCD and Hoarding Disorder. It scores validated instruments (OCI-R for OCD, SI-R for hoarding) and adds an AI-assisted screening layer on top: a hoarding image model that rates room clutter, and an OCD text model. Results come with plain-language explanations, then lead into self-guided therapy programs, progress tracking, and history.

It is never a diagnosis. Every result is labelled "preliminary screening, not a medical diagnosis."

Success means a user finishes a screening, understands their result and its limits, and takes one concrete next step: a therapy exercise, safety resources, or seeing a professional.

## Positioning

It combines established clinical scoring instruments with AI models trained on clinically relevant data (professionally rated clutter images from HINDER-2018/2025, community-labelled OCD text), and explains why the model said what it did. The validated score always comes first. AI is an extra layer, never a replacement, and the rule-based score still works offline.

## Operating Context

- Used privately on the person's own Android phone, often alone and in a vulnerable moment.
- Flow: welcome, register (with explicit consent), dashboard, choose a condition, assessment, report, then therapy programs, progress, history, and the chatbot.
- Hoarding screening can include photos of the user's rooms, which are uploaded for the clutter-rating model.
- Assessments include interactive tasks, such as a 12-item "Keep or let go" decision task with a 0–4 "How hard was that decision?" rating, as well as questionnaires.
- Demos run on an Android phone in front of the FYP panel.

## Capabilities and Constraints

- **Stack:** Flutter (Dart) app, plus a FastAPI (Python) backend for PyTorch, scikit-learn, and SHAP inference. Firebase handles Authentication, Firestore, and Storage.
- **Offline fallback:** rule-based OCI-R and SI-R scoring runs on-device in Dart. AI models run on the backend as an additional layer.
- **Scope:** exactly two conditions, OCD and Hoarding Disorder. BDD is excluded and must not appear anywhere.
- **Terminology:** always "preliminary screening". Never "diagnosis", "diagnose", or "you have X" in UI copy or code comments.
- **Language:** English only. OCI-R and SI-R are used in their validated English versions.
- **Data:** stored in Firebase under the user's account after explicit consent at registration ("I understand this app provides preliminary screening, not a medical diagnosis"). Room photos are uploaded to the backend for the AI model.
- **Risk handling:** when answers suggest high distress or risk, show a calm prompt that links to the Safety screen (contact local emergency services or someone you trust).
- **Open:** verified Pakistani helplines are not confirmed yet and must not be invented. Safety planning tools are not built yet.
- **Open:** the OCD text model depends on SMHD access (requested). The Reddit-derived corpus (`docs/DATA.md`) is labelled by subreddit membership, not by clinical annotation, and results must be described that way.
- **Roadmap:** 12 modules from P1 Mid to P2 Final (see CLAUDE.md). Auth and the dashboard are in progress. Therapy, progress tracking, the chatbot, and the explainable report come later.

## Brand Commitments

- Name: **MindPath AI**. Tagline in use: "Preliminary screening and self-support."
- Voice in use: quiet, plain, non-judgemental, e.g. "A quiet first step for obsessive thoughts and difficulty letting go.", "There is no right answer.", "You are not alone."
- Never alarmist, never clinical-sounding about the user, and never diagnostic.

## Evidence on Hand

- Datasets: HINDER-2025 and HINDER-2018 (clutter image rating 1–9, professionally labelled, already downloaded). OCD text corpora documented in `docs/DATA.md` (Hugging Face Reddit archive plus Zenodo record 3941387, with known source-confound limitations).
- Validated instruments: OCI-R and SI-R.
- Screen mockups: `docs/mindpath-screens.html`.
- Absent, and must not be fabricated: user testimonials, clinical validation of the app itself, model accuracy figures beyond what the team has measured, clinician endorsements, and helpline numbers.

## Product Principles

1. **Screening, never diagnosis.** Every result, label, and comment says what it is and what it is not.
2. **Validated score first, AI second.** The instrument score is the anchor. AI adds an explained second opinion and never overrides it silently.
3. **Calm over alarm.** The user may be anxious or ashamed. Copy and flow lower the stakes and always offer a next step.
4. **Honest about limits.** Show uncertainty, data limitations, and offline or fallback states plainly rather than hiding them.
5. **Private by consent.** Nothing is stored or uploaded without the user knowing, especially photos of their home.

## Accessibility & Inclusion

Users may be distressed while using the app, so it needs low cognitive load, clear progress through assessments, and no time pressure in screening tasks. No formal accessibility standard (such as a WCAG level) has been chosen yet.
