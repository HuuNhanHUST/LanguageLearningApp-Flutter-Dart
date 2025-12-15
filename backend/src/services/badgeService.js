const User = require('../models/User');
const Badge = require('../models/Badge');

/**
 * Badge Service
 * Xử lý nghiệp vụ kiểm tra và trao huy hiệu cho người dùng
 */

/**
 * Lấy thống kê của user để kiểm tra điều kiện badge
 * @param {Object} user - User object từ database
 * @returns {Object} - Thống kê user
 */
const getUserStats = (user) => {
    return {
        xp: user.xp || 0,
        level: user.level || 1,
        totalWordsLearned: user.totalWordsLearned || 0,
        streak: user.streak || 0,
        lessonsCompleted: user.lessonsCompleted || 0,
        perfectScores: user.perfectScores || 0,
        dailyGoalStreak: user.dailyGoalStreak || 0
    };
};

/**
 * Kiểm tra và trao huy hiệu cho người dùng
 * @param {String} userId - ID của user
 * @param {String} activityType - Loại hoạt động vừa thực hiện (optional, để tối ưu)
 * @returns {Object} - Danh sách badges mới nhận được
 */
const checkAndAwardBadges = async (userId, activityType = null) => {
    try {
        // Lấy thông tin user với badges hiện tại
        const user = await User.findById(userId).populate('badges.badgeId');
        
        if (!user) {
            throw new Error('User not found');
        }
        
        // Lấy thống kê user
        const userStats = getUserStats(user);
        
        // Lấy danh sách badge IDs mà user đã có
        const earnedBadgeIds = user.badges.map(b => b.badgeId._id.toString());
        
        // Lấy tất cả badges đang active
        let availableBadges = await Badge.getActiveBadges();
        
        // Nếu có activityType, filter badges liên quan để tối ưu
        if (activityType) {
            availableBadges = availableBadges.filter(badge => {
                const criteriaMap = {
                    'learn_word': ['words_learned', 'xp', 'level'],
                    'complete_lesson': ['lessons_completed', 'xp', 'level'],
                    'daily_practice': ['streak', 'daily_goal', 'xp'],
                    'perfect_score': ['perfect_scores', 'xp', 'level']
                };
                
                const relevantTypes = criteriaMap[activityType] || [];
                return relevantTypes.includes(badge.criteria.type);
            });
        }
        
        // Lọc ra các badges chưa đạt được
        const unearnedBadges = availableBadges.filter(
            badge => !earnedBadgeIds.includes(badge._id.toString())
        );
        
        // Kiểm tra từng badge chưa đạt được
        const newBadges = [];
        for (const badge of unearnedBadges) {
            if (badge.checkCriteria(userStats)) {
                // Thêm badge vào user
                user.badges.push({
                    badgeId: badge._id,
                    earnedAt: new Date()
                });
                
                // Nếu badge có XP bonus, cộng thêm XP
                if (badge.xpBonus > 0) {
                    user.xp += badge.xpBonus;
                    
                    // Recalculate level if needed
                    const { calculateLevel } = require('./gamificationService');
                    const newLevel = calculateLevel(user.xp);
                    if (newLevel > user.level) {
                        user.level = newLevel;
                    }
                }
                
                newBadges.push({
                    id: badge._id,
                    name: badge.name,
                    description: badge.description,
                    iconUrl: badge.iconUrl,
                    category: badge.category,
                    xpBonus: badge.xpBonus,
                    earnedAt: new Date()
                });
            }
        }
        
        // Lưu user nếu có badges mới
        if (newBadges.length > 0) {
            await user.save();
        }
        
        return {
            success: true,
            newBadges,
            totalBadges: user.badges.length,
            message: newBadges.length > 0 
                ? `Chúc mừng! Bạn vừa nhận được ${newBadges.length} huy hiệu mới!`
                : 'Không có huy hiệu mới'
        };
        
    } catch (error) {
        console.error('Error in checkAndAwardBadges:', error);
        throw error;
    }
};

/**
 * Lấy tất cả badges của user
 * @param {String} userId - ID của user
 * @returns {Object} - Thông tin badges của user
 */
const getUserBadges = async (userId) => {
    try {
        const user = await User.findById(userId).populate('badges.badgeId');
        
        if (!user) {
            throw new Error('User not found');
        }
        
        // Get all available badges
        const allBadges = await Badge.getActiveBadges();
        
        // Get user stats
        const userStats = getUserStats(user);
        
        // Map earned badges
        const earnedBadges = user.badges.map(b => ({
            id: b.badgeId._id,
            name: b.badgeId.name,
            description: b.badgeId.description,
            iconUrl: b.badgeId.iconUrl,
            category: b.badgeId.category,
            earnedAt: b.earnedAt,
            earned: true
        }));
        
        // Get earned badge IDs
        const earnedBadgeIds = earnedBadges.map(b => b.id.toString());
        
        // Map unearned badges with progress
        const unearnedBadges = allBadges
            .filter(badge => !earnedBadgeIds.includes(badge._id.toString()))
            .map(badge => {
                const progress = calculateBadgeProgress(badge, userStats);
                return {
                    id: badge._id,
                    name: badge.name,
                    description: badge.description,
                    iconUrl: badge.iconUrl,
                    category: badge.category,
                    earned: false,
                    progress
                };
            });
        
        return {
            success: true,
            earnedBadges,
            unearnedBadges,
            totalEarned: earnedBadges.length,
            totalAvailable: allBadges.length,
            completionPercentage: Math.round((earnedBadges.length / allBadges.length) * 100)
        };
        
    } catch (error) {
        console.error('Error in getUserBadges:', error);
        throw error;
    }
};

/**
 * Tính toán tiến độ đạt được badge
 * @param {Object} badge - Badge object
 * @param {Object} userStats - User statistics
 * @returns {Object} - Progress information
 */
const calculateBadgeProgress = (badge, userStats) => {
    const { type, target } = badge.criteria;
    let current = 0;
    let label = '';
    
    switch (type) {
        case 'xp':
            current = userStats.xp;
            label = 'XP';
            break;
        case 'words_learned':
            current = userStats.totalWordsLearned;
            label = 'từ vựng';
            break;
        case 'streak':
            current = userStats.streak;
            label = 'ngày';
            break;
        case 'lessons_completed':
            current = userStats.lessonsCompleted;
            label = 'bài học';
            break;
        case 'perfect_scores':
            current = userStats.perfectScores;
            label = 'điểm hoàn hảo';
            break;
        case 'daily_goal':
            current = userStats.dailyGoalStreak;
            label = 'ngày đạt mục tiêu';
            break;
        case 'level':
            current = userStats.level;
            label = 'cấp độ';
            break;
        default:
            current = 0;
            label = '';
    }
    
    const percentage = Math.min(Math.round((current / target) * 100), 100);
    
    return {
        current,
        target,
        percentage,
        label,
        remaining: Math.max(target - current, 0)
    };
};

/**
 * Lấy danh sách tất cả badges (admin)
 * @returns {Array} - Tất cả badges
 */
const getAllBadges = async () => {
    try {
        return await Badge.find().sort({ displayOrder: 1, 'criteria.target': 1 });
    } catch (error) {
        console.error('Error in getAllBadges:', error);
        throw error;
    }
};

/**
 * Tạo badge mới (admin)
 * @param {Object} badgeData - Dữ liệu badge
 * @returns {Object} - Badge mới được tạo
 */
const createBadge = async (badgeData) => {
    try {
        const badge = new Badge(badgeData);
        await badge.save();
        
        return {
            success: true,
            badge
        };
    } catch (error) {
        console.error('Error in createBadge:', error);
        throw error;
    }
};

/**
 * Cập nhật badge (admin)
 * @param {String} badgeId - ID của badge
 * @param {Object} updateData - Dữ liệu cập nhật
 * @returns {Object} - Badge đã cập nhật
 */
const updateBadge = async (badgeId, updateData) => {
    try {
        const badge = await Badge.findByIdAndUpdate(
            badgeId,
            updateData,
            { new: true, runValidators: true }
        );
        
        if (!badge) {
            throw new Error('Badge not found');
        }
        
        return {
            success: true,
            badge
        };
    } catch (error) {
        console.error('Error in updateBadge:', error);
        throw error;
    }
};

/**
 * Xóa badge (admin)
 * @param {String} badgeId - ID của badge
 * @returns {Object} - Kết quả xóa
 */
const deleteBadge = async (badgeId) => {
    try {
        const badge = await Badge.findByIdAndDelete(badgeId);
        
        if (!badge) {
            throw new Error('Badge not found');
        }
        
        // Optional: Remove this badge from all users
        await User.updateMany(
            { 'badges.badgeId': badgeId },
            { $pull: { badges: { badgeId } } }
        );
        
        return {
            success: true,
            message: 'Badge deleted successfully'
        };
    } catch (error) {
        console.error('Error in deleteBadge:', error);
        throw error;
    }
};

module.exports = {
    checkAndAwardBadges,
    getUserBadges,
    getAllBadges,
    createBadge,
    updateBadge,
    deleteBadge,
    calculateBadgeProgress,
    getUserStats
};
