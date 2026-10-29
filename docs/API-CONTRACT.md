# MindPath AI - Inference API contract (draft)

> **Status: planned, not implemented.** `backend/` is empty and the app does not call any
> of these endpoints yet. Paths and field names here are **proposals** to agree on before
> Modules 7 to 9. The facts they carry (models, label sets, instruments, report contents)
> come from the sources cited in each section. Anything not decided yet is listed under
> [Open decisions](#open-decisions) and is not filled in.

The API connects the Flutter app to the FastAPI inference service (see `ARCHITECTURE.md`).
It returns preliminary screening output only. It never returns a diagnosis.

## Conventions

| Item | Proposal | Basis |
|---|---|---|
| Base path | `/v1` | Lets the app keep working while the API changes |
| Format | JSON, except image uploads (`multipart/form-data`) | Room photos are uploaded to the backend (`PRODUCT.md`) |
| Field names | `snake_case` | Python and FastAPI convention |
| Errors | FastAPI default: `{"detail": "..."}`; `422` for invalid input | FastAPI behaviour |
| Disclaimer | Every result body has `"disclaimer": "Preliminary screening, not a medical diagnosis."` | Hard rule in `CLAUDE.md` and `PRODUCT.md` |
| Model version | Every model output names the model and its version | So a report can say which model produced it |
| Auth | **Open**, see below | Not decided |

### Shared values

| Name | Values | Source |
|---|---|---|
| `condition` | `"hoarding"`, `"ocd"` | `kDisorders` ids in `lib/models/disorders.dart` |
| `instrument` | `"SI-R"` for hoarding, `"OCI-R"` for OCD | `CLAUDE.md`, `PRODUCT.md` |
| `level` | `"low"`, `"medium"`, `"high"` | Report design (`docs/mindpath-screens.html`, `report_screen.dart`) |

## Endpoints

| Method | Path | Purpose | Module |
|---|---|---|---|
| `GET` | `/v1/health` | Is the service up, and which models are loaded | 9 |
| `POST` | `/v1/inference/hoarding-image` | One room photo to a clutter rating | 5, 7 |
| `POST` | `/v1/inference/ocd-text` | One piece of text to a class | 6, 8 |
| `POST` | `/v1/screenings` | Run the AI layer for one assessment, with explanations | 9 |
| `POST` | `/v1/reports` | Build the report content from a screening | 9 |

The two `inference` endpoints are single model calls (useful for testing and evaluation).
`screenings` is what the app calls after an assessment. `reports` turns its output into what
the Report screen shows.

---

### `GET /v1/health`

Lets the app decide whether to show the AI layer or the offline, instrument-only result
(offline fallback, `PRODUCT.md`).

**Response `200`**

```json
{
  "status": "ok",
  "models": {
    "hoarding_image": { "name": "hoarding-cir", "version": "0.1.0", "loaded": true },
    "ocd_text": { "name": "ocd-text", "version": "0.1.0", "loaded": false }
  }
}
```

---

### `POST /v1/inference/hoarding-image`

Rates one room photo on the HINDER Clutter Image Rating (CIR) scale, 1 (least clutter) to
9 (most), the label scale of HINDER-2018 and HINDER-2025.

**Request** - `multipart/form-data`

| Field | Type | Required | Notes |
|---|---|---|---|
| `image` | file, JPEG or PNG | yes | One photo of one room |
| `explain` | bool | no, default `false` | Include an explanation |

**Response `200`**

```json
{
  "model": { "name": "hoarding-cir", "version": "0.1.0" },
  "cir_rating": 6,
  "probabilities": {
    "1": 0.01, "2": 0.02, "3": 0.04, "4": 0.08, "5": 0.17,
    "6": 0.38, "7": 0.20, "8": 0.07, "9": 0.03
  },
  "explanation": null,
  "disclaimer": "Preliminary screening, not a medical diagnosis."
}
```

| Field | Type | Notes |
|---|---|---|
| `cir_rating` | int, 1 to 9 | Predicted CIR level |
| `probabilities` | map of `"1"`..`"9"` to float | Present if the model is a 9-class classifier, which matches the HINDER folder layout (`CIR 1` to `CIR 9`). If a regression model is chosen instead, this becomes `null`. |
| `explanation` | object or `null` | Shape **open**: the image explanation method is not chosen yet (SHAP is the only one named in the plan). |

---

### `POST /v1/inference/ocd-text`

Classifies one piece of text against the classes of the OCD corpora in `docs/DATA.md`.

**Request** - JSON

```json
{
  "text": "I keep going back to check the stove even after I have checked it.",
  "explain": true
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `text` | string | yes | English only (`PRODUCT.md`) |
| `explain` | bool | no, default `false` | Include token attributions |

**Response `200`**

```json
{
  "model": { "name": "ocd-text", "version": "0.1.0" },
  "label": "ocd",
  "probabilities": { "ocd": 0.81, "other_condition": 0.19 },
  "explanation": {
    "method": "shap",
    "tokens": [
      { "token": "check", "weight": 0.34 },
      { "token": "stove", "weight": 0.05 }
    ]
  },
  "disclaimer": "Preliminary screening, not a medical diagnosis."
}
```

| Field | Type | Notes |
|---|---|---|
| `label` | `"ocd"`, `"other_condition"`, or `"control"` | `control` exists only if the 3-class model is used (`ocd_corpus_3class.csv`). |
| `probabilities` | map of label to float | One entry per class the model was trained on |
| `explanation.tokens` | list of `{token, weight}` | SHAP attribution per token. Positive weight pushes toward `label`. |

**Meaning of the label.** The training labels come from subreddit membership, not clinical
assessment (`docs/DATA.md`, *Labelling method*). `"ocd"` means "this text resembles posts in
r/OCD". The app must never show it to the user as "you have OCD".

---

### `POST /v1/screenings`

Runs the AI layer for one completed assessment and returns it next to the instrument score.
The **instrument score is computed on the phone** by the Dart scoring engine (`CLAUDE.md`:
rule-based scoring runs on-device) and sent here as-is. The server does not change it.

**Request** - `multipart/form-data`

| Part | Type | Required | Notes |
|---|---|---|---|
| `payload` | JSON (below) | yes | |
| `images` | one or more files | for `hoarding` only | Room photos. Maximum count **open**. |

`payload`:

```json
{
  "condition": "ocd",
  "completed_at": "2026-10-27T12:00:00Z",
  "instrument": {
    "id": "OCI-R",
    "responses": [2, 3, 1, 0, 4, 2, 1, 3, 2, 0, 1, 2, 3, 1, 0, 2, 1, 3],
    "device_score": {
      "total": 31,
      "subscales": {
        "washing": 3, "checking": 9, "ordering": 5,
        "obsessing": 8, "hoarding": 2, "neutralizing": 4
      }
    }
  },
  "sorting_task": null,
  "texts": ["I keep going back to check the stove even after I have checked it."]
}
```

| Field | Type | Notes |
|---|---|---|
| `condition` | `"hoarding"` or `"ocd"` | |
| `instrument.id` | `"OCI-R"` or `"SI-R"` | |
| `instrument.responses` | list of int | OCI-R: 18 items, each 0 to 4. SI-R: 23 items, each 0 to 8. In item order of the published English version. |
| `instrument.device_score.total` | int | OCI-R 0 to 72. SI-R 0 to 92. |
| `instrument.device_score.subscales` | map | OCI-R: `washing`, `checking`, `ordering`, `obsessing`, `hoarding`, `neutralizing`. SI-R: `clutter`, `difficulty_discarding`, `acquisition`. |
| `sorting_task` | list or `null` | The "Keep or let go" task: `[{ "item": 1, "choice": "keep" or "let_go", "difficulty": 0..4 }]`, 12 items (design and `PRODUCT.md`). Passed through only; **how it is scored is open**. |
| `texts` | list of string or `null` | OCD only. **No screen collects free text yet**; the source of this text is open. |

**Response `200`**

```json
{
  "condition": "ocd",
  "instrument": {
    "id": "OCI-R",
    "device_score": { "total": 31, "subscales": { "checking": 9, "obsessing": 8 } }
  },
  "ai": {
    "available": true,
    "text_results": [
      {
        "model": { "name": "ocd-text", "version": "0.1.0" },
        "label": "ocd",
        "probabilities": { "ocd": 0.81, "other_condition": 0.19 },
        "explanation": { "method": "shap", "tokens": [{ "token": "check", "weight": 0.34 }] }
      }
    ],
    "image_results": null
  },
  "disclaimer": "Preliminary screening, not a medical diagnosis."
}
```

(Subscales are shortened in this example.)

- `ai.text_results` items have the same shape as `/v1/inference/ocd-text`, always with an
  explanation.
- `ai.image_results` items have the same shape as `/v1/inference/hoarding-image`, one per
  uploaded photo.
- If a model is not loaded, `ai.available` is `false` and the app shows the instrument score
  alone. The validated score always comes first (`PRODUCT.md`, principle 2).

---

### `POST /v1/reports`

Turns a screening response into the content of the Report screen ("Your fingerprint").

**Request** - JSON: the full response body of `POST /v1/screenings`.

**Response `200`**

```json
{
  "title": "Your fingerprint",
  "generated_at": "2026-10-27T12:00:05Z",
  "headline": "Checking and doubt stand out most.",
  "dimensions": [
    { "name": "Doubt & checking", "level": "high", "value": 0.252, "source": "instrument" },
    { "name": "Intrusive thoughts", "level": "high", "value": 0.215, "source": "instrument" }
  ],
  "ai_summary": {
    "text": "<plain-language summary of the AI layer; wording not written yet>",
    "models": [{ "name": "ocd-text", "version": "0.1.0" }]
  },
  "suggested_next": {
    "title": "Suggested next: checking ladder",
    "caption": "Start with the easiest step. 10 minutes."
  },
  "disclaimer": "AI-assisted preliminary screening, based on your answers and the OCI-R scoring bands. This is not a medical diagnosis."
}
```

The fields follow the Report screen and its design: title, headline, a list of dimensions
each with a name, a High/Medium/Low level and a ring value, one suggested next step, and the
disclaimer. Values above are the design's sample data.

| Field | Notes |
|---|---|
| `dimensions[].name` | The design shows six: Doubt & checking, Intrusive thoughts, Difficulty discarding, Order & symmetry, Clutter at home, Overall distress. **How these map to OCI-R and SI-R subscales and AI outputs is open.** |
| `dimensions[].level` | Thresholds for low, medium and high are **open**. They should come from the published OCI-R and SI-R scoring bands. |
| `dimensions[].value` | 0 to 1, drawn as a ring |
| `dimensions[].source` | `"instrument"` or `"ai"`, so the screen can show which layer each line came from |
| `ai_summary` | `null` when `ai.available` is `false` |
| `suggested_next` | Will point to a therapy program once Module 10 exists. Not linked to anything yet. |

## Open decisions

These must be settled before the service is built. They are left out of the shapes above on
purpose.

| Decision | Notes |
|---|---|
| How the app authenticates to the service | The app already uses Firebase Auth, so sending the Firebase ID token (`Authorization: Bearer <token>`) and checking it with the Firebase Admin SDK would fit. Not decided. |
| Photo transport | Straight to the backend (as above) or via Firebase Storage first. Storage is in the planned stack but not a dependency yet. |
| Photo and text retention | Whether the backend keeps uploads after responding. `PRODUCT.md` requires that nothing is stored without the user knowing. |
| Source of OCD text input | No screen asks for free text yet. |
| Scoring of the "Keep or let go" task | Not defined |
| Dimension mapping and level thresholds | See `/v1/reports` |
| Image explanation method and shape | SHAP is named in the stack; output format for images not chosen |
| 2-class or 3-class OCD model in production | Both corpora exist (`docs/DATA.md`) |
| Whether reports are built on the server or on the phone | Module 9 groups the report with the inference service. Building it on the phone would also work offline. |
| Report export (Share button) | Placeholder on the Report screen; format not chosen |
| Where results are stored | No Firestore schema for screenings or reports yet (`DATABASE-SCHEMA.md`) |
| Hosting | Not chosen |
