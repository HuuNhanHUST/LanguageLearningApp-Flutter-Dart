/**
 * Script để tạo admin account đầu tiên
 * Chạy: node backend/scripts/create-admin.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../src/models/User');

const createAdminUser = async () => {
    try {
        // Kết nối MongoDB
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/languagelearning');
        console.log('✅ Connected to MongoDB');
        
        // Kiểm tra xem đã có admin chưa
        const existingAdmin = await User.findOne({ role: 'admin' });
        
        if (existingAdmin) {
            console.log('⚠️  Admin account already exists:');
            console.log(`   Email: ${existingAdmin.email}`);
            console.log(`   Username: ${existingAdmin.username}`);
            process.exit(0);
        }
        
        // Tạo admin account mặc định
        const adminData = {
            username: 'admin',
            email: 'admin@languageapp.com',
            password: 'admin123', // Nên đổi password này sau khi đăng nhập
            firstName: 'Admin',
            lastName: 'System',
            role: 'admin',
            isActive: true,
            isVerified: true
        };
        
        const admin = new User(adminData);
        await admin.save();
        
        console.log('\n✅ Admin account created successfully!');
        console.log('==========================================');
        console.log('📧 Email:', adminData.email);
        console.log('👤 Username:', adminData.username);
        console.log('🔑 Password:', adminData.password);
        console.log('==========================================');
        console.log('⚠️  QUAN TRỌNG: Hãy đổi mật khẩu ngay sau khi đăng nhập!\n');
        
        process.exit(0);
        
    } catch (error) {
        console.error('❌ Error creating admin:', error.message);
        process.exit(1);
    }
};

createAdminUser();
