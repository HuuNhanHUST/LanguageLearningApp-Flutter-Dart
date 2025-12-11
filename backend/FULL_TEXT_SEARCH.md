# Full-Text Search Implementation

## Overview
Implemented MongoDB Full-Text Search for the Word collection with custom field weights for optimized search performance.

## Implementation Details

### 1. Database Index
**File**: `backend/src/models/Word.js`

Added compound text index with weighted fields:
```javascript
wordSchema.index({ 
  word: 'text', 
  meaning: 'text', 
  example: 'text',
  topic: 'text'
}, {
  name: 'word_fulltext_search',
  default_language: 'english',
  weights: {
    word: 10,        // Highest priority - exact word matches
    meaning: 5,      // Medium-high priority - definitions
    topic: 3,        // Medium priority - categories
    example: 1       // Lowest priority - usage examples
  }
});
```

### 2. API Endpoint
**File**: `backend/src/controllers/wordController.js`

```javascript
exports.searchWords = async (req, res) => {
  // Full-Text Search with text score
  const searchResults = await Word.find(
    { $text: { $search: searchQuery } },
    { score: { $meta: 'textScore' } }
  )
  .sort({ score: { $meta: 'textScore' } })
  .skip(skip)
  .limit(limitNum);
};
```

**Route**: `GET /api/words/search`
**File**: `backend/src/routes/wordRoutes.js`

### 3. API Usage

**Request:**
```http
GET /api/words/search?q=hello&limit=10&page=1
Authorization: Bearer <JWT_TOKEN>
```

**Query Parameters:**
- `q` (required): Search query string
- `limit` (optional): Results per page (default: 20)
- `page` (optional): Page number (default: 1)

**Response:**
```json
{
  "success": true,
  "message": "Search completed successfully",
  "data": {
    "words": [
      {
        "_id": "...",
        "word": "hello",
        "meaning": "Lời chào, từ dùng để chào hỏi",
        "type": "noun",
        "example": "Hello, how are you?",
        "topic": "Greetings",
        "isMemorized": false,
        "isInVocabulary": true,
        "reviewCount": 5,
        "accuracyRate": 0.8
      }
    ],
    "total": 2,
    "page": 1,
    "totalPages": 1,
    "hasMore": false,
    "searchTime": 65,
    "query": "hello"
  }
}
```

### 4. Features

✅ **Full-Text Search**: Uses MongoDB's native `$text` search operator
✅ **Relevance Scoring**: Results sorted by `textScore` with weighted fields
✅ **Pagination**: Support for `limit` and `page` parameters
✅ **User Context**: Shows if words are in user's vocabulary
✅ **Performance Tracking**: Returns search execution time
✅ **Error Handling**: Validates query parameters and handles errors

### 5. Performance

**Definition of Done (DoD)**: Search time < 100ms ✅

**Test Results**:
```
🔍 Testing search for: "hello"
⏱️  Search completed in 65ms
📦 Found 2 results

Top results:
1. hello - Lời chào, từ dùng để chào hỏi (Score: 11.75)
2. hlo - Từ không chuẩn trong tiếng Anh. (Score: 0.58)

✅ DoD Met: Search time < 100ms ✓
```

### 6. Index Creation Script

**File**: `backend/src/scripts/createTextIndex.js`

Script to initialize and test the Full-Text Search index:

```bash
node src/scripts/createTextIndex.js
```

This script:
- Connects to MongoDB
- Drops existing text indexes (if any)
- Creates the new weighted text index
- Tests search performance with sample query
- Validates DoD requirement (< 100ms)
- Lists all indexes on Word collection

### 7. Search Algorithm

MongoDB's Full-Text Search uses:
1. **Tokenization**: Breaks text into searchable tokens
2. **Stemming**: Matches word roots (e.g., "running" matches "run")
3. **Stop Words**: Filters common words (e.g., "the", "a", "an")
4. **Scoring**: Calculates relevance based on:
   - Term frequency (TF)
   - Inverse document frequency (IDF)
   - Field weights (custom configured)

### 8. Future Enhancements

- [ ] Add Vietnamese language support for text index
- [ ] Implement search suggestions/autocomplete
- [ ] Add search history tracking
- [ ] Support for phrase searches with quotes
- [ ] Fuzzy matching for typos
- [ ] Search filters (by topic, level, type)
- [ ] Search analytics and trending terms

### 9. Testing

**Manual Testing:**
```bash
# Start server
cd backend
npm start

# Test search (replace <TOKEN> with valid JWT)
curl -X GET "http://localhost:5000/api/words/search?q=hello&limit=5" \
  -H "Authorization: Bearer <TOKEN>"
```

**Expected Behavior:**
- ✅ Returns results sorted by relevance
- ✅ Shows user's vocabulary status for each word
- ✅ Search time < 100ms
- ✅ Supports pagination
- ✅ Handles empty queries with 400 error
- ✅ Requires authentication (401 if no token)

### 10. Index Management

**View all indexes:**
```javascript
db.words.getIndexes()
```

**Drop text index:**
```javascript
db.words.dropIndex("word_fulltext_search")
```

**Rebuild index:**
```javascript
db.words.reIndex()
```

### 11. Troubleshooting

**Issue**: Search returns no results
- **Solution**: Ensure text index is created (run `createTextIndex.js`)

**Issue**: Search is slow (>100ms)
- **Solution**: Check database indexes, ensure index is not dropped

**Issue**: Search doesn't match expected words
- **Solution**: Review field weights, check tokenization and stemming

**Issue**: Error "text index required for $text query"
- **Solution**: Run `node src/scripts/createTextIndex.js` to create index

## Implementation Date
December 11, 2025

## Status
✅ **Complete** - All DoD requirements met
- Text index created with custom weights
- API endpoint implemented and tested
- Search performance < 100ms
- Pagination support added
- User context integrated
- Error handling implemented
