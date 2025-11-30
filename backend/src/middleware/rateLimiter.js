const rateLimit = require('express-rate-limit');

// Rate Limiter cho endpoint upload audio
const uploadAudioLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 phút
  max: 10, // Tối đa 10 request
  message: 'Quá nhiều request từ IP này, vui lòng thử lại sau 1 phút',
  standardHeaders: true, // Trả về thông tin rate limit trong `RateLimit-*` headers
  legacyHeaders: false, // Tắt `X-RateLimit-*` headers
  skip: (req) => {
    // Có thể bỏ qua rate limiter nếu cần (ví dụ cho admin)
    return false;
  },
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Quá nhiều request từ IP này. Vui lòng thử lại sau 1 phút.',
      retryAfter: req.rateLimit.resetTime,
    });
  },
});

module.exports = {
  uploadAudioLimiter,
};
