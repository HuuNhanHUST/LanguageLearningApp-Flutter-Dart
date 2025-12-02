const User = require('../models/User');

/**
 * Gamification Service
 * Xử lý nghiệp vụ cộng điểm, thăng cấp, streak cho người dùng
 */

// Cấu hình XP cần thiết cho mỗi level
const LEVEL_XP_REQUIREMENTS = {
    1: 0,
    2: 100,
    3: 250,
    4: 450,
    5: 700,
    6: 1000,
    7: 1400,
    8: 1850,
    9: 2350,
    10: 2900,
    11: 3500,
    12: 4150,
    13: 4850,
    14: 5600,
    15: 6400,
    16: 7250,
    17: 8150,
    18: 9100,
    19: 10100,
    20: 11150
};

/**
 * Tính toán level dựa trên XP
 * @param {Number} xp - Tổng XP hiện tại
 * @returns {Number} - Level tương ứng
 */
const calculateLevel = (xp) => {
    let level = 1;
    
    for (let lvl = 20; lvl >= 1; lvl--) {
        if (xp >= LEVEL_XP_REQUIREMENTS[lvl]) {
            level = lvl;
            break;
        }
    }
    
    return level;
};

/**
 * Tính toán XP cần thiết để lên level tiếp theo
 * @param {Number} currentLevel - Level hiện tại
 * @returns {Number} - XP cần thiết cho level tiếp theo
 */
const getXPForNextLevel = (currentLevel) => {
    if (currentLevel >= 20) return null; // Max level
    return LEVEL_XP_REQUIREMENTS[currentLevel + 1];
};

/**
 * Tính toán XP dựa trên điểm số bài học
 * @param {Number} score - Điểm số (0-100)
 * @param {String} difficulty - Độ khó: easy, medium, hard
 * @returns {Number} - Số XP nhận được
 */
const calculateXPFromScore = (score, difficulty = 'medium') => {
    const baseXP = {
        easy: 10,
        medium: 20,
        hard: 30
    };
    
    const multiplier = score / 100; // 0.0 - 1.0
    const earnedXP = Math.floor(baseXP[difficulty] * multiplier);
    
    return earnedXP;
};

/**
 * Cộng XP cho người dùng và kiểm tra level up
 * @param {String} userId - ID của user
 * @param {Number} amount - Số XP cần cộng
 * @returns {Object} - Kết quả bao gồm XP mới, level mới, và thông tin level up
 */
const addXP = async (userId, amount) => {
    try {
        // Lấy user hiện tại
        const user = await User.findById(userId);
        
        if (!user) {
            throw new Error('User not found');
        }
        
        // Lưu level cũ
        const oldLevel = user.level;
        const oldXP = user.xp;
        
        // Cộng XP
        user.xp += amount;
        
        // Tính toán level mới
        const newLevel = calculateLevel(user.xp);
        
        // Kiểm tra level up
        const leveledUp = newLevel > oldLevel;
        
        if (leveledUp) {
            user.level = newLevel;
        }
        
        // Lưu user
        await user.save();
        
        // Tính XP cần thiết cho level tiếp theo
        const xpForNextLevel = getXPForNextLevel(newLevel);
        const xpInCurrentLevel = user.xp - LEVEL_XP_REQUIREMENTS[newLevel];
        const xpNeededForNextLevel = xpForNextLevel ? (xpForNextLevel - user.xp) : 0;
        
        return {
            success: true,
            currentXP: user.xp,
            xpGained: amount,
            level: user.level,
            leveledUp,
            levelsGained: leveledUp ? (newLevel - oldLevel) : 0,
            oldLevel,
            newLevel,
            xpForNextLevel,
            xpInCurrentLevel,
            xpNeededForNextLevel,
            streak: user.streak
        };
        
    } catch (error) {
        console.error('Error adding XP:', error);
        throw error;
    }
};

/**
 * Cập nhật streak của người dùng
 * @param {String} userId - ID của user
 * @returns {Object} - Streak mới
 */
const updateStreak = async (userId) => {
    try {
        const user = await User.findById(userId);
        
        if (!user) {
            throw new Error('User not found');
        }
        
        const now = new Date();
        const lastActive = new Date(user.lastActiveDate);
        
        // Reset về đầu ngày để so sánh
        now.setHours(0, 0, 0, 0);
        lastActive.setHours(0, 0, 0, 0);
        
        const diffTime = Math.abs(now - lastActive);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays === 0) {
            // Cùng ngày - không thay đổi streak
            return {
                streak: user.streak,
                streakMaintained: true,
                streakBroken: false
            };
        } else if (diffDays === 1) {
            // Ngày tiếp theo - tăng streak
            user.streak += 1;
            user.lastActiveDate = new Date();
            await user.save();
            
            return {
                streak: user.streak,
                streakMaintained: true,
                streakBroken: false
            };
        } else {
            // Quá 1 ngày - reset streak
            user.streak = 1;
            user.lastActiveDate = new Date();
            await user.save();
            
            return {
                streak: user.streak,
                streakMaintained: false,
                streakBroken: true
            };
        }
        
    } catch (error) {
        console.error('Error updating streak:', error);
        throw error;
    }
};

/**
 * Xử lý hoàn thành bài học
 * @param {String} userId - ID của user
 * @param {Object} lessonData - Dữ liệu bài học { score, difficulty, activityType }
 * @returns {Object} - Kết quả gamification
 */
const completeLessonActivity = async (userId, lessonData) => {
    try {
        const { score, difficulty = 'medium', activityType = 'lesson' } = lessonData;
        
        // Validate score
        if (score < 0 || score > 100) {
            throw new Error('Score must be between 0 and 100');
        }
        
        // Tính XP dựa trên score
        const xpEarned = calculateXPFromScore(score, difficulty);
        
        // Cộng XP và kiểm tra level up
        const xpResult = await addXP(userId, xpEarned);
        
        // Cập nhật streak
        const streakResult = await updateStreak(userId);
        
        return {
            success: true,
            message: 'Lesson completed successfully',
            xp: xpResult,
            streak: streakResult,
            activityType,
            score
        };
        
    } catch (error) {
        console.error('Error completing lesson activity:', error);
        throw error;
    }
};

/**
 * Lấy thông tin gamification của user
 * @param {String} userId - ID của user
 * @returns {Object} - Thông tin gamification
 */
const getGamificationStats = async (userId) => {
    try {
        const user = await User.findById(userId);
        
        if (!user) {
            throw new Error('User not found');
        }
        
        const xpForNextLevel = getXPForNextLevel(user.level);
        const xpInCurrentLevel = user.xp - LEVEL_XP_REQUIREMENTS[user.level];
        const xpNeededForNextLevel = xpForNextLevel ? (xpForNextLevel - user.xp) : 0;
        
        return {
            currentXP: user.xp,
            level: user.level,
            streak: user.streak,
            xpForNextLevel,
            xpInCurrentLevel,
            xpNeededForNextLevel,
            lastActiveDate: user.lastActiveDate,
            isMaxLevel: user.level >= 20
        };
        
    } catch (error) {
        console.error('Error getting gamification stats:', error);
        throw error;
    }
};

module.exports = {
    addXP,
    calculateLevel,
    getXPForNextLevel,
    calculateXPFromScore,
    updateStreak,
    completeLessonActivity,
    getGamificationStats,
    LEVEL_XP_REQUIREMENTS
};
