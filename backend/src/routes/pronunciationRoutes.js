const express = require('express');
const { auth } = require('../middleware/auth');
const pronunciationController = require('../controllers/pronunciationController');

const router = express.Router();

/**
 * @route   POST /api/pronunciation/compare
 * @desc    Compare pronunciation and get detailed analysis with score and word-by-word feedback
 * @access  Private (requires authentication)
 * @body    { target: string, transcript: string }
 * @returns { success, message, data: { score, accuracy, target, transcript, wordDetails, stats } }
 */
router.post('/compare', auth, pronunciationController.comparePronunciation);

/**
 * @route   POST /api/pronunciation/score
 * @desc    Calculate similarity score only (simplified endpoint)
 * @access  Private (requires authentication)
 * @body    { target: string, transcript: string }
 * @returns { success, message, data: { score, target, transcript } }
 */
router.post('/score', auth, pronunciationController.calculateScore);

/**
 * @route   POST /api/pronunciation/errors
 * @desc    Get word-by-word error highlights
 * @access  Private (requires authentication)
 * @body    { target: string, transcript: string }
 * @returns { success, message, data: { wordDetails, target, transcript } }
 */
router.post('/errors', auth, pronunciationController.highlightErrors);

module.exports = router;
