const pronunciationService = require('../services/pronunciationService');

/**
 * Compare pronunciation and return score with detailed feedback
 * @route POST /api/pronunciation/compare
 * @body { target: string, transcript: string }
 */
exports.comparePronunciation = async (req, res) => {
  try {
    const { target, transcript } = req.body;

    // Validation
    if (!target || typeof target !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Target text is required and must be a string',
      });
    }

    if (!transcript || typeof transcript !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Transcript text is required and must be a string',
      });
    }

    // Get pronunciation analysis
    const analysis = pronunciationService.analyzePronunciation(target, transcript);

    return res.status(200).json({
      success: true,
      message: 'Pronunciation analysis completed',
      data: {
        score: analysis.score,
        accuracy: analysis.accuracy,
        target: analysis.target,
        transcript: analysis.transcript,
        wordDetails: analysis.wordDetails,
        stats: analysis.stats,
      },
    });
  } catch (error) {
    console.error('Error in comparePronunciation:', error);
    
    return res.status(500).json({
      success: false,
      message: 'Failed to analyze pronunciation',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Calculate only the score (simplified endpoint)
 * @route POST /api/pronunciation/score
 * @body { target: string, transcript: string }
 */
exports.calculateScore = async (req, res) => {
  try {
    const { target, transcript } = req.body;

    // Validation
    if (!target || !transcript) {
      return res.status(400).json({
        success: false,
        message: 'Both target and transcript are required',
      });
    }

    const score = pronunciationService.calculateScore(target, transcript);

    return res.status(200).json({
      success: true,
      message: 'Score calculated successfully',
      data: {
        score,
        target: pronunciationService.normalizeText(target),
        transcript: pronunciationService.normalizeText(transcript),
      },
    });
  } catch (error) {
    console.error('Error in calculateScore:', error);
    
    return res.status(500).json({
      success: false,
      message: 'Failed to calculate score',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * Get word-by-word error highlights
 * @route POST /api/pronunciation/errors
 * @body { target: string, transcript: string }
 */
exports.highlightErrors = async (req, res) => {
  try {
    const { target, transcript } = req.body;

    // Validation
    if (!target || !transcript) {
      return res.status(400).json({
        success: false,
        message: 'Both target and transcript are required',
      });
    }

    const wordDetails = pronunciationService.highlightErrors(target, transcript);

    return res.status(200).json({
      success: true,
      message: 'Error highlighting completed',
      data: {
        wordDetails,
        target: pronunciationService.normalizeText(target),
        transcript: pronunciationService.normalizeText(transcript),
      },
    });
  } catch (error) {
    console.error('Error in highlightErrors:', error);
    
    return res.status(500).json({
      success: false,
      message: 'Failed to highlight errors',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};
