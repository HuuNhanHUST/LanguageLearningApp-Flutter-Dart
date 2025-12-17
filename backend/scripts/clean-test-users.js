/**
 * Script để xóa test users khỏi database
 * Chỉ giữ lại những users thật (có Facebook/Google ID hoặc email thật)
 */

const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
const mongoose = require('mongoose');
const User = require('../src/models/User');

const cleanTestUsers = async () => {
  try {
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Tìm và xóa test users (username chứa: test, user_, champion_, master_, expert_, advanced_, demo, sample)
    const testUserPatterns = [
      /^test/i,
      /^user_\d+$/i,
      /^champion_/i,
      /^master_/i,
      /^expert_/i,
      /^advanced_/i,
      /^demo/i,
      /^sample/i
    ];

    // Build query để tìm test users
    const query = {
      $or: testUserPatterns.map(pattern => ({ username: { $regex: pattern } }))
    };

    // Preview test users trước khi xóa
    const testUsers = await User.find(query).select('username email xp level');
    console.log(`\n📋 Found ${testUsers.length} test users:`);
    testUsers.forEach(user => {
      console.log(`   - ${user.username} (Level ${user.level}, ${user.xp} XP)`);
    });

    // Confirm deletion
    if (testUsers.length > 0) {
      console.log('\n⚠️  Xóa test users này? (Nhấn Ctrl+C để hủy, Enter để tiếp tục)');
      
      // Delete test users
      const result = await User.deleteMany(query);
      console.log(`✅ Đã xóa ${result.deletedCount} test users`);
      
      // Show remaining users
      const remainingUsers = await User.find().select('username email xp level').sort({ xp: -1 });
      console.log(`\n📊 Còn lại ${remainingUsers.length} real users:`);
      remainingUsers.slice(0, 10).forEach((user, index) => {
        console.log(`   ${index + 1}. ${user.username} (Level ${user.level}, ${user.xp} XP)`);
      });
      if (remainingUsers.length > 10) {
        console.log(`   ... và ${remainingUsers.length - 10} users khác`);
      }
    } else {
      console.log('✅ Không tìm thấy test users nào');
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
    process.exit(0);
  }
};

// Run the script
cleanTestUsers();
