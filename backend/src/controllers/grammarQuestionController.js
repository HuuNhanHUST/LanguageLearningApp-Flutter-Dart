const grammarQuestionService = require('../services/grammarQuestionService');
const GrammarQuestion = require('../models/GrammarQuestion');
const Class = require('../models/Class');
const Word = require('../models/Word');

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

/**
 * Get random grammar questions by difficulty (no wordId needed)
 * For grammar practice lesson
 */
exports.getRandomQuestions = async (req, res) => {
  try {
    const { difficulty = 'beginner', limit = 10 } = req.query;

    const questions = await grammarQuestionService.getRandomQuestionsByDifficulty({
      difficulty,
      limit: limit ? Number(limit) : 10,
    });

    res.status(200).json({
      success: true,
      data: {
        difficulty,
        count: questions.length,
        questions,
      },
    });
  } catch (error) {
    console.error('Failed to load random grammar questions:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Unable to fetch random grammar questions',
    });
  }
};

/**
 * @desc    Giáo viên tạo câu hỏi ngữ pháp cho lớp học
 * @route   POST /api/grammar/class-questions
 * @access  Private (Teacher)
 */
exports.createClassQuestion = async (req, res) => {
  try {
    const { wordId, word, question, options, correctIndex, explanation, difficulty, classId, isPublic } = req.body;
    
    // Validate required fields
    if (!question || !options || correctIndex === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Question, options, and correctIndex are required'
      });
    }
    
    // Validate options
    if (!Array.isArray(options) || options.length !== 4) {
      return res.status(400).json({
        success: false,
        message: 'Options must be an array of 4 choices'
      });
    }
    
    // Validate correctIndex
    if (correctIndex < 0 || correctIndex > 3) {
      return res.status(400).json({
        success: false,
        message: 'correctIndex must be between 0 and 3'
      });
    }
    
    // Nếu có classId, kiểm tra giáo viên có phải owner của lớp không
    if (classId) {
      const classData = await Class.findById(classId);
      if (!classData) {
        return res.status(404).json({
          success: false,
          message: 'Class not found'
        });
      }
      
      if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'You do not have permission to add questions to this class'
        });
      }
    }
    
    // Tìm hoặc tạo word nếu cần
    let wordData = null;
    if (wordId) {
      wordData = await Word.findById(wordId);
    } else if (word) {
      // Tìm word theo text
      wordData = await Word.findOne({ word: word.toLowerCase() });
    }
    
    const questionData = {
      wordId: wordData ? wordData._id : null,
      word: word || (wordData ? wordData.word : 'general'),
      question,
      options,
      correctIndex,
      explanation: explanation || '',
      difficulty: difficulty || 'beginner',
      createdBy: req.user._id,
      classId: classId || null,
      isPublic: isPublic !== undefined ? isPublic : !classId, // Mặc định public nếu không thuộc lớp
      targetSkill: 'grammar',
      source: 'teacher'
    };
    
    const newQuestion = await GrammarQuestion.create(questionData);
    
    res.status(201).json({
      success: true,
      message: 'Question created successfully',
      data: newQuestion
    });
    
  } catch (error) {
    console.error('Create class question error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create question',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * @desc    Lấy danh sách câu hỏi của lớp học
 * @route   GET /api/grammar/class/:classId
 * @access  Private (Teacher/Student của lớp)
 */
exports.getClassQuestions = async (req, res) => {
  try {
    const { classId } = req.params;
    
    // Kiểm tra quyền truy cập
    const classData = await Class.findById(classId);
    if (!classData) {
      return res.status(404).json({
        success: false,
        message: 'Class not found'
      });
    }
    
    const isTeacher = classData.teacher.equals(req.user._id);
    const isStudent = classData.students.includes(req.user._id);
    const isAdmin = req.user.role === 'admin';
    
    if (!isTeacher && !isStudent && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'You do not have access to this class'
      });
    }
    
    const questions = await GrammarQuestion.find({
      classId: classId,
      isPublic: false
    })
    .populate('createdBy', 'username firstName lastName')
    .sort({ createdAt: -1 });
    
    res.json({
      success: true,
      count: questions.length,
      data: questions
    });
    
  } catch (error) {
    console.error('Get class questions error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch questions',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * @desc    Cập nhật câu hỏi (chỉ giáo viên tạo mới được sửa)
 * @route   PUT /api/grammar/:questionId
 * @access  Private (Teacher - creator)
 */
exports.updateQuestion = async (req, res) => {
  try {
    const question = await GrammarQuestion.findById(req.params.questionId);
    
    if (!question) {
      return res.status(404).json({
        success: false,
        message: 'Question not found'
      });
    }
    
    // Kiểm tra quyền (chỉ giáo viên tạo câu hỏi mới được cập nhật)
    if (question.createdBy && !question.createdBy.equals(req.user._id) && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this question'
      });
    }
    
    const { word, question: questionText, options, correctIndex, explanation, difficulty, isPublic } = req.body;
    
    if (word) question.word = word;
    if (questionText) question.question = questionText;
    if (options) {
      if (!Array.isArray(options) || options.length !== 4) {
        return res.status(400).json({
          success: false,
          message: 'Options must be an array of 4 choices'
        });
      }
      question.options = options;
    }
    if (correctIndex !== undefined) {
      if (correctIndex < 0 || correctIndex > 3) {
        return res.status(400).json({
          success: false,
          message: 'correctIndex must be between 0 and 3'
        });
      }
      question.correctIndex = correctIndex;
    }
    if (explanation !== undefined) question.explanation = explanation;
    if (difficulty) question.difficulty = difficulty;
    if (isPublic !== undefined) question.isPublic = isPublic;
    
    await question.save();
    
    res.json({
      success: true,
      message: 'Question updated successfully',
      data: question
    });
    
  } catch (error) {
    console.error('Update question error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update question',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * @desc    Xóa câu hỏi
 * @route   DELETE /api/grammar/:questionId
 * @access  Private (Teacher - creator hoặc Admin)
 */
exports.deleteQuestion = async (req, res) => {
  try {
    const question = await GrammarQuestion.findById(req.params.questionId);
    
    if (!question) {
      return res.status(404).json({
        success: false,
        message: 'Question not found'
      });
    }
    
    // Kiểm tra quyền
    if (question.createdBy && !question.createdBy.equals(req.user._id) && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this question'
      });
    }
    
    await GrammarQuestion.findByIdAndDelete(req.params.questionId);
    
    res.json({
      success: true,
      message: 'Question deleted successfully'
    });
    
  } catch (error) {
    console.error('Delete question error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete question',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * @desc    Lấy danh sách câu hỏi mà giáo viên đã tạo
 * @route   GET /api/grammar/my-questions
 * @access  Private (Teacher)
 */
exports.getMyQuestions = async (req, res) => {
  try {
    const { classId, difficulty } = req.query;
    
    const filter = {
      createdBy: req.user._id
    };
    
    if (classId) {
      filter.classId = classId;
    }
    
    if (difficulty) {
      filter.difficulty = difficulty;
    }
    
    const questions = await GrammarQuestion.find(filter)
      .populate('classId', 'name classCode')
      .sort({ createdAt: -1 });
    
    res.json({
      success: true,
      count: questions.length,
      data: questions
    });
    
  } catch (error) {
    console.error('Get my questions error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch questions',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};
