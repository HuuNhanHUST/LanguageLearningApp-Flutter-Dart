# SCRUM-25: Pronunciation Scoring API Testing

## API Endpoints

### 1. POST /api/pronunciation/compare
**Full pronunciation analysis with score and word-by-word feedback**

**Request:**
```json
{
  "target": "Hello, how are you today?",
  "transcript": "Hello how are you"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Pronunciation analysis completed",
  "data": {
    "score": 85.71,
    "accuracy": 80,
    "target": "hello how are you today",
    "transcript": "hello how are you",
    "wordDetails": [
      { "word": "hello", "status": "correct", "position": 0 },
      { "word": "how", "status": "correct", "position": 1 },
      { "word": "are", "status": "correct", "position": 2 },
      { "word": "you", "status": "correct", "position": 3 },
      { "word": "today", "status": "missing", "position": 4 }
    ],
    "stats": {
      "totalWords": 5,
      "correctWords": 4,
      "wrongWords": 0,
      "closeWords": 0,
      "missingWords": 1,
      "extraWords": 0
    }
  }
}
```

---

### 2. POST /api/pronunciation/score
**Calculate similarity score only (simplified)**

**Request:**
```json
{
  "target": "Good morning everyone",
  "transcript": "Good morning everyOne"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Score calculated successfully",
  "data": {
    "score": 100,
    "target": "good morning everyone",
    "transcript": "good morning everyone"
  }
}
```

---

### 3. POST /api/pronunciation/errors
**Get word-by-word error highlights**

**Request:**
```json
{
  "target": "The quick brown fox",
  "transcript": "The qick brwn fox"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Error highlighting completed",
  "data": {
    "wordDetails": [
      { "word": "the", "status": "correct", "position": 0 },
      { 
        "word": "qick", 
        "expected": "quick",
        "status": "close", 
        "similarity": 80,
        "position": 1 
      },
      { 
        "word": "brwn", 
        "expected": "brown",
        "status": "close", 
        "similarity": 80,
        "position": 2 
      },
      { "word": "fox", "status": "correct", "position": 3 }
    ],
    "target": "the quick brown fox",
    "transcript": "the qick brwn fox"
  }
}
```

---

## Word Status Types

- **`correct`**: Word matches exactly
- **`wrong`**: Word is significantly different (similarity < 70%)
- **`close`**: Word is similar but not exact (similarity >= 70%)
- **`missing`**: Word is in target but not in transcript
- **`extra`**: Word is in transcript but not in target

---

## Algorithm Details

### Levenshtein Distance
- Uses `fast-levenshtein` library for string comparison
- Calculates edit distance between two strings
- Formula: `similarity = ((maxLength - distance) / maxLength) * 100`

### Text Normalization
1. Convert to lowercase
2. Remove punctuation: `.,!?;:"""''()[]{}` 
3. Replace multiple spaces with single space
4. Trim whitespace

### Scoring
- **Score**: Overall similarity percentage (0-100) based on Levenshtein distance
- **Accuracy**: Percentage of correct words out of total words

---

## Testing with curl (requires Bearer token)

```bash
# Get auth token first
TOKEN="your_jwt_token_here"

# Test compare endpoint
curl -X POST http://localhost:5000/api/pronunciation/compare \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "target": "Hello world",
    "transcript": "Hello wrld"
  }'

# Test score endpoint
curl -X POST http://localhost:5000/api/pronunciation/score \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "target": "Good morning",
    "transcript": "Good morning"
  }'

# Test errors endpoint
curl -X POST http://localhost:5000/api/pronunciation/errors \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "target": "The cat is black",
    "transcript": "The ct is blak"
  }'
```

---

## Definition of Done (DoD) ✅

- [x] Install `fast-levenshtein` library
- [x] Implement `calculateScore(target, transcript)` function
  - [x] Normalize strings (lowercase, remove punctuation)
  - [x] Calculate similarity percentage using Levenshtein distance
  - [x] Return score (0-100)
- [x] Implement `highlightErrors(target, transcript)` function
  - [x] Identify wrong/missing/extra words
  - [x] Return array with word status (correct/wrong/close/missing/extra)
- [x] API returns JSON with: `score`, `transcript`, and word-by-word error details
- [x] Add authentication middleware (requires login)
- [x] Create 3 endpoints: `/compare`, `/score`, `/errors`
- [x] Add to server.js routes

---

## Files Created

1. `backend/src/services/pronunciationService.js` - Core logic
2. `backend/src/controllers/pronunciationController.js` - API handlers
3. `backend/src/routes/pronunciationRoutes.js` - Route definitions
4. `backend/server.js` - Updated with pronunciation routes

---

## Next Steps

1. Test API với Postman hoặc curl
2. Tích hợp vào Flutter app
3. Thêm UI để hiển thị word-by-word feedback với màu sắc:
   - 🟢 Correct (green)
   - 🟡 Close (yellow)
   - 🔴 Wrong (red)
   - ⚪ Missing (gray)
   - 🔵 Extra (blue)
