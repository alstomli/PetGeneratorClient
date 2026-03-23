# Pet Evolution - API Integration Guide

## Overview
The app connects to a real backend at `http://10.0.0.131:3001` (LAN IP) using Gemini image generation.

## Base URL
```swift
// PetEvolutionService.swift
private let baseURL = "http://10.0.0.131:3001"
```

---

## Endpoints

### GET /api/health
Health check — called on app launch to show/hide the server unreachable banner.

**Response:** `{ "status": "ok" }`

---

### POST /api/google/generate-pet
Generates a new stage-1 pet from configuration.

**Content-Type:** `application/json`

**Body:**
```json
{
  "style": "Gentle",
  "colorPalette": "Blue and Purple",
  "animals": ["Cat", "Dragon"],
  "maxStages": 3
}
```

> Note: All string values use title case (first letter capitalized).

**Response:** `Pet` object (see Models.swift)

---

### POST /api/google/evolve-pet
Evolves a pet to the next stage. Uploads the current pet image.

**Content-Type:** `multipart/form-data`

**Fields:**

| Field | Type | Notes |
|-------|------|-------|
| `petId` | string | Pet ID from previous response |
| `currentStage` | string | Current stage number |
| `maxStages` | string | Max stages number |
| `description` | string | From `pet.prompt` (truncated to 200 chars) |
| `evolutionPath` | string | `pet.style ?? pet.evolutionPath ?? "Gentle"` |
| `colorPalette` | string | From `pet.colorPalette` |
| `previousMetadata` | string | JSON string of `pet.metadata` |
| `augments` | string | JSON array string, e.g. `"[]"` |
| `image` | file | PNG decoded from `pet.imageUrl` base64 |

**Response:** `Pet` object

---

## App Flow

```
[Configuration Screen]
  → Style: Gentle / Fierce / Playful / Mystical
  → Color Palette: Blue and Purple / Fire and Red / etc.
  → Animals: Cat, Dragon, Fox... (multi-select)
  → "Generate Pet!" → POST /api/google/generate-pet

[First Evolution Screen]
  → Shows Stage 1 pet
  → "Evolve!" → POST /api/google/evolve-pet

[Final Evolution Screen]
  → Shows Stage 2 pet
  → "Final Evolve!" → POST /api/google/evolve-pet

[Completion Screen]
  → Shows Stage 3 (final) pet
  → "Start New Evolution" → reset
```

---

## Notes

- `imageUrl` in all responses is a base64 data URL (`data:image/png;base64,...`) — use `PetImageView` to display
- The `augments` field in Pet may be any array type; it is safely decoded with fallback to `[]`
- `metadata` is stored as `[String: AnyJSON]?` for arbitrary JSON pass-through
- All HTTP requests go through `URLSession` with ATS exception set in `Info.plist`
