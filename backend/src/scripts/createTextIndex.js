/**
 * Script to create Full-Text Search Index on Word collection
 * Run: node src/scripts/createTextIndex.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const Word = require('../models/Word');

const createTextIndex = async () => {
  try {
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    console.log('📊 Creating Full-Text Search Index on Word collection...');
    
    // Drop existing text index if any
    try {
      await Word.collection.dropIndex('word_fulltext_search');
      console.log('🗑️  Dropped old text index');
    } catch (err) {
      // Index doesn't exist, that's ok
      console.log('ℹ️  No existing text index to drop');
    }

    // Create new text index
    await Word.collection.createIndex(
      { 
        word: 'text', 
        meaning: 'text', 
        example: 'text',
        topic: 'text'
      },
      {
        name: 'word_fulltext_search',
        default_language: 'english',
        weights: {
          word: 10,
          meaning: 5,
          topic: 3,
          example: 1
        }
      }
    );

    console.log('✅ Full-Text Search Index created successfully!');

    // Test the index
    const testWord = 'hello';
    console.log(`\n🔍 Testing search for: "${testWord}"`);
    const startTime = Date.now();
    
    const results = await Word.find(
      { $text: { $search: testWord } },
      { score: { $meta: 'textScore' } }
    )
    .sort({ score: { $meta: 'textScore' } })
    .limit(5);

    const endTime = Date.now();
    const duration = endTime - startTime;

    console.log(`⏱️  Search completed in ${duration}ms`);
    console.log(`📦 Found ${results.length} results`);
    
    if (results.length > 0) {
      console.log('\nTop results:');
      results.forEach((word, index) => {
        const scoreValue = word._doc?.score || word.score || 0;
        console.log(`${index + 1}. ${word.word} - ${word.meaning} (Score: ${scoreValue.toFixed(2)})`);
      });
    }

    if (duration < 100) {
      console.log('\n✅ DoD Met: Search time < 100ms ✓');
    } else {
      console.log('\n⚠️  Warning: Search time >= 100ms');
    }

    // Show all indexes
    console.log('\n📋 All indexes on Word collection:');
    const indexes = await Word.collection.getIndexes();
    Object.keys(indexes).forEach(indexName => {
      console.log(`  - ${indexName}`);
    });

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
    process.exit(0);
  }
};

createTextIndex();
