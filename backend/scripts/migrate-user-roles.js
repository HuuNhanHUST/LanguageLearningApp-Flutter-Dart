/**
 * Script to migrate old users without role field
 * This adds role='user' to all users that don't have a role
 * Run: node scripts/migrate-user-roles.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');

async function migrateUserRoles() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find all users without role field or with null/undefined role
    const usersWithoutRole = await User.find({
      $or: [
        { role: { $exists: false } },
        { role: null },
        { role: '' }
      ]
    });

    console.log(`\n📊 Found ${usersWithoutRole.length} users without role`);

    if (usersWithoutRole.length === 0) {
      console.log('✅ All users already have roles assigned!');
      process.exit(0);
    }

    // Update each user
    let updated = 0;
    for (const user of usersWithoutRole) {
      console.log(`\n🔧 Updating user: ${user.username} (${user.email})`);
      console.log(`   Current role: ${user.role || 'undefined'}`);
      
      user.role = 'user'; // Set default role
      await user.save();
      
      console.log(`   ✅ Updated to: ${user.role}`);
      updated++;
    }

    console.log(`\n🎉 Migration complete! Updated ${updated} users`);
    
    // Show summary
    const roleStats = await User.aggregate([
      {
        $group: {
          _id: '$role',
          count: { $sum: 1 }
        }
      },
      {
        $sort: { _id: 1 }
      }
    ]);

    console.log('\n📊 Current role distribution:');
    roleStats.forEach(stat => {
      console.log(`   ${(stat._id || 'no role').padEnd(10)}: ${stat.count} users`);
    });

    process.exit(0);

  } catch (error) {
    console.error('❌ Migration error:', error.message);
    process.exit(1);
  }
}

migrateUserRoles();
