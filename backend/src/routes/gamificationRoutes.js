const express = require('express');
const { body } = require('express-validator');
const gamificationController = require('../controllers/gamificationController');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Public routes
router.get('/levels', gamificationController.getLevelRequirements);

// Protected routes (require authentication)
router.use(auth); // Apply auth middleware to all routes below

// Main endpoint - Cộng điểm khi hoàn thành bài học
router.post('/progress', [
    body('score')
        .isInt({ min: 0, max: 100 })
        .withMessage('Score must be between 0 and 100'),
    body('difficulty')
        .optional()
        .isIn(['easy', 'medium', 'hard'])
        .withMessage('Difficulty must be easy, medium, or hard'),
    body('activityType')
        .optional()
        .isString()
        .withMessage('Activity type must be a string')
], gamificationController.addProgress);

// Get gamification stats
router.get('/stats', gamificationController.getStats);

// Add XP directly (for testing or admin)
router.post('/add-xp', [
    body('amount')
        .isInt({ min: 1 })
        .withMessage('Amount must be a positive integer')
], gamificationController.addXP);

// Update streak
router.post('/update-streak', gamificationController.updateStreak);

module.exports = router;
