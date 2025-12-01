const express = require('express');
const { uploadAudioLimiter } = require('../middleware/rateLimiter');
const { uploadAudio } = require('../controllers/uploadController');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// Protected route: auth -> rate limit -> multer(single file field "file")
router.post('/audio', auth, uploadAudioLimiter, upload.single('file'), uploadAudio);

module.exports = router;
