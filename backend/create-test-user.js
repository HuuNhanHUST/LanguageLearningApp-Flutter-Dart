/**
 * Script tạo user test
 * Chạy: node create-test-user.js
 */

const http = require('http');

function makeRequest(path, method, data) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 5000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            body: JSON.parse(body),
          });
        } catch (e) {
          resolve({ status: res.statusCode, body: body });
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function createTestUser() {
  console.log('🔨 Tạo user test...\n');
  
  const userData = {
    username: 'testuser',
    email: 'test@example.com',
    password: 'Test123456',
    firstName: 'Test',
    lastName: 'User',
    nativeLanguage: 'vi',
  };

  console.log('Thông tin user:');
  console.log(JSON.stringify(userData, null, 2));
  console.log('');

  const response = await makeRequest(
    '/api/users/register',
    'POST',
    userData
  );

  console.log(`Status: ${response.status}`);
  
  if (response.status === 201) {
    console.log('✅ Tạo user thành công!');
    console.log(`Token: ${response.body.data.token.substring(0, 30)}...`);
    console.log('\n✅ Giờ có thể chạy: node test-pronunciation-api.js');
  } else {
    console.log(`❌ Lỗi: ${response.body.message || response.body}`);
    if (response.body.message && response.body.message.includes('already exists')) {
      console.log('\n💡 User đã tồn tại. Có thể chạy test luôn: node test-pronunciation-api.js');
    }
  }
}

createTestUser().catch(console.error);
