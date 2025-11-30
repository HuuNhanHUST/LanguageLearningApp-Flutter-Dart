# 🔄 MIGRATION GUIDE: Word Model Refactoring

## 📋 Overview
Refactored từ **single model** (Word với owners/memorizedBy) sang **two-model pattern** (Word + UserWord) để support 3000 từ pre-loaded dictionary.

## ✅ Changes Completed

### 1. **Word Model** (src/models/Word.js)
**Before:** Word có `owners[]` và `memorizedBy[]` arrays
**After:** Word = Global dictionary, không có user-specific data

**New Fields:**
- `level`: beginner | intermediate | advanced
- `frequency`: Word frequency rank (1 = most common)
- `pronunciation`: IPA phonetic notation
- `synonyms[]`: List of synonyms
- `antonyms[]`: List of antonyms
- `totalLearners`: Count of users who added this word

**Removed Fields:**
- ❌ `owners[]`
- ❌ `memorizedBy[]`

---

### 2. **UserWord Model** (src/models/UserWord.js) - NEW
**Purpose:** Track user-word relationship và learning progress

**Key Fields:**
- `userId`: Reference to User
- `wordId`: Reference to Word
- `isMemorized`: Boolean
- `reviewCount`, `correctCount`, `incorrectCount`: Statistics
- `easinessFactor`, `interval`, `nextReviewDate`: Spaced repetition (SM-2)
- `personalNote`, `personalExample`: User customization

**Methods:**
- `toggleMemorized()`: Toggle memorization status
- `updateReview(quality)`: Update based on SM-2 algorithm
- `getUserStats(userId)`: Get user's vocabulary statistics
- `getDueWords(userId)`: Get words due for review

---

### 3. **Controller Refactoring** (src/controllers/wordController.js)

#### **lookupWord** (POST /api/words/lookup)
```
Old Flow:
1. Find word
2. Add userId to owners[]
3. Return word

New Flow:
1. Find word in Word collection
2. Check UserWord for user-word relationship
3. If not exists, create UserWord entry
4. Increment Word.totalLearners
5. Return word + user data
```

#### **createWord** (POST /api/words/create)
```
Old: Create Word với owners = [userId]
New: Create Word + Create UserWord entry
```

#### **getWords** (GET /api/words)
```
Old: Word.find({ owners: userId })
New: UserWord.find({ userId }).populate('wordId')
```

#### **updateWord** (PUT /api/words/:id)
```
Old: Update Word fields + memorizedBy[]
New: Update Word definition + UserWord personal data
```

#### **deleteWord** (DELETE /api/words/:id)
```
Old: Remove userId from owners[], delete if empty
New: Delete UserWord entry, decrement totalLearners
```

#### **toggleMemorized** (PATCH /api/words/:id/memorize)
```
Old: Add/remove userId in memorizedBy[]
New: Toggle UserWord.isMemorized
```

#### **NEW: getUserStats** (GET /api/words/stats)
Returns user's vocabulary statistics

#### **NEW: getDueWords** (GET /api/words/due)
Returns words due for review based on spaced repetition

---

### 4. **Routes Updated** (src/routes/wordRoutes.js)
Added new routes:
- `GET /api/words/stats` → getUserStats
- `GET /api/words/due` → getDueWords

---

## 🔄 Data Migration Script

**IMPORTANT:** Run this script ONLY if you have existing data with old schema

```javascript
// File: backend/scripts/migrate-to-two-model.js
const mongoose = require('mongoose');
require('dotenv').config();

// Import OLD schema (Word.legacy.js if you backed it up)
const WordLegacy = require('../src/models/Word.legacy');
// Import NEW schemas
const Word = require('../src/models/Word');
const UserWord = require('../src/models/UserWord');

async function migrateData() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get all old words
    const oldWords = await WordLegacy.find({});
    console.log(`📊 Found ${oldWords.length} words to migrate`);

    for (const oldWord of oldWords) {
      // 1. Create new Word (dictionary entry) without owners/memorizedBy
      let newWord = await Word.findOne({ normalizedWord: oldWord.normalizedWord });
      
      if (!newWord) {
        newWord = await Word.create({
          word: oldWord.word,
          meaning: oldWord.meaning,
          type: oldWord.type,
          example: oldWord.example,
          topic: oldWord.topic,
          totalLearners: oldWord.owners?.length || 0,
        });
        console.log(`✅ Created word: ${newWord.word}`);
      }

      // 2. Create UserWord entries for each owner
      if (oldWord.owners && oldWord.owners.length > 0) {
        for (const userId of oldWord.owners) {
          const isMemorized = oldWord.memorizedBy?.some(
            id => id.toString() === userId.toString()
          ) || false;

          await UserWord.create({
            userId: userId,
            wordId: newWord._id,
            isMemorized: isMemorized,
            addedAt: oldWord.createdAt || new Date(),
            source: 'migration',
            nextReviewDate: new Date(Date.now() + 24 * 60 * 60 * 1000),
          });
          
          console.log(`  → Added UserWord for user ${userId}`);
        }
      }
    }

    console.log('✅ Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

migrateData();
```

**To run migration:**
```bash
cd backend
node scripts/migrate-to-two-model.js
```

---

## 🧪 Testing Checklist

### Backend Tests:
- [ ] POST /api/words/lookup - Lookup từ dictionary
- [ ] POST /api/words/lookup - Lookup từ mới (qua Gemini)
- [ ] POST /api/words/create - Tạo từ manual
- [ ] GET /api/words - Lấy danh sách từ của user
- [ ] GET /api/words/:id - Lấy chi tiết 1 từ
- [ ] PUT /api/words/:id - Update từ
- [ ] DELETE /api/words/:id - Xóa từ khỏi vocabulary
- [ ] PATCH /api/words/:id/memorize - Toggle memorized
- [ ] GET /api/words/stats - Thống kê vocabulary
- [ ] GET /api/words/due - Words due for review

### Data Integrity:
- [ ] Verify 3000 từ pre-loaded không có userId
- [ ] Verify UserWord entries có correct userId + wordId
- [ ] Verify isMemorized status preserved
- [ ] Verify totalLearners count accurate

---

## 🚀 Import 3000 Words Script

```javascript
// File: backend/scripts/import-3000-words.js
const mongoose = require('mongoose');
const Word = require('../src/models/Word');
require('dotenv').config();

// Your 3000 words data (from Google Colab)
const words3000 = require('./data/3000-words.json');

async function importWords() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    for (const wordData of words3000) {
      await Word.findOneAndUpdate(
        { normalizedWord: wordData.word.toLowerCase() },
        {
          word: wordData.word,
          meaning: wordData.meaning,
          type: wordData.type || 'other',
          example: wordData.example,
          topic: wordData.topic || 'General',
          level: wordData.level || 'intermediate',
          frequency: wordData.frequency || 0,
          pronunciation: wordData.pronunciation,
          synonyms: wordData.synonyms || [],
          antonyms: wordData.antonyms || [],
          totalLearners: 0,
        },
        { upsert: true, new: true }
      );
    }

    console.log(`✅ Imported ${words3000.length} words!`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Import failed:', error);
    process.exit(1);
  }
}

importWords();
```

---

## 📊 API Response Changes

### Before:
```json
{
  "success": true,
  "data": {
    "word": {
      "id": "...",
      "word": "hello",
      "meaning": "xin chào",
      "isMemorized": true
    }
  }
}
```

### After (same format, backward compatible):
```json
{
  "success": true,
  "data": {
    "word": {
      "id": "...",
      "word": "hello",
      "meaning": "xin chào",
      "isMemorized": true,
      "addedAt": "2025-01-15",
      "reviewCount": 5,
      "accuracyRate": 80,
      "nextReviewDate": "2025-01-20",
      "personalNote": "Từ đơn giản"
    }
  }
}
```

**✅ Backward Compatible:** Frontend cũ vẫn hoạt động vì `isMemorized` vẫn có!

---

## 🎯 Benefits of New Architecture

1. **✅ Scalability**: 3000 từ không bị "claimed" bởi users
2. **✅ Performance**: Indexed queries trên UserWord
3. **✅ Storage Efficiency**: Không có arrays lớn
4. **✅ Feature Rich**: Spaced repetition, statistics, personal notes
5. **✅ Analytics**: totalLearners, accuracy tracking
6. **✅ Separation of Concerns**: Dictionary vs User Data

---

## ⚠️ Important Notes

1. **3000 từ pre-loaded** nên được import VÀO Word collection (không có UserWord)
2. **Khi user lookup từ**, tạo UserWord entry để track learning progress
3. **Word.totalLearners** được auto-update khi user add/remove từ
4. **Frontend không cần thay đổi** vì API response format giữ nguyên

---

## 🔧 Next Steps

1. Run migration script (if có data cũ)
2. Import 3000 words vào Word collection
3. Test all API endpoints
4. Update frontend nếu muốn sử dụng new fields (optional)
5. Deploy to production

---

**Status:** ✅ Migration Complete - Ready for Testing
