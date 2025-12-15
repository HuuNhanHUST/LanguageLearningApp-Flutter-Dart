const mongoose = require('mongoose');
const Word = require('../models/Word');
const path = require('path');

// Load environment variables từ file .env ở root của backend
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

/**
 * Script để cập nhật difficulty cho các từ CHƯA CÓ difficulty
 * Sử dụng data có sẵn trong database, chỉ set default cho từ thiếu
 */

const updateWordDifficulty = async () => {
  try {
    console.log('🔗 Connecting to MongoDB...');
    
    // Lấy MongoDB URI từ environment variable
    const mongoURI = process.env.MONGODB_URI;
    
    if (!mongoURI) {
      throw new Error('MONGODB_URI not found in environment variables. Please check your .env file');
    }
    
    console.log('🔗 URI found:', mongoURI.replace(/\/\/.*:.*@/, '//***:***@'));
    
    await mongoose.connect(mongoURI);
    console.log('✅ Connected to MongoDB');

    // Lấy tất cả từ CHƯA CÓ difficulty hoặc difficultyLevel
    const wordsNeedUpdate = await Word.find({
      $or: [
        { difficulty: { $exists: false } },
        { difficultyLevel: { $exists: false } },
        { difficulty: null },
        { difficultyLevel: null }
      ]
    });
    
    console.log(`📚 Found ${wordsNeedUpdate.length} words need difficulty update`);

    if (wordsNeedUpdate.length === 0) {
      console.log('✅ All words already have difficulty set!');
      return;
    }

    let updated = 0;
    for (const word of wordsNeedUpdate) {
      // Nếu chưa có, set default dựa vào độ dài từ
      if (!word.difficulty || !word.difficultyLevel) {
        const length = word.word.length;
        
        if (length <= 5) {
          word.difficulty = 'beginner';
          word.difficultyLevel = 1;
        } else if (length <= 7) {
          word.difficulty = 'beginner';
          word.difficultyLevel = 3;
        } else if (length <= 9) {
          word.difficulty = 'intermediate';
          word.difficultyLevel = 5;
        } else if (length <= 11) {
          word.difficulty = 'intermediate';
          word.difficultyLevel = 7;
        } else {
          word.difficulty = 'advanced';
          word.difficultyLevel = 9;
        }
        
        await word.save();
        updated++;
        
        if (updated % 50 === 0) {
          console.log(`⏳ Updated ${updated}/${wordsNeedUpdate.length} words...`);
        }
      }
    }

    console.log(`✅ Successfully updated ${updated} words with difficulty levels`);
    
    // Thống kê tổng thể
    const totalWords = await Word.countDocuments({});
    const stats = await Word.aggregate([
      {
        $group: {
          _id: '$difficulty',
          count: { $sum: 1 }
        }
      }
    ]);
    
    console.log(`\n📊 Total words in database: ${totalWords}`);
    console.log('📊 Difficulty Distribution:');
    stats.forEach(stat => {
      console.log(`   - ${stat._id}: ${stat.count} words`);
    });

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔒 Connection closed');
  }
};

// Run script
updateWordDifficulty();
