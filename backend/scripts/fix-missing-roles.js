/**
 * Migration script to fix users without role field
 * Run: node scripts/fix-missing-roles.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');

async function fixMissingRoles() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find all users without role or with null/undefined role
    const usersWithoutRole = await User.find({
      $or: [
        { role: { $exists: false } },
        { role: null },
        { role: '' }
      ]
    });

    console.log(`\n🔍 Found ${usersWithoutRole.length} users without role\n`);

    if (usersWithoutRole.length === 0) {
      console.log('✅ All users already have roles!');
      process.exit(0);
    }

    // Update each user
    let updated = 0;
    for (const user of usersWithoutRole) {
      user.role = 'user'; // Set default role as 'user'
      await user.save();
      console.log(`✅ Fixed: ${user.username} (${user.email}) - Set role to 'user'`);
      updated++;
    }

    console.log(`\n🎉 Migration complete! Updated ${updated} users.`);
    
    // Verify results
    const stillMissing = await User.countDocuments({
      $or: [
        { role: { $exists: false } },
        { role: null },
        { role: '' }
      ]
    });

    if (stillMissing === 0) {
      console.log('✅ Verification passed: All users now have roles');
    } else {
      console.log(`⚠️  Warning: ${stillMissing} users still missing roles`);
    }

    // Show role distribution
    const roleStats = await User.aggregate([
      { $group: { _id: '$role', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    console.log('\n📊 Role distribution:');
    roleStats.forEach(stat => {
      const roleIcon = stat._id === 'admin' ? '👑' : stat._id === 'teacher' ? '👨‍🏫' : '👤';
      console.log(`  ${roleIcon} ${stat._id}: ${stat.count} users`);
    });

    process.exit(0);

  } catch (error) {
    console.error('❌ Migration error:', error.message);
    process.exit(1);
  }
}

fixMissingRoles();
