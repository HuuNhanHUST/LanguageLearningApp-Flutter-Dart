const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const {
  markWordLearned,
  getProgress,
  getLearnedWords,
} = require('../controllers/learningController');

// All routes require authentication
router.use(auth);

// @route   POST /api/learning/word-learned
// @desc    Mark a word as learned and earn XP
// @access  Private
router.post('/word-learned', markWordLearned);

// @route   GET /api/learning/progress
// @desc    Get learning progress (XP, level, words learned, streak)
// @access  Private
router.get('/progress', getProgress);

// @route   GET /api/learning/learned-words
// @desc    Get list of learned word IDs
// @access  Private
router.get('/learned-words', getLearnedWords);

module.exports = router;
