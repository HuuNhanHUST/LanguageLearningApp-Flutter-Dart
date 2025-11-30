const express = require('express');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const aiController = require('../controllers/aiController');

const router = express.Router();

router.post(
  '/stt',
  auth,
  upload.single('audio'),
  aiController.transcribeAudio,
);

module.exports = router;
