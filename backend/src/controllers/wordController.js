const Word = require('../models/Word');
const { validationResult } = require('express-validator');

/**
 * @desc    Create a new word
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

    // Check if word already exists for this user
    const existingWord = await Word.findOne({
      owner: req.user._id,
      word: word.trim(),
    });

    if (existingWord) {
      return res.status(400).json({
        success: false,
        message: 'Word already exists in your vocabulary list',
      });
    }

    // Create new word
    const newWord = new Word({
      word: word.trim(),
      meaning: meaning.trim(),
      type: type || 'other',
      example: example?.trim(),
      topic: topic?.trim() || 'General',
      owner: req.user._id,
      isMemorized: false,
    });

    await newWord.save();

    res.status(201).json({
      success: true,
      message: 'Word created successfully',
      data: {
        word: newWord,
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
    const { topic, isMemorized, type } = req.query;

    // Build filter query
    const filter = { owner: req.user._id };

    if (topic) {
      filter.topic = topic;
    }

    if (isMemorized !== undefined) {
      filter.isMemorized = isMemorized === 'true';
    }

    if (type) {
      filter.type = type;
    }

    const words = await Word.find(filter).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      message: 'Words retrieved successfully',
      data: {
        words,
        count: words.length,
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
    const word = await Word.findOne({
      _id: req.params.id,
      owner: req.user._id,
    });

    if (!word) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Word retrieved successfully',
      data: {
        word,
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
 * @desc    Update a word
 * @route   PUT /api/words/:id
 * @access  Private
 */
exports.updateWord = async (req, res) => {
  try {
    const { word, meaning, type, example, topic, isMemorized } = req.body;

    const existingWord = await Word.findOne({
      _id: req.params.id,
      owner: req.user._id,
    });

    if (!existingWord) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    // Update fields
    if (word !== undefined) existingWord.word = word.trim();
    if (meaning !== undefined) existingWord.meaning = meaning.trim();
    if (type !== undefined) existingWord.type = type;
    if (example !== undefined) existingWord.example = example.trim();
    if (topic !== undefined) existingWord.topic = topic.trim();
    if (isMemorized !== undefined) existingWord.isMemorized = isMemorized;

    await existingWord.save();

    res.status(200).json({
      success: true,
      message: 'Word updated successfully',
      data: {
        word: existingWord,
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
 * @desc    Delete a word
 * @route   DELETE /api/words/:id
 * @access  Private
 */
exports.deleteWord = async (req, res) => {
  try {
    const word = await Word.findOneAndDelete({
      _id: req.params.id,
      owner: req.user._id,
    });

    if (!word) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

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
    const word = await Word.findOne({
      _id: req.params.id,
      owner: req.user._id,
    });

    if (!word) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    word.isMemorized = !word.isMemorized;
    await word.save();

    res.status(200).json({
      success: true,
      message: `Word marked as ${word.isMemorized ? 'memorized' : 'not memorized'}`,
      data: {
        word,
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
