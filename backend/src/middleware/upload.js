const multer = require('multer');
const path = require('path');
const fs = require('fs');

const AUDIO_UPLOAD_DIR = path.join(__dirname, '../../uploads/audio');

if (!fs.existsSync(AUDIO_UPLOAD_DIR)) {
  fs.mkdirSync(AUDIO_UPLOAD_DIR, { recursive: true });
}

const sanitizeForFilename = (value = '') => value.replace(/[^a-zA-Z0-9_-]/g, '');

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, AUDIO_UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const rawUserId = req?.user?.id || req?.user?._id || 'anonymous';
    const safeUserId = sanitizeForFilename(String(rawUserId)) || 'anonymous';
    const ext = path.extname(file.originalname) || '.webm';
    cb(null, `${safeUserId}_${timestamp}${ext}`);
  },
});

const ALLOWED_MIME_TYPES = new Set([
  'audio/wav',
  'audio/x-wav',
  'audio/mpeg',
  'audio/mp3',
  'audio/webm',
  'audio/ogg',
  'audio/m4a',
  'audio/x-m4a',
  'audio/aac',
]);

const upload = multer({
  storage,
  limits: {
    fileSize: 15 * 1024 * 1024, // 15MB
  },
  fileFilter: (_req, file, cb) => {
    if (file?.mimetype && file.mimetype.startsWith('audio/')) {
      if (ALLOWED_MIME_TYPES.size === 0 || ALLOWED_MIME_TYPES.has(file.mimetype)) {
        return cb(null, true);
      }
    }

    cb(new Error('Only audio files are allowed.'));
  },
});

module.exports = upload;
