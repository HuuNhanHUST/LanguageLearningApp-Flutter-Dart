const mongoose = require('mongoose');
const User = require('../models/User');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

async function connectDB() {
  try {
    const uri = process.env.MONGODB_URI;
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 10000,
      socketTimeoutMS: 45000,
    });
    console.log('✅ Connected to MongoDB\n');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  }
}

async function seedLeaderboardData() {
  await connectDB();
  
  try {
    console.log('🌱 Seeding leaderboard data...\n');

    // Create test users with varying XP levels
    const testUsers = [
      { username: 'champion_user', email: 'champion@test.com', firstName: 'Champion', lastName: 'User', xp: 10000, level: 50, password: 'password123' },
      { username: 'master_user', email: 'master@test.com', firstName: 'Master', lastName: 'User', xp: 8500, level: 42, password: 'password123' },
      { username: 'expert_user', email: 'expert@test.com', firstName: 'Expert', lastName: 'User', xp: 7200, level: 36, password: 'password123' },
      { username: 'advanced_user', email: 'advanced@test.com', firstName: 'Advanced', lastName: 'User', xp: 6000, level: 30, password: 'password123' },
      { username: 'intermediate_user', email: 'intermediate@test.com', firstName: 'Intermediate', lastName: 'User', xp: 4500, level: 22, password: 'password123' },
      { username: 'beginner_user', email: 'beginner@test.com', firstName: 'Beginner', lastName: 'User', xp: 2000, level: 10, password: 'password123' },
      { username: 'newbie_user', email: 'newbie@test.com', firstName: 'Newbie', lastName: 'User', xp: 500, level: 5, password: 'password123' },
    ];

    // Generate additional random users (93 more to make 100 total)
    for (let i = 1; i <= 93; i++) {
      const randomXP = Math.floor(Math.random() * 5000) + 100; // 100-5100 XP
      const level = Math.floor(randomXP / 100) + 1;
      
      testUsers.push({
        username: `user_${i.toString().padStart(3, '0')}`,
        email: `user${i}@test.com`,
        firstName: `User`,
        lastName: `${i}`,
        xp: randomXP,
        level: level,
        password: 'password123',
        streak: Math.floor(Math.random() * 30)
      });
    }

    // Clear existing test users
    console.log('🗑️  Clearing existing test users...');
    await User.deleteMany({ email: { $regex: '@test.com$' } });

    // Insert new test users
    console.log('➕ Creating test users...');
    const createdUsers = await User.insertMany(testUsers);
    console.log(`✅ Created ${createdUsers.length} test users\n`);

    // Display top 10 users
    const top10 = await User.find({})
      .select('username xp level')
      .sort({ xp: -1 })
      .limit(10);

    console.log('🏆 Top 10 Users:');
    console.log('═'.repeat(60));
    top10.forEach((user, index) => {
      console.log(`${(index + 1).toString().padStart(2, ' ')}. ${user.username.padEnd(20, ' ')} - XP: ${user.xp.toString().padStart(6, ' ')} - Level: ${user.level}`);
    });
    console.log('═'.repeat(60));

    // Get a valid token for testing
    const testUser = createdUsers[0];
    const token = testUser.generateAccessToken();
    
    console.log('\n🔑 Test Token (use this for API testing):');
    console.log(token);
    console.log(`\n👤 Test User: ${testUser.username} (${testUser.email})`);
    console.log(`   User ID: ${testUser._id}`);
    console.log(`   XP: ${testUser.xp}`);
    console.log(`   Level: ${testUser.level}\n`);

    console.log('✅ Leaderboard seeding completed successfully!\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
}

// Run seeding
seedLeaderboardData();
