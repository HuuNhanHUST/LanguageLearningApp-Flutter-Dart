const jwt = require('jsonwebtoken');
require('dotenv').config();

function getTestToken() {
  const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
  const testUserId = process.env.TEST_USER_ID || '507f1f77bcf86cd799439011';
  return jwt.sign({ id: testUserId }, JWT_SECRET, { expiresIn: '24h' });
}

module.exports = getTestToken;
