const badgeService = require('../services/badgeService');

/**
 * Badge Controller
 * Xử lý các HTTP requests liên quan đến badges
 */

/**
 * @route   GET /api/badges
 * @desc    Get all available badges
 * @access  Public
 */
const getAllBadges = async (req, res) => {
    try {
        const badges = await badgeService.getAllBadges();
        
        res.status(200).json({
            success: true,
            count: badges.length,
            data: badges
        });
    } catch (error) {
        console.error('Error in getAllBadges controller:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching badges',
            error: error.message
        });
    }
};

/**
 * @route   GET /api/badges/user/:userId
 * @desc    Get user's badges with progress
 * @access  Private
 */
const getUserBadges = async (req, res) => {
    try {
        const userId = req.params.userId || req.user.id;
        
        // Verify user can only access their own badges
        if (req.user.id !== userId && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized to access this user\'s badges'
            });
        }
        
        const result = await badgeService.getUserBadges(userId);
        
        res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('Error in getUserBadges controller:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching user badges',
            error: error.message
        });
    }
};

/**
 * @route   GET /api/badges/me
 * @desc    Get current user's badges
 * @access  Private
 */
const getMyBadges = async (req, res) => {
    try {
        const result = await badgeService.getUserBadges(req.user.id);
        
        res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('Error in getMyBadges controller:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching your badges',
            error: error.message
        });
    }
};

/**
 * @route   POST /api/badges/check/:userId
 * @desc    Manually check and award badges for a user
 * @access  Private (Admin only)
 */
const manualCheckBadges = async (req, res) => {
    try {
        const userId = req.params.userId || req.user.id;
        const { activityType } = req.body;
        
        const result = await badgeService.checkAndAwardBadges(userId, activityType);
        
        res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('Error in manualCheckBadges controller:', error);
        res.status(500).json({
            success: false,
            message: 'Error checking badges',
            error: error.message
        });
    }
};

/**
 * @route   POST /api/badges
 * @desc    Create a new badge (Admin only)
 * @access  Private/Admin
 */
const createBadge = async (req, res) => {
    try {
        const result = await badgeService.createBadge(req.body);
        
        res.status(201).json({
            success: true,
            message: 'Badge created successfully',
            data: result.badge
        });
    } catch (error) {
        console.error('Error in createBadge controller:', error);
        res.status(500).json({
            success: false,
            message: 'Error creating badge',
            error: error.message
        });
    }
};

/**
 * @route   PUT /api/badges/:badgeId
 * @desc    Update a badge (Admin only)
 * @access  Private/Admin
 */
const updateBadge = async (req, res) => {
    try {
        const { badgeId } = req.params;
        const result = await badgeService.updateBadge(badgeId, req.body);
        
        res.status(200).json({
            success: true,
            message: 'Badge updated successfully',
            data: result.badge
        });
    } catch (error) {
        console.error('Error in updateBadge controller:', error);
        res.status(500).json({
            success: false,
            message: 'Error updating badge',
            error: error.message
        });
    }
};

/**
 * @route   DELETE /api/badges/:badgeId
 * @desc    Delete a badge (Admin only)
 * @access  Private/Admin
 */
const deleteBadge = async (req, res) => {
    try {
        const { badgeId } = req.params;
        const result = await badgeService.deleteBadge(badgeId);
        
        res.status(200).json({
            success: true,
            message: result.message
        });
    } catch (error) {
        console.error('Error in deleteBadge controller:', error);
        res.status(500).json({
            success: false,
            message: 'Error deleting badge',
            error: error.message
        });
    }
};

module.exports = {
    getAllBadges,
    getUserBadges,
    getMyBadges,
    manualCheckBadges,
    createBadge,
    updateBadge,
    deleteBadge
};
