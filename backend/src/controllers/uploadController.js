// Upload controller
const uploadAudio = async (req, res) => {
  try {
    // Kiểm tra xem file đã được upload chưa
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Không có file audio được upload',
      });
    }

    // Kiểm tra loại file
    const allowedMimeTypes = [
      'audio/wav',
      'audio/x-wav',
      'audio/mpeg',
      'audio/mp3',
      'audio/webm',
      'audio/ogg',
      'audio/m4a',
      'audio/x-m4a',
      'audio/aac',
    ];
    if (!allowedMimeTypes.includes(req.file.mimetype)) {
      return res.status(400).json({
        success: false,
        message: 'Loại file không được hỗ trợ. Chỉ chấp nhận: mp3, wav, ogg, m4a',
      });
    }

    // Kiểm tra kích thước file (tối đa 10MB)
    const maxFileSize = 15 * 1024 * 1024; // 15MB
    if (req.file.size > maxFileSize) {
      return res.status(400).json({
        success: false,
        message: 'Kích thước file vượt quá giới hạn (10MB)',
      });
    }

    // Trả về thông tin file đã upload
    const relativePath = `/uploads/audio/${req.file.filename}`;
    const baseUrl = process.env.BACKEND_PUBLIC_URL || `${req.protocol}://${req.get('host')}`;

    res.status(200).json({
      success: true,
      message: 'File audio được upload thành công',
      data: {
        filename: req.file.filename,
        originalName: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size,
        path: relativePath,
        url: `${baseUrl}${relativePath}`,
      },
    });
  } catch (error) {
    console.error('Error uploading audio:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi upload file audio',
      error: error.message,
    });
  }
};

module.exports = {
  uploadAudio,
};
