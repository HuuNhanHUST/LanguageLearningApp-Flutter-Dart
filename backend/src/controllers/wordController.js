const Word = require('../models/Word');
const UserWord = require('../models/UserWord');
const { validationResult } = require('express-validator');
const geminiService = require('../services/geminiService');

const escapeRegex = (value = '') => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const buildWordLookupQuery = (term, normalizedTerm) => ({
  $or: [
    { normalizedWord: normalizedTerm },
    {
      normalizedWord: { $exists: false },
      word: { $regex: new RegExp(`^${escapeRegex(term)}$`, 'i') },
    },
  ],
});

/**
 * Format word with user's learning data
 */
const formatWordWithUserData = async (wordDoc, userId) => {
  const wordObj = wordDoc.toObject();
  
  // Get user's learning data for this word
  const userWord = await UserWord.findOne({
    userId: userId,
    wordId: wordDoc._id,
  });
  
  if (userWord) {
    wordObj.isMemorized = userWord.isMemorized;
    wordObj.addedAt = userWord.addedAt;
    wordObj.reviewCount = userWord.reviewCount;
    wordObj.accuracyRate = userWord.accuracyRate;
    wordObj.nextReviewDate = userWord.nextReviewDate;
    wordObj.personalNote = userWord.personalNote;
    wordObj.personalExample = userWord.personalExample;
  } else {
    wordObj.isMemorized = false;
  }
  
  return wordObj;
};

/**
 * @desc    Lookup a word via Gemini or dictionary and add to user's vocabulary
 * @route   POST /api/words/lookup
 * @access  Private
 */
exports.lookupWord = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const term = req.body.word.trim();
    const normalizedTerm = term.toLowerCase();

    // 1. Check if word exists in dictionary
    let wordDefinition = await Word.findOne(
      buildWordLookupQuery(term, normalizedTerm),
    );

    // 2. If exists, check if user already has it
    if (wordDefinition) {
      let userWord = await UserWord.findOne({
        userId: req.user._id,
        wordId: wordDefinition._id,
      });

      if (userWord) {
        // User already has this word
        const response = await formatWordWithUserData(wordDefinition, req.user._id);
        return res.status(200).json({
          success: true,
          message: 'Word already exists in your vocabulary list',
          data: {
            word: response,
            source: 'existing',
          },
        });
      }

      // Add word to user's vocabulary
      userWord = await UserWord.create({
        userId: req.user._id,
        wordId: wordDefinition._id,
        source: 'lookup',
        nextReviewDate: new Date(Date.now() + 24 * 60 * 60 * 1000), // Tomorrow
      });

      // Update word's total learners
      await Word.findByIdAndUpdate(wordDefinition._id, {
        $inc: { totalLearners: 1 },
      });

      const response = await formatWordWithUserData(wordDefinition, req.user._id);
      return res.status(200).json({
        success: true,
        message: 'Word added to your vocabulary list',
        data: {
          word: response,
          source: 'dictionary',
        },
      });
    }

    // 3. Word not in dictionary - fetch from Gemini
    const geminiData = await geminiService.fetchWordData(term);

    if (!geminiData.meaning) {
      return res.status(502).json({
        success: false,
        message: 'Gemini could not provide a definition. Please try another word.',
      });
    }

    // 4. Create new word in dictionary
    wordDefinition = await Word.create({
      ...geminiData,
      word: geminiData.word || term,
      topic: geminiData.topic || 'General',
      example: geminiData.example || '',
      totalLearners: 1,
    });

    // 5. Add to user's vocabulary
    await UserWord.create({
      userId: req.user._id,
      wordId: wordDefinition._id,
      source: 'lookup',
      nextReviewDate: new Date(Date.now() + 24 * 60 * 60 * 1000),
    });

    const response = await formatWordWithUserData(wordDefinition, req.user._id);
    res.status(201).json({
      success: true,
      message: 'Word fetched from Gemini successfully',
      data: {
        word: response,
        source: 'gemini',
      },
    });
  } catch (error) {
    console.error('Lookup word error:', error);
    const status = error.message?.includes('Gemini') ? 502 : 500;
    res.status(status).json({
      success: false,
      message: error.message || 'Server error while looking up word',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    });
  }
};

/**
 * @desc    Create a new word manually
 * @route   POST /api/words/create
 * @access  Private (requires authentication)
 */
exports.createWord = async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const { word, meaning, type, example, topic } = req.body;
    const normalizedWord = word.trim().toLowerCase();

    // 1. Check if word exists in dictionary
    let wordDefinition = await Word.findOne(
      buildWordLookupQuery(word, normalizedWord),
    );

    if (wordDefinition) {
      // Word exists, check if user has it
      const userWord = await UserWord.findOne({
        userId: req.user._id,
        wordId: wordDefinition._id,
      });

      if (userWord) {
        return res.status(400).json({
          success: false,
          message: 'Word already exists in your vocabulary list',
        });
      }

      // Add to user's vocabulary
      await UserWord.create({
        userId: req.user._id,
        wordId: wordDefinition._id,
        source: 'manual',
        nextReviewDate: new Date(Date.now() + 24 * 60 * 60 * 1000),
      });

      await Word.findByIdAndUpdate(wordDefinition._id, {
        $inc: { totalLearners: 1 },
      });

      const response = await formatWordWithUserData(wordDefinition, req.user._id);
      return res.status(200).json({
        success: true,
        message: 'Word added to your vocabulary list',
        data: {
          word: response,
        },
      });
    }

    // 2. Create new word in dictionary
    wordDefinition = await Word.create({
      word: word.trim(),
      meaning: meaning.trim(),
      type: type || 'other',
      example: example?.trim(),
      topic: topic?.trim() || 'General',
      totalLearners: 1,
    });

    // 3. Add to user's vocabulary
    await UserWord.create({
      userId: req.user._id,
      wordId: wordDefinition._id,
      source: 'manual',
      nextReviewDate: new Date(Date.now() + 24 * 60 * 60 * 1000),
    });

    const response = await formatWordWithUserData(wordDefinition, req.user._id);
    res.status(201).json({
      success: true,
      message: 'Word created successfully',
      data: {
        word: response,
      },
    });
  } catch (error) {
    console.error('Create word error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating word',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * @desc    Get all words for the current user
 * @route   GET /api/words
 * @access  Private
 */
exports.getWords = async (req, res) => {
  try {
    const { topic, isMemorized, type, limit = 100 } = req.query;

    // Build filter for UserWord
    const userWordFilter = { userId: req.user._id };
    if (isMemorized !== undefined) {
      userWordFilter.isMemorized = isMemorized === 'true';
    }

    // Get user's words
    const userWords = await UserWord.find(userWordFilter)
      .populate('wordId')
      .sort({ addedAt: -1 })
      .limit(parseInt(limit));

    // Filter by word properties if needed
    let filteredWords = userWords;
    if (topic || type) {
      filteredWords = userWords.filter((uw) => {
        if (!uw.wordId) return false;
        if (topic && uw.wordId.topic !== topic) return false;
        if (type && uw.wordId.type !== type) return false;
        return true;
      });
    }

    // Format response
    const formattedWords = filteredWords.map((uw) => {
      if (!uw.wordId) return null;
      
      const wordObj = uw.wordId.toObject();
      wordObj.isMemorized = uw.isMemorized;
      wordObj.addedAt = uw.addedAt;
      wordObj.reviewCount = uw.reviewCount;
      wordObj.accuracyRate = uw.accuracyRate;
      wordObj.nextReviewDate = uw.nextReviewDate;
      wordObj.personalNote = uw.personalNote;
      wordObj.personalExample = uw.personalExample;
      
      return wordObj;
    }).filter(Boolean);

    res.status(200).json({
      success: true,
      message: 'Words retrieved successfully',
      data: {
        words: formattedWords,
        count: formattedWords.length,
      },
    });
  } catch (error) {
    console.error('Get words error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while retrieving words',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * @desc    Get a single word by ID
 * @route   GET /api/words/:id
 * @access  Private
 */
exports.getWordById = async (req, res) => {
  try {
    // Find word in dictionary
    const wordDefinition = await Word.findById(req.params.id);

    if (!wordDefinition) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    // Check if user has this word
    const userWord = await UserWord.findOne({
      userId: req.user._id,
      wordId: wordDefinition._id,
    });

    if (!userWord) {
      return res.status(404).json({
        success: false,
        message: 'Word not found in your vocabulary',
      });
    }

    const response = await formatWordWithUserData(wordDefinition, req.user._id);
    res.status(200).json({
      success: true,
      message: 'Word retrieved successfully',
      data: {
        word: response,
      },
    });
  } catch (error) {
    console.error('Get word by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while retrieving word',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * @desc    Update a word (user's personal data or word definition)
 * @route   PUT /api/words/:id
 * @access  Private
 */
exports.updateWord = async (req, res) => {
  try {
    const { word, meaning, type, example, topic, isMemorized, personalNote, personalExample } = req.body;

    const wordDefinition = await Word.findById(req.params.id);
    if (!wordDefinition) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    const userWord = await UserWord.findOne({
      userId: req.user._id,
      wordId: wordDefinition._id,
    });

    if (!userWord) {
      return res.status(404).json({
        success: false,
        message: 'Word not found in your vocabulary',
      });
    }

    // Update word definition (if provided)
    if (word !== undefined) wordDefinition.word = word.trim();
    if (meaning !== undefined) wordDefinition.meaning = meaning.trim();
    if (type !== undefined) wordDefinition.type = type;
    if (example !== undefined) wordDefinition.example = example.trim();
    if (topic !== undefined) wordDefinition.topic = topic.trim();

    // Update user's personal data
    if (isMemorized !== undefined) {
      userWord.isMemorized = isMemorized;
      if (isMemorized) {
        userWord.memorizedAt = new Date();
      } else {
        userWord.memorizedAt = null;
      }
    }
    if (personalNote !== undefined) userWord.personalNote = personalNote;
    if (personalExample !== undefined) userWord.personalExample = personalExample;

    await wordDefinition.save();
    await userWord.save();

    const response = await formatWordWithUserData(wordDefinition, req.user._id);
    res.status(200).json({
      success: true,
      message: 'Word updated successfully',
      data: {
        word: response,
      },
    });
  } catch (error) {
    console.error('Update word error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating word',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * @desc    Delete a word from user's vocabulary
 * @route   DELETE /api/words/:id
 * @access  Private
 */
exports.deleteWord = async (req, res) => {
  try {
    const wordDefinition = await Word.findById(req.params.id);
    
    if (!wordDefinition) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    const userWord = await UserWord.findOne({
      userId: req.user._id,
      wordId: wordDefinition._id,
    });

    if (!userWord) {
      return res.status(404).json({
        success: false,
        message: 'Word not found in your vocabulary',
      });
    }

    // Remove from user's vocabulary
    await userWord.deleteOne();

    // Decrement total learners count
    await Word.findByIdAndUpdate(wordDefinition._id, {
      $inc: { totalLearners: -1 },
    });

    res.status(200).json({
      success: true,
      message: 'Word deleted successfully',
    });
  } catch (error) {
    console.error('Delete word error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting word',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * @desc    Toggle word memorized status
 * @route   PATCH /api/words/:id/memorize
 * @access  Private
 */
exports.toggleMemorized = async (req, res) => {
  try {
    const wordDefinition = await Word.findById(req.params.id);

    if (!wordDefinition) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    const userWord = await UserWord.findOne({
      userId: req.user._id,
      wordId: wordDefinition._id,
    });

    if (!userWord) {
      return res.status(404).json({
        success: false,
        message: 'Word not found in your vocabulary',
      });
    }

    // Toggle memorized status
    await userWord.toggleMemorized();

    const response = await formatWordWithUserData(wordDefinition, req.user._id);
    res.status(200).json({
      success: true,
      message: `Word marked as ${userWord.isMemorized ? 'memorized' : 'not memorized'}`,
      data: {
        word: response,
      },
    });
  } catch (error) {
    console.error('Toggle memorized error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating word status',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * @desc    Get user's vocabulary statistics
 * @route   GET /api/words/stats
 * @access  Private
 */
exports.getUserStats = async (req, res) => {
  try {
    const stats = await UserWord.getUserStats(req.user._id);
    
    res.status(200).json({
      success: true,
      message: 'Statistics retrieved successfully',
      data: stats,
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while retrieving statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * @desc    Get words due for review
 * @route   GET /api/words/due
 * @access  Private
 */
exports.getDueWords = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const dueWords = await UserWord.getDueWords(req.user._id, limit);
    
    const formattedWords = dueWords.map((uw) => {
      if (!uw.wordId) return null;
      
      const wordObj = uw.wordId.toObject();
      wordObj.isMemorized = uw.isMemorized;
      wordObj.addedAt = uw.addedAt;
      wordObj.reviewCount = uw.reviewCount;
      wordObj.accuracyRate = uw.accuracyRate;
      wordObj.nextReviewDate = uw.nextReviewDate;
      
      return wordObj;
    }).filter(Boolean);

    res.status(200).json({
      success: true,
      message: 'Due words retrieved successfully',
      data: {
        words: formattedWords,
        count: formattedWords.length,
      },
    });
  } catch (error) {
    console.error('Get due words error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while retrieving due words',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};
