/**
 * Script to check and update current user's role
 * Run: node scripts/check-my-role.js <your-email> <new-role>
 * Example: node scripts/check-my-role.js user@example.com teacher
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');

const email = process.argv[2];
const newRole = process.argv[3];

if (!email) {
  console.error('❌ Please provide email address');
  console.log('Usage: node scripts/check-my-role.js <your-email> [new-role]');
  console.log('Example: node scripts/check-my-role.js user@example.com teacher');
  process.exit(1);
}

async function checkAndUpdateRole() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find user
    const user = await User.findOne({ email });
    
    if (!user) {
      console.error(`❌ User not found with email: ${email}`);
      process.exit(1);
    }

    console.log('\n📋 Current user info:');
    console.log(`   ID: ${user._id}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Username: ${user.username}`);
    console.log(`   Name: ${user.firstName} ${user.lastName}`);
    console.log(`   Current Role: ${user.role || 'user'}`);

    // Update role if provided
    if (newRole) {
      if (!['user', 'teacher', 'admin'].includes(newRole)) {
        console.error(`❌ Invalid role: ${newRole}`);
        console.log('   Valid roles: user, teacher, admin');
        process.exit(1);
      }

      const oldRole = user.role;
      user.role = newRole;
      await user.save();

      console.log(`\n✅ Role updated: ${oldRole || 'user'} → ${newRole}`);
    }

    console.log('\n✨ Done!');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkAndUpdateRole();
