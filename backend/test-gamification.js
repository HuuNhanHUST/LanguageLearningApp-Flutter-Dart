const axios = require('axios');

/**
 * Script để test Gamification API
 * Chạy: node test-gamification.js
 */

const BASE_URL = 'http://localhost:5000/api';

// Thông tin user để test (cần đăng nhập trước)
let accessToken = '';
let userId = '';

// Hàm helper để gọi API
const api = axios.create({
    baseURL: BASE_URL,
    headers: {
        'Content-Type': 'application/json'
    }
});

// Thêm token vào request
api.interceptors.request.use(config => {
    if (accessToken) {
        config.headers.Authorization = `Bearer ${accessToken}`;
    }
    return config;
});

// Test functions
async function testRegisterOrLogin() {
    console.log('\n📝 Test 1: Register/Login User');
    console.log('='.repeat(50));
    
    try {
        // Thử login trước
        const loginData = {
            email: 'testgamification@test.com',
            password: 'test123'
        };
        
        try {
            const response = await api.post('/users/login', loginData);
            accessToken = response.data.data.accessToken;
            userId = response.data.data.user.id;
            
            console.log('✅ Login successful');
            console.log('User ID:', userId);
            console.log('Current XP:', response.data.data.user.xp);
            console.log('Current Level:', response.data.data.user.level);
            return true;
        } catch (loginError) {
            // Nếu login thất bại, thử register
            console.log('⚠️  Login failed, trying to register...');
            
            const registerData = {
                username: 'testgamification',
                email: 'testgamification@test.com',
                password: 'test123',
                firstName: 'Test',
                lastName: 'Gamification'
            };
            
            const response = await api.post('/users/register', registerData);
            accessToken = response.data.data.accessToken;
            userId = response.data.data.user.id;
            
            console.log('✅ Register successful');
            console.log('User ID:', userId);
            console.log('Current XP:', response.data.data.user.xp);
            console.log('Current Level:', response.data.data.user.level);
            return true;
        }
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
        return false;
    }
}

async function testGetLevelRequirements() {
    console.log('\n📊 Test 2: Get Level Requirements');
    console.log('='.repeat(50));
    
    try {
        const response = await api.get('/gamification/levels');
        console.log('✅ Level requirements retrieved');
        console.log('Max Level:', response.data.data.maxLevel);
        console.log('Sample levels:');
        const levels = response.data.data.levels;
        for (let i = 1; i <= 5; i++) {
            console.log(`  Level ${i}: ${levels[i]} XP`);
        }
        return true;
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
        return false;
    }
}

async function testGetGamificationStats() {
    console.log('\n📈 Test 3: Get Gamification Stats');
    console.log('='.repeat(50));
    
    try {
        const response = await api.get('/gamification/stats');
        console.log('✅ Stats retrieved');
        console.log('Current XP:', response.data.data.currentXP);
        console.log('Level:', response.data.data.level);
        console.log('Streak:', response.data.data.streak);
        console.log('XP for next level:', response.data.data.xpForNextLevel);
        console.log('XP needed for next level:', response.data.data.xpNeededForNextLevel);
        return true;
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
        return false;
    }
}

async function testAddProgressWithScore(score, difficulty) {
    console.log(`\n🎯 Test 4: Add Progress (Score: ${score}, Difficulty: ${difficulty})`);
    console.log('='.repeat(50));
    
    try {
        const response = await api.post('/gamification/progress', {
            score,
            difficulty,
            activityType: 'lesson'
        });
        
        console.log('✅ Progress updated');
        console.log('Message:', response.data.message);
        console.log('XP Gained:', response.data.data.xpGained);
        console.log('Current XP:', response.data.data.currentXP);
        console.log('Level:', response.data.data.level);
        console.log('Leveled Up:', response.data.data.leveledUp);
        
        if (response.data.data.leveledUp) {
            console.log('🎉 LEVEL UP! Levels gained:', response.data.data.levelsGained);
        }
        
        console.log('Streak:', response.data.data.streak);
        console.log('XP needed for next level:', response.data.data.xpNeededForNextLevel);
        
        return true;
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
        return false;
    }
}

async function testAddXPDirectly(amount) {
    console.log(`\n⚡ Test 5: Add XP Directly (Amount: ${amount})`);
    console.log('='.repeat(50));
    
    try {
        const response = await api.post('/gamification/add-xp', { amount });
        
        console.log('✅ XP added');
        console.log('Message:', response.data.message);
        console.log('XP Gained:', response.data.data.xpGained);
        console.log('Current XP:', response.data.data.currentXP);
        console.log('Level:', response.data.data.level);
        console.log('Leveled Up:', response.data.data.leveledUp);
        
        if (response.data.data.leveledUp) {
            console.log('🎉 LEVEL UP! Levels gained:', response.data.data.levelsGained);
        }
        
        return true;
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
        return false;
    }
}

async function testUpdateStreak() {
    console.log('\n🔥 Test 6: Update Streak');
    console.log('='.repeat(50));
    
    try {
        const response = await api.post('/gamification/update-streak');
        
        console.log('✅ Streak updated');
        console.log('Message:', response.data.message);
        console.log('Streak:', response.data.data.streak);
        console.log('Streak Maintained:', response.data.data.streakMaintained);
        console.log('Streak Broken:', response.data.data.streakBroken);
        
        return true;
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
        return false;
    }
}

async function testLevelUpScenario() {
    console.log('\n🚀 Test 7: Level Up Scenario (Multiple completions)');
    console.log('='.repeat(50));
    
    try {
        // Hoàn thành 5 bài học với điểm cao
        for (let i = 1; i <= 5; i++) {
            console.log(`\n  Lesson ${i}:`);
            const score = 80 + Math.floor(Math.random() * 20); // 80-100
            const difficulty = ['easy', 'medium', 'hard'][Math.floor(Math.random() * 3)];
            
            const response = await api.post('/gamification/progress', {
                score,
                difficulty,
                activityType: 'lesson'
            });
            
            console.log(`    Score: ${score}, Difficulty: ${difficulty}`);
            console.log(`    XP Gained: ${response.data.data.xpGained}`);
            console.log(`    Total XP: ${response.data.data.currentXP}`);
            console.log(`    Level: ${response.data.data.level}`);
            
            if (response.data.data.leveledUp) {
                console.log(`    🎉 LEVEL UP to ${response.data.data.level}!`);
            }
            
            // Delay nhỏ giữa các request
            await new Promise(resolve => setTimeout(resolve, 500));
        }
        
        return true;
    } catch (error) {
        console.error('❌ Error:', error.response?.data || error.message);
        return false;
    }
}

async function testInvalidInputs() {
    console.log('\n⚠️  Test 8: Invalid Inputs');
    console.log('='.repeat(50));
    
    // Test score > 100
    try {
        await api.post('/gamification/progress', {
            score: 150,
            difficulty: 'medium'
        });
        console.log('❌ Should have failed for score > 100');
    } catch (error) {
        console.log('✅ Correctly rejected score > 100');
        console.log('   Error:', error.response?.data?.message);
    }
    
    // Test score < 0
    try {
        await api.post('/gamification/progress', {
            score: -10,
            difficulty: 'medium'
        });
        console.log('❌ Should have failed for score < 0');
    } catch (error) {
        console.log('✅ Correctly rejected score < 0');
        console.log('   Error:', error.response?.data?.message);
    }
    
    // Test invalid difficulty
    try {
        await api.post('/gamification/progress', {
            score: 80,
            difficulty: 'super_hard'
        });
        console.log('❌ Should have failed for invalid difficulty');
    } catch (error) {
        console.log('✅ Correctly rejected invalid difficulty');
        console.log('   Error:', error.response?.data?.errors?.[0]?.msg);
    }
    
    return true;
}

// Main test runner
async function runAllTests() {
    console.log('\n🧪 GAMIFICATION API TEST SUITE');
    console.log('='.repeat(50));
    console.log('Testing API endpoints for gamification feature\n');
    
    const results = [];
    
    // Test 1: Register/Login
    results.push(await testRegisterOrLogin());
    
    if (!accessToken) {
        console.error('\n❌ Cannot continue tests without authentication');
        return;
    }
    
    // Test 2: Get Level Requirements
    results.push(await testGetLevelRequirements());
    
    // Test 3: Get Stats
    results.push(await testGetGamificationStats());
    
    // Test 4: Add Progress với các score khác nhau
    results.push(await testAddProgressWithScore(50, 'easy'));
    results.push(await testAddProgressWithScore(75, 'medium'));
    results.push(await testAddProgressWithScore(100, 'hard'));
    
    // Test 5: Add XP directly
    results.push(await testAddXPDirectly(50));
    
    // Test 6: Update Streak
    results.push(await testUpdateStreak());
    
    // Test 7: Level Up Scenario
    results.push(await testLevelUpScenario());
    
    // Test 8: Invalid Inputs
    results.push(await testInvalidInputs());
    
    // Summary
    console.log('\n📊 TEST SUMMARY');
    console.log('='.repeat(50));
    const passed = results.filter(r => r).length;
    const total = results.length;
    console.log(`Passed: ${passed}/${total}`);
    console.log(`Failed: ${total - passed}/${total}`);
    
    if (passed === total) {
        console.log('\n✅ ALL TESTS PASSED! 🎉');
    } else {
        console.log('\n⚠️  SOME TESTS FAILED');
    }
    
    // Final stats
    await testGetGamificationStats();
}

// Run tests
runAllTests().catch(error => {
    console.error('\n💥 Unexpected error:', error.message);
    process.exit(1);
});
