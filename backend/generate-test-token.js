// Script để tạo JWT token cho testing
const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Tạo token test cho user ID giả định
const testUserId = '507f1f77bcf86cd799439011'; // MongoDB ObjectId format

const token = jwt.sign(
  { id: testUserId },
  JWT_SECRET,
  { expiresIn: '24h' }
);

console.log('🔐 JWT Token được tạo thành công!');
console.log('\n📋 Token:');
console.log(token);
console.log('\n💡 Cách sử dụng:');
console.log('1. Chạy server: npm start');
console.log('2. Chạy test với token:');
console.log(`   TEST_TOKEN="${token}" node test-rate-limiter.js`);
console.log('\n⏰ Token hết hạn sau 24 giờ');
