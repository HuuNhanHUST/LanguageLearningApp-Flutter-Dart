/**
 * Script to create test users for testing admin dashboard
 * Run: node scripts/create-test-users.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');

const testUsers = [
  {
    username: 'student1',
    email: 'student1@test.com',
    password: 'Test@123456',
    firstName: 'Student',
    lastName: 'One',
    role: 'user',
    nativeLanguage: 'en',
    xp: 50,
    level: 1
  },
  {
    username: 'student2',
    email: 'student2@test.com',
    password: 'Test@123456',
    firstName: 'Student',
    lastName: 'Two',
    role: 'user',
    nativeLanguage: 'vi',
    xp: 120,
    level: 2
  },
  {
    username: 'student3',
    email: 'student3@test.com',
    password: 'Test@123456',
    firstName: 'Student',
    lastName: 'Three',
    role: 'user',
    nativeLanguage: 'en',
    xp: 200,
    level: 3
  },
  {
    username: 'teacher1',
    email: 'teacher1@test.com',
    password: 'Test@123456',
    firstName: 'Teacher',
    lastName: 'One',
    role: 'teacher',
    nativeLanguage: 'en',
    xp: 500,
    level: 5
  },
  {
    username: 'teacher2',
    email: 'teacher2@test.com',
    password: 'Test@123456',
    firstName: 'Teacher',
    lastName: 'Two',
    role: 'teacher',
    nativeLanguage: 'vi',
    xp: 350,
    level: 4
  }
];

async function createTestUsers() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Check if users already exist
    for (const userData of testUsers) {
      const existingUser = await User.findOne({
        $or: [
          { email: userData.email },
          { username: userData.username }
        ]
      });

      if (existingUser) {
        console.log(`⏭️  User ${userData.username} already exists, skipping...`);
        continue;
      }

      // Create new user
      const user = new User(userData);
      await user.save();
      console.log(`✅ Created user: ${userData.username} (${userData.role})`);
    }

    console.log('\n🎉 Test users created successfully!');
    console.log('\nTest accounts:');
    testUsers.forEach(u => {
      console.log(`  ${u.role.padEnd(8)} - ${u.email.padEnd(25)} | Password: Test@123456`);
    });

    process.exit(0);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createTestUsers();
