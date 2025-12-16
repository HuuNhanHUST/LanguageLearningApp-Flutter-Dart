const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const {
  markWordLearned,
  getProgress,
  getLearnedWords,
  getTodayProgress,
  addXpOnly,
} = require('../controllers/learningController');

// All routes require authentication
router.use(auth);

// @route   POST /api/learning/word-learned
// @desc    Mark a word as learned and earn XP
// @access  Private
router.post('/word-learned', markWordLearned);

// @route   POST /api/learning/xp-only
// @desc    Add XP for grammar practice (không đánh dấu từ là đã học)
// @access  Private
router.post('/xp-only', addXpOnly);

// @route   GET /api/learning/progress
// @desc    Get learning progress (XP, level, words learned, streak)
// @access  Private
router.get('/progress', getProgress);

// @route   GET /api/learning/learned-words
// @desc    Get list of learned word IDs
// @access  Private
router.get('/learned-words', getLearnedWords);

// @route   GET /api/learning/today-progress
// @desc    Get today's learning progress (words, pronunciation, XP, streak)
// @access  Private
router.get('/today-progress', getTodayProgress);

module.exports = router;
