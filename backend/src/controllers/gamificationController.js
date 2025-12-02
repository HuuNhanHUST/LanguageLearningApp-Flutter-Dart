const gamificationService = require('../services/gamificationService');

/**
 * @desc    Cộng điểm cho người dùng khi hoàn thành bài học
 * @route   POST /api/gamification/progress
 * @access  Private
 */
exports.addProgress = async (req, res) => {
    try {
        const userId = req.user._id;
        const { score, difficulty, activityType } = req.body;
        
        // Validate input
        if (score === undefined || score === null) {
            return res.status(400).json({
                success: false,
                message: 'Score is required'
            });
        }
        
        if (score < 0 || score > 100) {
            return res.status(400).json({
                success: false,
                message: 'Score must be between 0 and 100'
            });
        }
        
        // Validate difficulty
        const validDifficulties = ['easy', 'medium', 'hard'];
        const lessonDifficulty = difficulty && validDifficulties.includes(difficulty) 
            ? difficulty 
            : 'medium';
        
        // Xử lý hoàn thành bài học
        const result = await gamificationService.completeLessonActivity(userId, {
            score,
            difficulty: lessonDifficulty,
            activityType: activityType || 'lesson'
        });
        
        // Tạo message phù hợp
        let message = 'Progress updated successfully';
        if (result.xp.leveledUp) {
            message = `Congratulations! You leveled up to level ${result.xp.level}! 🎉`;
        }
        
        res.status(200).json({
            success: true,
            message,
            data: {
                currentXP: result.xp.currentXP,
                xpGained: result.xp.xpGained,
                level: result.xp.level,
                leveledUp: result.xp.leveledUp,
                levelsGained: result.xp.levelsGained,
                xpForNextLevel: result.xp.xpForNextLevel,
                xpInCurrentLevel: result.xp.xpInCurrentLevel,
                xpNeededForNextLevel: result.xp.xpNeededForNextLevel,
                streak: result.streak.streak,
                streakMaintained: result.streak.streakMaintained,
                streakBroken: result.streak.streakBroken,
                score: result.score,
                activityType: result.activityType
            }
        });
        
    } catch (error) {
        console.error('Add progress error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update progress',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy thông tin gamification của user
 * @route   GET /api/gamification/stats
 * @access  Private
 */
exports.getStats = async (req, res) => {
    try {
        const userId = req.user._id;
        
        const stats = await gamificationService.getGamificationStats(userId);
        
        res.status(200).json({
            success: true,
            data: stats
        });
        
    } catch (error) {
        console.error('Get gamification stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to retrieve gamification stats',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Cộng XP trực tiếp cho user (cho testing hoặc admin)
 * @route   POST /api/gamification/add-xp
 * @access  Private
 */
exports.addXP = async (req, res) => {
    try {
        const userId = req.user._id;
        const { amount } = req.body;
        
        if (!amount || amount <= 0) {
            return res.status(400).json({
                success: false,
                message: 'Amount must be a positive number'
            });
        }
        
        const result = await gamificationService.addXP(userId, amount);
        
        let message = 'XP added successfully';
        if (result.leveledUp) {
            message = `XP added! You leveled up to level ${result.level}! 🎉`;
        }
        
        res.status(200).json({
            success: true,
            message,
            data: result
        });
        
    } catch (error) {
        console.error('Add XP error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to add XP',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Cập nhật streak của user
 * @route   POST /api/gamification/update-streak
 * @access  Private
 */
exports.updateStreak = async (req, res) => {
    try {
        const userId = req.user._id;
        
        const result = await gamificationService.updateStreak(userId);
        
        let message = 'Streak updated successfully';
        if (result.streakBroken) {
            message = 'Your streak was reset. Start a new streak today!';
        } else if (result.streak > 1) {
            message = `Great! You're on a ${result.streak}-day streak! 🔥`;
        }
        
        res.status(200).json({
            success: true,
            message,
            data: result
        });
        
    } catch (error) {
        console.error('Update streak error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update streak',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy danh sách level requirements
 * @route   GET /api/gamification/levels
 * @access  Public
 */
exports.getLevelRequirements = async (req, res) => {
    try {
        res.status(200).json({
            success: true,
            data: {
                levels: gamificationService.LEVEL_XP_REQUIREMENTS,
                maxLevel: 20
            }
        });
        
    } catch (error) {
        console.error('Get level requirements error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to retrieve level requirements',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// Không cần export lại vì đã sử dụng exports.functionName ở trên
