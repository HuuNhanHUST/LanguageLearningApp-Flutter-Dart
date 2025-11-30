const fs = require('fs/promises');
const sttService = require('../services/sttService');

exports.transcribeAudio = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      message: 'Audio file is required. Use field name "audio".',
    });
  }

  try {
    const transcript = await sttService.transcribeAudio(req.file.path, {
      language: req.body.language,
    });

    return res.status(200).json({
      success: true,
      message: 'Transcription successful',
      data: {
        transcript: transcript?.trim() || '',
      },
    });
  } catch (error) {
    console.error('Transcription failed:', error.response?.data || error.message);

    const statusCode = error.response?.status || 500;
    const message = error.response?.data?.error?.message || error.message || 'Failed to transcribe audio';

    return res.status(statusCode >= 400 && statusCode < 600 ? statusCode : 500).json({
      success: false,
      message,
      ...(process.env.NODE_ENV === 'development' && {
        providerResponse: error.response?.data,
      }),
    });
  } finally {
    fs.unlink(req.file.path).catch(() => {});
  }
};
