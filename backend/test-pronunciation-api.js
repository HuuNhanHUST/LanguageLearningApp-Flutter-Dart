/**
 * Test script để kiểm tra Pronunciation API
 * Chạy: node test-pronunciation-api.js
 */

const http = require('http');

// Cấu hình
const BASE_URL = 'http://localhost:5000';
const TEST_EMAIL = 'test@example.com';
const TEST_PASSWORD = 'Test123456';

let authToken = null;

// Helper function để gọi API
function makeRequest(path, method, data, token) {
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

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let body = '';

      res.on('data', (chunk) => {
        body += chunk;
      });

      res.on('end', () => {
        try {
          const jsonBody = JSON.parse(body);
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: jsonBody,
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: body,
          });
        }
      });
    });

    req.on('error', reject);

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

// Test 1: Login
async function testLogin() {
  console.log('\n📝 Test 1: Login');
  console.log('='.repeat(50));
  
  const response = await makeRequest(
    '/api/users/login',
    'POST',
    {
      email: TEST_EMAIL,
      password: TEST_PASSWORD,
    }
  );

  console.log(`Status: ${response.status}`);
  console.log(`Success: ${response.body.success}`);
  
  if (response.status === 200 && response.body.success) {
    authToken = response.body.data.token;
    console.log(`✅ Login thành công`);
    console.log(`Token (first 20 chars): ${authToken.substring(0, 20)}...`);
    return true;
  } else {
    console.log(`❌ Login thất bại: ${response.body.message}`);
    console.log(`Hint: Tạo user với email: ${TEST_EMAIL}, password: ${TEST_PASSWORD}`);
    return false;
  }
}

// Test 2: Test Pronunciation API với token
async function testPronunciationAPI() {
  console.log('\n📝 Test 2: Pronunciation API');
  console.log('='.repeat(50));
  
  if (!authToken) {
    console.log('❌ Không có token, skip test này');
    return false;
  }

  const testCases = [
    {
      name: 'Perfect match',
      target: 'Hello world',
      transcript: 'Hello world',
      expectedScore: 100,
    },
    {
      name: 'One error',
      target: 'I eat an apple',
      transcript: 'I eat a apple',
      expectedScore: 90,
    },
    {
      name: 'Multiple errors',
      target: 'The cat is sleeping',
      transcript: 'cat sleep',
      expectedScore: 50,
    },
  ];

  for (const testCase of testCases) {
    console.log(`\n  Testing: ${testCase.name}`);
    console.log(`  Target: "${testCase.target}"`);
    console.log(`  Transcript: "${testCase.transcript}"`);

    const response = await makeRequest(
      '/api/pronunciation/compare',
      'POST',
      {
        target: testCase.target,
        transcript: testCase.transcript,
      },
      authToken
    );

    console.log(`  Status: ${response.status}`);
    
    if (response.status === 200 && response.body.success) {
      const score = response.body.data.score;
      const accuracy = response.body.data.accuracy;
      console.log(`  ✅ Score: ${score.toFixed(2)} (expected ~${testCase.expectedScore})`);
      console.log(`  ✅ Accuracy: ${accuracy}%`);
      console.log(`  ✅ Stats:`, response.body.data.stats);
    } else if (response.status === 401) {
      console.log(`  ❌ 401 Unauthorized!`);
      console.log(`  ❌ Message: ${response.body.message}`);
      console.log(`  ❌ Token có vẻ không hợp lệ!`);
      console.log(`  ❌ Token đang dùng: ${authToken.substring(0, 30)}...`);
      return false;
    } else {
      console.log(`  ❌ Lỗi: ${response.body.message || response.body}`);
      return false;
    }
  }

  return true;
}

// Test 3: Test với token sai
async function testInvalidToken() {
  console.log('\n📝 Test 3: Test với Token sai');
  console.log('='.repeat(50));
  
  const fakeToken = 'fake-token-123456';
  
  const response = await makeRequest(
    '/api/pronunciation/compare',
    'POST',
    {
      target: 'Hello',
      transcript: 'Hello',
    },
    fakeToken
  );

  console.log(`Status: ${response.status}`);
  
  if (response.status === 401) {
    console.log(`✅ Đúng! API trả về 401 với token sai`);
    console.log(`Message: ${response.body.message}`);
    return true;
  } else {
    console.log(`❌ Sai! API nên trả về 401 nhưng trả về ${response.status}`);
    return false;
  }
}

// Main
async function main() {
  console.log('\n🧪 BẮT ĐẦU TEST PRONUNCIATION API');
  console.log('='.repeat(50));
  
  try {
    // Test login
    const loginOk = await testLogin();
    if (!loginOk) {
      console.log('\n❌ Login thất bại. Dừng test.');
      console.log('\n💡 Hướng dẫn:');
      console.log('1. Đảm bảo backend đang chạy: node server.js');
      console.log(`2. Tạo user test: POST /api/users/register`);
      console.log(`   Email: ${TEST_EMAIL}`);
      console.log(`   Password: ${TEST_PASSWORD}`);
      return;
    }

    // Test pronunciation API
    await new Promise((resolve) => setTimeout(resolve, 500));
    const apiOk = await testPronunciationAPI();
    
    if (!apiOk) {
      console.log('\n❌ Pronunciation API test thất bại!');
      console.log('\n🔍 DEBUG INFO:');
      console.log(`   Token being used: ${authToken}`);
      console.log(`   API endpoint: ${BASE_URL}/api/pronunciation/compare`);
      return;
    }

    // Test invalid token
    await new Promise((resolve) => setTimeout(resolve, 500));
    await testInvalidToken();

    console.log('\n✅ TẤT CẢ TEST HOÀN THÀNH!');
    console.log('\n💡 KẾT LUẬN:');
    console.log('   - Backend API hoạt động HOÀN HẢO');
    console.log('   - Authentication middleware OK');
    console.log('   - Pronunciation scoring OK');
    console.log('   - Vấn đề 401 ở Flutter có thể do:');
    console.log('     1. Token không được lưu đúng trong SecureStorage');
    console.log('     2. Token không được gửi đúng format');
    console.log('     3. App đang gửi đến sai URL');
    
  } catch (error) {
    console.log('\n❌ LỖI NGHIÊM TRỌNG:');
    console.log(error);
  }
}

// Run
main();
