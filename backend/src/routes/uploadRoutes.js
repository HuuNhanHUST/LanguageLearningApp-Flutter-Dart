const express = require('express');
const multer = require('multer');
const { uploadAudioLimiter } = require('../middleware/rateLimiter');
const { uploadAudio } = require('../controllers/uploadController');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Multer setup - store files in backend/uploads/audio
const upload = multer({
	dest: 'uploads/audio/',
	limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
});

// Protected route with rate limiter and multer middleware
router.post('/audio', auth, uploadAudioLimiter, upload.single('audio'), uploadAudio);

module.exports = router;
