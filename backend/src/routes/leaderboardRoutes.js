const express = require('express');
const router = express.Router();
const leaderboardController = require('../controllers/leaderboardController');
const { auth } = require('../middleware/auth');

/**
 * @route   GET /api/leaderboard/top100
 * @desc    Get top 100 users by XP (Leaderboard)
 * @access  Private
 */
router.get('/top100', auth, leaderboardController.getTop100);

/**
 * @route   GET /api/leaderboard/my-rank
 * @desc    Get current user's rank in leaderboard
 * @access  Private
 */
router.get('/my-rank', auth, leaderboardController.getMyRank);

module.exports = router;
