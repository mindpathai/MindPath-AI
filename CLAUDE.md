# MindPath AI — Project Context

## What this app is
FYP at SZABIST (AI and Robotics degree). An AI-assisted preliminary screening and
self-support app for two disorders: OCD and Hoarding Disorder. NOT a diagnosis tool —
it never claims to diagnose. It gives validated-instrument scoring plus AI-assisted
screening, always labelled "preliminary screening, not a medical diagnosis."

## Team
- Samama Zubair (23108141) — owns the Hoarding AI model end to end
- Waasay Tariq (23108147) — owns the OCD AI model end to end
- Abdul Momin Abbasi (23108102) — owns dataset foundation + explainability
Supervisor: Mr. Syed Muhammad Muslim Rizvi

## The 12 modules (P1 Mid -> P2 Final, hardest ML work front-loaded to P2 Mid)
P1 Mid: 1) App framework, navigation, design system  2) Auth, registration, privacy
consent  3) Dataset acquisition, curation, exploratory analysis
P1 Final: 4) Dashboard, assessment engine, standardised instruments (OCI-R, SI-R)
5) Hoarding image preprocessing + baseline CNN  6) OCD text preprocessing + baseline
classifier
P2 Mid: 7) Hoarding deep model (ViT) + cross-dataset eval  8) OCD transformer model +
multi-class eval  9) Explainable AI, inference service, assessment report
P2 Final: 10) Therapy programs  11) Progress tracking, history, chatbot  12) Integration,
deployment, testing

## Datasets
- Hoarding: HINDER-2025 + HINDER-2018 (Clutter Image Rating 1-9, professional-labelled,
  already downloaded) — primary, defensible result
- OCD: SMHD (access requested) is primary; Reddit Mental Health Dataset (Zenodo,
  no OCD subreddit — used as "other conditions" class) as secondary

## Architecture
- Flutter (Dart) mobile app, FastAPI (Python) backend for anything needing PyTorch/
  scikit-learn/SHAP (Flutter cannot run .pkl files)
- Firebase: Authentication + Firestore + Storage
- Rule-based scoring engine runs on-device in Dart (offline fallback), AI models run
  on the backend as an additional layer
- Current status: Module 1 (framework, theme, routing) done. Building Module 2 (auth
  forms) and dashboard tonight for the 30% mid demo.

## Hard rules
- Never claim diagnosis anywhere in UI copy or code comments — always "preliminary
  screening"
- No BDD anywhere in code (excluded from scope)
- No git commands unless explicitly asked
