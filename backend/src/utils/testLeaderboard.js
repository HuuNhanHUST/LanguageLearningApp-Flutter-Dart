const axios = require('axios');
const getTestToken = require('./getTestToken');

const BASE_URL = 'http://localhost:5000/api';

async function testLeaderboardAPI() {
  try {
    const token = getTestToken();
    console.log('🔑 Test Token generated successfully');
    console.log('Token:', token.substring(0, 50) + '...\n');

    // Test 1: Get Top 100 Leaderboard
    console.log('📊 Test 1: GET /api/leaderboard/top100');
    console.log('=' .repeat(60));
    
    const startTime = Date.now();
    const response = await axios.get(`${BASE_URL}/leaderboard/top100`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    const responseTime = Date.now() - startTime;
    
    console.log('✅ Status:', response.status);
    console.log('✅ Response Time:', responseTime + 'ms');
    console.log('✅ Success:', response.data.success);
    console.log('✅ Total Users in Leaderboard:', response.data.data.totalUsers);
    console.log('✅ Current User Rank:', response.data.data.currentUserRank);
    
    if (response.data.data.leaderboard.length > 0) {
      console.log('\n🏆 Top 5 Users:');
      response.data.data.leaderboard.slice(0, 5).forEach((user, index) => {
        console.log(`  ${index + 1}. ${user.username} - XP: ${user.xp} - Level: ${user.level}`);
      });
    }
    
    // Performance check
    if (responseTime < 200) {
      console.log(`\n✅ Performance: PASSED (${responseTime}ms < 200ms)`);
    } else {
      console.log(`\n⚠️  Performance: WARNING (${responseTime}ms >= 200ms)`);
    }
    
    console.log('\n' + '=' .repeat(60));
    
    // Test 2: Get My Rank
    console.log('\n👤 Test 2: GET /api/leaderboard/my-rank');
    console.log('=' .repeat(60));
    
    const rankResponse = await axios.get(`${BASE_URL}/leaderboard/my-rank`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ Status:', rankResponse.status);
    console.log('✅ Success:', rankResponse.data.success);
    console.log('✅ My Rank:', rankResponse.data.data.rank);
    console.log('✅ My XP:', rankResponse.data.data.xp);
    console.log('✅ My Level:', rankResponse.data.data.level);
    console.log('✅ Percentile:', rankResponse.data.data.percentile + '%');
    
    console.log('\n' + '=' .repeat(60));
    console.log('🎉 All tests completed successfully!\n');
    
  } catch (error) {
    console.error('❌ Error testing Leaderboard API:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    } else {
      console.error(error.message);
    }
  }
}

// Run tests
testLeaderboardAPI();
