const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { auth } = require('../middleware/auth');

/**
 * @route   POST /api/chat
 * @desc    Chat with AI Tutor
 * @access  Private
 */
router.post('/', auth, (req, res) => chatController.chat(req, res));

/**
 * @route   POST /api/chat/translate
 * @desc    Translate text to Vietnamese
 * @access  Private
 */
router.post('/translate', auth, (req, res) => chatController.translate(req, res));

module.exports = router;
