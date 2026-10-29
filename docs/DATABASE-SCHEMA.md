# MindPath AI - Firestore schema

What the app actually stores in Cloud Firestore today, taken from the code. Anything not
listed here is not stored in Firestore.

Last checked against the code on 2026-10-27.

## Summary

| Collection | Document ID | Written by | Status |
|---|---|---|---|
| `users` | Firebase Auth `uid` | `FirebaseAuthService.signUp` | **In use** |

There is **one** collection. There is no `sessions` collection and no other top-level
collection. Login sessions are handled entirely by Firebase Authentication on the device;
the app writes nothing to Firestore when a user logs in or out.

## `users/{uid}`

One document per account, created once at registration. The document ID is the user's
Firebase Authentication `uid`.

Written in `lib/services/firebase_auth_service.dart:59`, right after
`createUserWithEmailAndPassword` and `updateDisplayName` succeed.

| Field | Type | Example | Source of the value |
|---|---|---|---|
| `name` | string | `"Abdul Momin"` | Register form, trimmed (`normalizeName`). 3 to 50 characters (`validateName`). |
| `email` | string | `"abdul@example.com"` | Register form, trimmed and lowercased (`normalizeEmail`). |
| `createdAt` | timestamp | server time | `FieldValue.serverTimestamp()` |
| `consent` | map | see below | Consent given on the Register screen |

### `consent` map

| Field | Type | Value written | Meaning |
|---|---|---|---|
| `version` | string | `"2026-10-v1"` | `kConsentVersion` (`firebase_auth_service.dart:11`). Identifies which consent wording was shown. |
| `acceptedAt` | timestamp | server time | `FieldValue.serverTimestamp()` |
| `isAdult` | bool | `true` | Register checkbox "I am 18 or older" |
| `understandsScreeningNotDiagnosis` | bool | `true` | Register checkbox "I understand this app provides preliminary screening, not a medical diagnosis" |

Both booleans are always `true`. The Register button stays disabled until both boxes are
ticked, and `signUp` does not receive the checkbox values, so reaching the write means both
were agreed to.

### Example document

```json
{
  "name": "Abdul Momin",
  "email": "abdul@example.com",
  "createdAt": "2026-10-27T12:00:00Z",
  "consent": {
    "version": "2026-10-v1",
    "acceptedAt": "2026-10-27T12:00:00Z",
    "isAdult": true,
    "understandsScreeningNotDiagnosis": true
  }
}
```

Timestamps are shown as ISO strings here; in Firestore they are `Timestamp` values.

### Write behaviour

- **Create only.** The app creates the document once at sign-up and never updates it.
- **No account without consent.** If the display name or the Firestore write fails, the
  new Firebase Auth account is deleted (`firebase_auth_service.dart:75`) and the error is
  passed to the Register screen.
- **Reads.** The app does not read this document yet. The signed-in user's name shown on
  the dashboard comes from the Firebase Auth `displayName`, not from Firestore.

## Security rules

Defined in `firestore.rules` and registered in `firebase.json`.

| Path | Read | Create | Update | Delete |
|---|---|---|---|---|
| `users/{uid}` | owner only | owner only, with validation | owner only, with validation | owner only |
| `users/{uid}/{subcollection}/...` | owner only | owner only | owner only | owner only |
| anything else | denied | denied | denied | denied |

"Owner" means `request.auth.uid == uid`.

Validation on `users/{uid}`:

- Only the fields `name`, `email`, `createdAt` and `consent` are allowed.
- `name` is a string of 3 to 50 characters.
- `email` must equal the signed-in account's email (`request.auth.token.email`).
- On create, `createdAt` must be the server time of the write.
- On create, `consent` must contain exactly the four fields above, a non-empty `version`,
  `acceptedAt` equal to the server time, and both booleans `true`.
- On update, `createdAt` cannot change, and `consent` must either stay the same or be a
  new valid consent record (re-consent).

The subcollection rule allows owner-only data under a user's document. **No
subcollections exist yet.** The rule is there so future per-user data stays private by
default.

The rules are in the repo, but they take effect only after
`firebase deploy --only firestore:rules`.

## What is not in Firestore

| Data | Where it lives now |
|---|---|
| Password | Firebase Authentication only. Never written to Firestore. |
| Login session | Firebase Authentication on the device |
| Failed login count and 30-second lockout | In memory on the Login screen (`LoginThrottle`), reset on restart |
| Mood strip selection on the dashboard | Widget state only, not saved |
| Check-in count on the dashboard | Not stored; the card shows 0 |
| Assessment answers, scores, reports | Not built. The Assessment and Report screens use sample data. |
| Room photos | Not built. Firebase Storage is in the planned stack but not a dependency yet. |

## Planned data with no schema yet

`PRODUCT.md` and the module plan list these, but no fields have been designed:

- Assessment results (OCI-R, SI-R, the "Keep or let go" task) - Module 4
- AI screening results and reports - Module 9
- Therapy program progress - Module 10
- Progress tracking, history, chatbot - Module 11

Add each one to this file when its first Firestore write is written.
