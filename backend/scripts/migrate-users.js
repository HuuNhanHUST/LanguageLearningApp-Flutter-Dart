/**
 * Script để cập nhật tất cả users cũ với role và các trường còn thiếu
 * Chạy: node backend/scripts/migrate-users.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');

const migrateUsers = async () => {
    try {
        // Kết nối MongoDB
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/languagelearning');
        console.log('✅ Connected to MongoDB');
        
        // Tìm tất cả users
        const users = await User.find({});
        console.log(`\n📊 Found ${users.length} users to check\n`);
        
        let updatedCount = 0;
        
        for (const user of users) {
            let needsUpdate = false;
            const updates = {};
            
            // Set role nếu chưa có
            if (!user.role) {
                updates.role = 'user';
                needsUpdate = true;
                console.log(`  ➤ ${user.username || user.email}: Adding role = 'user'`);
            }
            
            // Set nativeLanguage nếu chưa có
            if (!user.nativeLanguage) {
                updates.nativeLanguage = 'en';
                needsUpdate = true;
                console.log(`  ➤ ${user.username || user.email}: Adding nativeLanguage = 'en'`);
            }
            
            // Set XP, Level, Streak nếu chưa có
            if (user.xp === undefined || user.xp === null) {
                updates.xp = 0;
                needsUpdate = true;
            }
            if (user.level === undefined || user.level === null) {
                updates.level = 1;
                needsUpdate = true;
            }
            if (user.streak === undefined || user.streak === null) {
                updates.streak = 0;
                needsUpdate = true;
            }
            
            // Set preferences nếu chưa có
            if (!user.preferences || typeof user.preferences !== 'object') {
                updates.preferences = {
                    dailyGoal: 10,
                    notifications: true,
                    soundEffects: true
                };
                needsUpdate = true;
                console.log(`  ➤ ${user.username || user.email}: Adding default preferences`);
            }
            
            // Set learningLanguages nếu chưa có
            if (!user.learningLanguages || !Array.isArray(user.learningLanguages)) {
                updates.learningLanguages = [];
                needsUpdate = true;
            }
            
            // Update user nếu cần
            if (needsUpdate) {
                await User.findByIdAndUpdate(user._id, { $set: updates });
                updatedCount++;
                console.log(`  ✅ Updated ${user.username || user.email}\n`);
            }
        }
        
        console.log('\n==========================================');
        console.log(`✅ Migration complete!`);
        console.log(`📊 Total users: ${users.length}`);
        console.log(`🔄 Updated users: ${updatedCount}`);
        console.log(`✓ Up-to-date users: ${users.length - updatedCount}`);
        console.log('==========================================\n');
        
        process.exit(0);
        
    } catch (error) {
        console.error('❌ Migration error:', error.message);
        console.error(error.stack);
        process.exit(1);
    }
};

migrateUsers();
