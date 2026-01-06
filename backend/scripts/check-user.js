/**
 * Script để kiểm tra chi tiết user
 * Chạy: node backend/scripts/check-user.js <userId>
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');

const checkUser = async () => {
    try {
        const userId = process.argv[2] || '695c482e83f7dd4b4e8c72f5'; // ID từ log
        
        // Kết nối MongoDB
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/languagelearning');
        console.log('✅ Connected to MongoDB\n');
        
        // Tìm user
        const user = await User.findById(userId);
        
        if (!user) {
            console.log(`❌ User not found with ID: ${userId}`);
            process.exit(1);
        }
        
        console.log('==========================================');
        console.log('USER DETAILS:');
        console.log('==========================================');
        console.log(`ID: ${user._id}`);
        console.log(`Username: ${user.username || 'MISSING ❌'}`);
        console.log(`Email: ${user.email || 'MISSING ❌'}`);
        console.log(`First Name: ${user.firstName || 'MISSING ❌'}`);
        console.log(`Last Name: ${user.lastName || 'MISSING ❌'}`);
        console.log(`Role: ${user.role || 'MISSING ❌'}`);
        console.log(`Avatar: ${user.avatar || 'null'}`);
        console.log(`Native Language: ${user.nativeLanguage || 'MISSING ❌'}`);
        console.log(`XP: ${user.xp !== undefined ? user.xp : 'MISSING ❌'}`);
        console.log(`Level: ${user.level !== undefined ? user.level : 'MISSING ❌'}`);
        console.log(`Streak: ${user.streak !== undefined ? user.streak : 'MISSING ❌'}`);
        console.log(`Learning Languages: ${user.learningLanguages ? JSON.stringify(user.learningLanguages) : 'MISSING ❌'}`);
        console.log(`Preferences: ${user.preferences ? JSON.stringify(user.preferences) : 'MISSING ❌'}`);
        console.log(`Created At: ${user.createdAt || 'MISSING ❌'}`);
        console.log(`Is Active: ${user.isActive}`);
        console.log('==========================================\n');
        
        console.log('PUBLIC PROFILE OUTPUT:');
        console.log('==========================================');
        const publicProfile = user.getPublicProfile();
        console.log(JSON.stringify(publicProfile, null, 2));
        console.log('==========================================\n');
        
        process.exit(0);
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error(error.stack);
        process.exit(1);
    }
};

checkUser();
