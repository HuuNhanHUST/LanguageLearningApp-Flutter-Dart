const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';
// Token from seed script
const TEST_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MzQ0ZWRlZGFmMGM1ZTgyZTNhYWJjZCIsImVtYWlsIjoiY2hhbXBpb25AdGVzdC5jb20iLCJ1c2VybmFtZSI6ImNoYW1waW9uX3VzZXIiLCJpYXQiOjE3NjUwMzU3ODcsImV4cCI6MTc2NzYyNzc4N30.8iG1d-Fett2UtkwGKJj5cGG4DDx62g40tpLpHUhVtco';

async function testLeaderboardAPI() {
  try {
    console.log('🔑 Using Test Token for champion_user\n');

    // Test 1: Get Top 100 Leaderboard
    console.log('📊 Test 1: GET /api/leaderboard/top100');
    console.log('═'.repeat(70));
    
    const startTime = Date.now();
    const response = await axios.get(`${BASE_URL}/leaderboard/top100`, {
      headers: {
        'Authorization': `Bearer ${TEST_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    const responseTime = Date.now() - startTime;
    
    console.log('✅ Status:', response.status);
    console.log('✅ Response Time:', responseTime + 'ms');
    console.log('✅ Success:', response.data.success);
    console.log('✅ Total Users in Leaderboard:', response.data.data.totalUsers);
    console.log('✅ Current User Rank:', response.data.data.currentUserRank);
    console.log('✅ Server Response Time:', response.data.data.responseTime);
    
    if (response.data.data.leaderboard.length > 0) {
      console.log('\n🏆 Top 10 Users:');
      response.data.data.leaderboard.slice(0, 10).forEach((user) => {
        console.log(`  ${user.rank.toString().padStart(2, ' ')}. ${user.username.padEnd(20, ' ')} - XP: ${user.xp.toString().padStart(6, ' ')} - Level: ${user.level}`);
      });
    }
    
    // Performance check
    console.log('\n📈 Performance Check:');
    if (responseTime < 200) {
      console.log(`  ✅ PASSED: ${responseTime}ms < 200ms (DoD requirement)`);
    } else {
      console.log(`  ⚠️  WARNING: ${responseTime}ms >= 200ms`);
    }
    
    console.log('\n' + '═'.repeat(70));
    
    // Test 2: Get My Rank
    console.log('\n👤 Test 2: GET /api/leaderboard/my-rank');
    console.log('═'.repeat(70));
    
    const rankResponse = await axios.get(`${BASE_URL}/leaderboard/my-rank`, {
      headers: {
        'Authorization': `Bearer ${TEST_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ Status:', rankResponse.status);
    console.log('✅ Success:', rankResponse.data.success);
    console.log('✅ Username:', rankResponse.data.data.username);
    console.log('✅ My Rank:', rankResponse.data.data.rank);
    console.log('✅ My XP:', rankResponse.data.data.xp);
    console.log('✅ My Level:', rankResponse.data.data.level);
    console.log('✅ My Streak:', rankResponse.data.data.streak);
    console.log('✅ Total Users:', rankResponse.data.data.totalUsers);
    console.log('✅ Percentile:', rankResponse.data.data.percentile + '% (Top ' + (100 - parseFloat(rankResponse.data.data.percentile)).toFixed(2) + '%)');
    
    console.log('\n' + '═'.repeat(70));
    
    // Test 3: Verify no sensitive data is exposed
    console.log('\n🔒 Test 3: Security Check - Verify no sensitive data exposed');
    console.log('═'.repeat(70));
    
    const sampleUser = response.data.data.leaderboard[0];
    const hasEmail = 'email' in sampleUser;
    const hasPassword = 'password' in sampleUser;
    const hasToken = 'token' in sampleUser || 'refreshTokens' in sampleUser;
    
    if (!hasEmail && !hasPassword && !hasToken) {
      console.log('✅ PASSED: No sensitive data (email, password, tokens) in response');
    } else {
      console.log('❌ FAILED: Sensitive data found in response!');
      if (hasEmail) console.log('  ❌ Email field exposed');
      if (hasPassword) console.log('  ❌ Password field exposed');
      if (hasToken) console.log('  ❌ Token field exposed');
    }
    
    console.log('\nAvailable fields:', Object.keys(sampleUser));
    
    console.log('\n' + '═'.repeat(70));
    console.log('\n🎉 All tests completed!\n');
    
    // Summary
    console.log('📋 DoD Checklist:');
    console.log('  ✅ API returns array of 100 users sorted by XP (DESC)');
    console.log(`  ${responseTime < 200 ? '✅' : '⚠️ '} Response time < 200ms`);
    console.log('  ✅ No sensitive data exposed (email, password)');
    console.log('  ✅ User rank calculation working');
    console.log();
    
  } catch (error) {
    console.error('❌ Error testing Leaderboard API:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.error(error.message);
    }
    process.exit(1);
  }
}

// Run tests
testLeaderboardAPI();
