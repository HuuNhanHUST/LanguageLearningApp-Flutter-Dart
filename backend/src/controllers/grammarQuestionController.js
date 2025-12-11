const grammarQuestionService = require('../services/grammarQuestionService');

const parseBool = (value, fallback = true) => {
  if (value === undefined) return fallback;
  if (typeof value === 'boolean') return value;
  const normalized = String(value).toLowerCase();
  if (['false', '0', 'no'].includes(normalized)) return false;
  if (['true', '1', 'yes'].includes(normalized)) return true;
  return fallback;
};

exports.getQuestions = async (req, res) => {
  try {
    const { wordId, limit, difficulty = 'beginner', autoGenerate, lessonKey } = req.query;

    if (!wordId) {
      return res.status(400).json({
        success: false,
        message: 'wordId is required',
      });
    }

    const questions = await grammarQuestionService.getOrGenerate({
      wordId,
      desiredCount: limit ? Number(limit) : undefined,
      difficulty,
      lessonKey,
      autoGenerate: parseBool(autoGenerate, true),
    });

    res.status(200).json({
      success: true,
      data: {
        wordId,
        count: questions.length,
        questions,
      },
    });
  } catch (error) {
    console.error('Failed to load grammar questions:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Unable to fetch grammar questions',
    });
  }
};

exports.generateQuestions = async (req, res) => {
  try {
    const { wordId, count = 3, difficulty = 'beginner', lessonKey } = req.body;

    if (!wordId) {
      return res.status(400).json({
        success: false,
        message: 'wordId is required',
      });
    }

    const generated = await grammarQuestionService.generateQuestions({
      wordId,
      count: Number(count) || 3,
      difficulty,
      lessonKey,
    });

    res.status(201).json({
      success: true,
      message: generated.length
        ? 'Grammar questions generated successfully'
        : 'No new grammar questions were created',
      data: {
        wordId,
        count: generated.length,
        questions: generated,
      },
    });
  } catch (error) {
    console.error('Failed to generate grammar questions:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Unable to generate grammar questions',
    });
  }
};
