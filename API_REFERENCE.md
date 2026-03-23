# Pet Evolution API Reference

Base URL: `http://localhost:3001`

Start server: `npm start` (requires `GEMINI_API_KEY` in `.env`)

---

## Endpoints

### GET /api/health
Health check.

**Response:**
```json
{ "status": "ok" }
```

---

### POST /api/google/generate-pet
Generate a new baby pet (stage 1).

**Content-Type:** `application/json`

**Body:**
```json
{
  "style": "Gentle",
  "colorPalette": "Blue and Purple",
  "animals": ["Cat", "Dragon"],
  "maxStages": 3,
  "guaranteeAugment": false
}
```

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `style` | string | No | `"gentle"` | Pet personality style. Valid: `bold`, `gentle`, `curious` (see [Supported Types](#supported-types)) |
| `colorPalette` | string | No | `"rainbow bright"` | Color description |
| `animals` | string[] | No | `[]` | Animal inspirations |
| `maxStages` | number | No | `3` | Total evolution stages |
| `guaranteeAugment` | boolean | No | `false` | Force an augment to be applied |

**Response:**
```json
{
  "id": "1769651134217",
  "stage": 1,
  "maxStages": 3,
  "style": "Gentle",
  "colorPalette": "Blue and Purple",
  "animals": ["Cat", "Dragon"],
  "imageUrl": "data:image/png;base64,...",
  "prompt": "...",
  "metadata": "...",
  "augments": [],
  "provider": "google"
}
```

**curl:**
```bash
curl -X POST http://localhost:3001/api/google/generate-pet \
  -H "Content-Type: application/json" \
  -d '{
    "style": "Gentle",
    "colorPalette": "Blue and Purple",
    "animals": ["Cat", "Dragon"],
    "maxStages": 3
  }'
```

---

### POST /api/google/evolve-pet
Evolve a pet to the next stage.

**Content-Type:** `multipart/form-data`

**Fields:**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `petId` | string | Yes | ID of the pet to evolve |
| `currentStage` | number | Yes | Current stage (e.g. `1`) |
| `maxStages` | number | Yes | Max stages (e.g. `3`) |
| `description` | string | Yes | Text description of the pet |
| `evolutionPath` | string | No | Default: `"gentle"` | Valid: `bold`, `gentle`, `curious` (see [Supported Types](#supported-types)) |
| `colorPalette` | string | No | Pet's color palette |
| `previousMetadata` | string | No | Metadata from previous stage |
| `augments` | string (JSON) | No | JSON array of existing augments |
| `guaranteeAugment` | boolean | No | Force a new augment |
| `image` | file | No | Upload pet image (png/jpg, max 10MB). **Cannot be a URL — must be a local file.** |

**Response:**
```json
{
  "id": "1769651134217-2-1769651186186",
  "stage": 2,
  "maxStages": 3,
  "evolutionPath": "gentle",
  "imageUrl": "data:image/png;base64,...",
  "prompt": "...",
  "metadata": "...",
  "augments": [],
  "provider": "google"
}
```

**curl (no image):**
```bash
curl -X POST http://localhost:3001/api/google/evolve-pet \
  -F "petId=1769651134217" \
  -F "currentStage=1" \
  -F "maxStages=3" \
  -F "description=a cute dragon-cat hybrid with blue scales" \
  -F "evolutionPath=gentle" \
  -F "colorPalette=blue and purple"
```

**curl (with image file):**
```bash
curl -X POST http://localhost:3001/api/google/evolve-pet \
  -F "petId=1769651134217" \
  -F "currentStage=1" \
  -F "maxStages=3" \
  -F "description=a cute dragon-cat hybrid with blue scales" \
  -F "image=@/path/to/pet.png"
```

---

### POST /api/google/merge-pets
Merge two saved pets into one.

**Content-Type:** `application/json`

**Body:**
```json
{
  "pet1Id": "1769651134217",
  "pet2Id": "1769651186186"
}
```

> Both pets must be saved to disk first via `POST /api/pets/save`.

**Response:**
```json
{
  "pet": {
    "id": "...",
    "stage": 1,
    "imageUrl": "data:image/png;base64,...",
    "augments": [],
    "provider": "google"
  },
  "isRare": false,
  "rareType": null,
  "sourceHandling": {
    "pet1": "preserved",
    "pet2": "preserved"
  }
}
```

**curl:**
```bash
curl -X POST http://localhost:3001/api/google/merge-pets \
  -H "Content-Type: application/json" \
  -d '{"pet1Id": "1769651134217", "pet2Id": "1769651186186"}'
```

---

### GET /api/google/merge-pets/preview
Preview merge outcome without generating an image.

**Query params:** `pet1Id`, `pet2Id`

**curl:**
```bash
curl "http://localhost:3001/api/google/merge-pets/preview?pet1Id=AAA&pet2Id=BBB"
```

---

### POST /api/pets/save
Save a pet object to disk.

**Content-Type:** `application/json`

**Body:**
```json
{
  "pet": { "id": "1769651134217", "stage": 1, "imageUrl": "data:image/png;base64,..." },
  "params": {}
}
```

**Response:**
```json
{ "success": true, "id": "1769651134217" }
```

---

### GET /api/pets
Get all saved pets.

**curl:**
```bash
curl http://localhost:3001/api/pets
```

---

### GET /api/pets/:id
Get a single saved pet by ID.

**curl:**
```bash
curl http://localhost:3001/api/pets/1769651134217
```

---

### GET /api/pets/:id/image.png
Get the raw image file of a saved pet.

**curl:**
```bash
curl http://localhost:3001/api/pets/1769651134217/image.png --output pet.png
```

---

### DELETE /api/pets/:id
Delete a saved pet.

**curl:**
```bash
curl -X DELETE http://localhost:3001/api/pets/1769651134217
```

---

## Supported Types

### Styles

The `style` field (used in `generate-pet`) and `evolutionPath` field (used in `evolve-pet`) share the same valid values:

| Value | Description |
|-------|-------------|
| `bold` | Transforms with dramatic physical changes — larger, more powerful and confident body, prominent strength features. Fearless and ready for adventure. |
| `gentle` | Transforms with dramatic physical changes — rounder, fluffier body, bigger expressive features, prominent nurturing traits. Warm and approachable. |
| `curious` | Transforms with dramatic physical changes — more elaborate mystical features, prominent magical appendages (multiple tails, wings, crystals), glowing elements. Inquisitive and mysterious. |

> `curious` style has a +10% bonus augment chance on generation, and +15% on evolution.

---

### Color Palettes

Valid values for `colorPalette`:

| Category | Values |
|----------|--------|
| Warm | `sunset orange`, `golden sun`, `cherry blossom pink`, `autumn leaves`, `coral reef`, `cinnamon spice` |
| Cool | `ocean blue`, `forest green`, `arctic ice`, `lavender dreams`, `mint fresh`, `slate storm` |
| Vibrant | `rainbow bright`, `neon electric`, `tropical paradise`, `berry blast` |
| Magical/Dark | `purple magic`, `starry night`, `midnight galaxy`, `mystic moonlight` |
| Soft/Light | `pink princess`, `cotton candy`, `pastel sunrise`, `cream vanilla` |
| Earthy | `mossy woodland`, `desert sand`, `volcanic ember` |

---

### Animal Inspirations

Valid values for `animals`:

| Category | Values |
|----------|--------|
| Domestic | `cat`, `dog`, `bunny`, `hamster` |
| Forest | `fox`, `bear`, `deer`, `squirrel`, `raccoon`, `wolf` |
| Sea & Sky | `bird`, `butterfly`, `owl`, `eagle`, `dolphin`, `penguin`, `seal`, `stingray`, `crab`, `octopus` |
| Mythical | `dragon`, `unicorn`, `phoenix`, `griffin` |
| Exotic | `tiger`, `lion`, `panda`, `elephant`, `giraffe`, `monkey`, `chameleon`, `kangaroo`, `sloth`, `armadillo` |

> Mythical animals (`dragon`, `phoenix`, `unicorn`, `griffin`) have a +10% bonus augment chance on generation.

---

## Notes

- `imageUrl` in responses is always a base64 data URL (`data:image/png;base64,...`)
- Image upload for evolve-pet must be a **local file**, not a URL
- The `evolve-pet` endpoint uses `multipart/form-data`; all other endpoints use `application/json`
- Pets must be saved via `/api/pets/save` before they can be merged
