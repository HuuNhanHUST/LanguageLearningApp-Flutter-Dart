// Test script để kiểm tra Rate Limiter
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const axios = require('axios');

// Tạo file audio dummy để test
const dummyAudioPath = path.join(__dirname, 'dummy-audio.mp3');

// Tạo file audio giả (100KB)
if (!fs.existsSync(dummyAudioPath)) {
  const dummyBuffer = Buffer.alloc(100 * 1024); // 100KB
  fs.writeFileSync(dummyAudioPath, dummyBuffer);
  console.log('✅ Tạo file audio dummy thành công');
}

// URL endpoint
const API_URL = 'http://localhost:5000/api/upload/audio';

// Lấy token: ưu tiên lấy trực tiếp từ module tạo token để tránh copy/paste lỗi
let TOKEN = null;
try {
  const getTestToken = require('./src/utils/getTestToken');
  TOKEN = getTestToken();
} catch (err) {
  // Fallback: lấy từ environment (và sanitize)
  const rawToken = process.env.TEST_TOKEN || 'test_token'; // Thay bằng token thực tế
  TOKEN = String(rawToken).replace(/\s+/g, '');
}

// Diagnostic: show token length and whether it contains non-ASCII
function isAscii(str) {
  return /^[\x00-\x7F]*$/.test(str);
}
console.log('\n🔐 Using token for test (length):', TOKEN.length);
if (!isAscii(TOKEN)) {
  console.log('⚠️ Token contains non-ASCII characters. Showing first 100 code points:');
  const codes = TOKEN.split('').slice(0, 100).map(c => c.charCodeAt(0));
  console.log(codes);
}

// Hàm gửi request
async function sendRequest(requestNumber) {
  const form = new FormData();
  form.append('audio', fs.createReadStream(dummyAudioPath), 'test-audio.mp3');

  try {
    const headers = {
      ...form.getHeaders(),
      'Authorization': `Bearer ${TOKEN}`,
    };

    // Diagnostic: show Authorization header length (not full token)
    console.log(`  Debug: Authorization header length ${String(headers.Authorization).length}`);

    const response = await axios.post(API_URL, form, {
      headers,
      validateStatus: () => true, // Chấp nhận tất cả status codes
    });

    const status = response.status;
    const data = response.data;
    
    console.log(`Request #${requestNumber}:`);
    console.log(`  Status: ${status}`);
    console.log(`  Message: ${data.message}`);
    
    // In chi tiết rate limit nếu có
    if (response.headers['ratelimit-limit']) {
      console.log(`  Rate-Limit: ${response.headers['ratelimit-remaining']}/${response.headers['ratelimit-limit']}`);
    }
    
    return status;
  } catch (error) {
    console.log(`Request #${requestNumber}: ❌ Error - ${error.message}`);
    if (error.response) {
      console.log('  Response status:', error.response.status);
      console.log('  Response data:', error.response.data);
      console.log('  Response headers:', error.response.headers);
    } else if (error.request) {
      console.log('  No response received. Request made but no reply.');
    } else {
      console.log('  Axios error:', error.code || error.message);
    }
    return null;
  }
}

// Hàm test spam
async function testRateLimiter() {
  console.log(`\n🔥 Bắt đầu spam 15 requests đến ${API_URL}\n`);
  
  const results = [];
  
  for (let i = 1; i <= 15; i++) {
    const status = await sendRequest(i);
    results.push(status);
    
    // Chờ 100ms giữa các request
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  console.log('\n📊 Kết quả:');
  const success200 = results.filter(s => s === 200).length;
  const rateLimited429 = results.filter(s => s === 429).length;
  const unauthorized401 = results.filter(s => s === 401).length;
  
  console.log(`✅ Requests thành công (200): ${success200}`);
  console.log(`🚫 Requests bị chặn (429): ${rateLimited429}`);
  console.log(`🔐 Unauthorized (401): ${unauthorized401}`);
  
  if (rateLimited429 > 0 && success200 === 10) {
    console.log('\n✨ Rate Limiter hoạt động đúng! 10 requests được chấp nhận, những request sau bị chặn.');
  } else if (unauthorized401 > 0) {
    console.log('\n⚠️ Token không hợp lệ. Bạn cần sử dụng token thực tế từ server.');
    console.log('💡 Gợi ý: Đăng nhập và lấy token, sau đó chạy: TEST_TOKEN=your_token node test-rate-limiter.js');
  }
}

// Chạy test
testRateLimiter();
