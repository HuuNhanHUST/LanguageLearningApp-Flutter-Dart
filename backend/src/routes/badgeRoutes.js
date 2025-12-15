const express = require('express');
const router = express.Router();
const badgeController = require('../controllers/badgeController');
const { auth } = require('../middleware/auth');

/**
 * Badge Routes
 * All badge-related endpoints
 */

// Public routes
/**
 * @route   GET /api/badges
 * @desc    Get all available badges
 * @access  Public
 */
router.get('/', badgeController.getAllBadges);

// Protected routes (require authentication)
/**
 * @route   GET /api/badges/me
 * @desc    Get current user's badges with progress
 * @access  Private
 */
router.get('/me', auth, badgeController.getMyBadges);

/**
 * @route   GET /api/badges/user/:userId
 * @desc    Get specific user's badges
 * @access  Private
 */
router.get('/user/:userId', auth, badgeController.getUserBadges);

/**
 * @route   POST /api/badges/check
 * @desc    Check and award badges for current user
 * @access  Private
 */
router.post('/check', auth, badgeController.manualCheckBadges);

// Admin routes (require admin role)
// Note: Add admin middleware when you have role-based access control

/**
 * @route   POST /api/badges
 * @desc    Create a new badge (Admin only)
 * @access  Private/Admin
 */
router.post('/', auth, badgeController.createBadge);

/**
 * @route   PUT /api/badges/:badgeId
 * @desc    Update a badge (Admin only)
 * @access  Private/Admin
 */
router.put('/:badgeId', auth, badgeController.updateBadge);

/**
 * @route   DELETE /api/badges/:badgeId
 * @desc    Delete a badge (Admin only)
 * @access  Private/Admin
 */
router.delete('/:badgeId', auth, badgeController.deleteBadge);

module.exports = router;
