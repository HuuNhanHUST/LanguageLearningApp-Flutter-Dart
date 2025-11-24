const Word = require('../models/Word');
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

const formatWordForUser = (wordDoc, userId) => {
  const wordObj = wordDoc.toObject();
  const userObjectId = userId.toString();
  wordObj.isMemorized = wordDoc.memorizedBy?.some(
    (id) => id.toString() === userObjectId,
  );
  delete wordObj.memorizedBy;
  delete wordObj.owners;
  delete wordObj.normalizedWord;
  return wordObj;
};

/**
 * @desc    Lookup a word via Gemini and store if new
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

    let existingWord = await Word.findOne(
      buildWordLookupQuery(term, normalizedTerm),
    );

    if (existingWord) {
      const alreadyOwned = existingWord.owners?.some((id) =>
        id.toString() === req.user._id.toString()
      );

      if (!alreadyOwned) {
        existingWord.owners = existingWord.owners || [];
        existingWord.owners.push(req.user._id);
        await existingWord.save();
      }

      return res.status(200).json({
        success: true,
        message: alreadyOwned
          ? 'Word already exists in your vocabulary list'
          : 'Word added to your vocabulary list',
        data: {
          word: formatWordForUser(existingWord, req.user._id),
          source: 'database',
        },
      });
    }

    const geminiData = await geminiService.fetchWordData(term);

    if (!geminiData.meaning) {
      return res.status(502).json({
        success: false,
        message: 'Gemini could not provide a definition. Please try another word.',
      });
    }

    const newWord = await Word.create({
      ...geminiData,
      word: geminiData.word || term,
      topic: geminiData.topic || 'General',
      example: geminiData.example || '',
      owners: [req.user._id],
      memorizedBy: [],
    });

    res.status(201).json({
        success: true,
        message: 'Word fetched from Gemini successfully',
        data: {
          word: formatWordForUser(newWord, req.user._id),
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

    const normalizedWord = word.trim().toLowerCase();

    let existingWord = await Word.findOne(
      buildWordLookupQuery(word, normalizedWord),
    );

    if (existingWord) {
      const alreadyOwned = existingWord.owners?.some((id) =>
        id.toString() === req.user._id.toString()
      );

      if (alreadyOwned) {
        return res.status(400).json({
          success: false,
          message: 'Word already exists in your vocabulary list',
        });
      }

      existingWord.owners = existingWord.owners || [];
      existingWord.owners.push(req.user._id);
      await existingWord.save();

      return res.status(200).json({
        success: true,
        message: 'Word added to your vocabulary list',
        data: {
          word: formatWordForUser(existingWord, req.user._id),
        },
      });
    }

    // Create new word definition
    const newWord = new Word({
      word: word.trim(),
      meaning: meaning.trim(),
      type: type || 'other',
      example: example?.trim(),
      topic: topic?.trim() || 'General',
      owners: [req.user._id],
      memorizedBy: [],
    });

    await newWord.save();

    res.status(201).json({
        success: true,
        message: 'Word created successfully',
        data: {
          word: formatWordForUser(newWord, req.user._id),
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
    const filter = { owners: req.user._id };

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
    const formattedWords = words.map((word) => formatWordForUser(word, req.user._id));

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
    const word = await Word.findOne({
      _id: req.params.id,
      owners: req.user._id,
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
          word: formatWordForUser(word, req.user._id),
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
      owners: req.user._id,
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
    if (isMemorized !== undefined) {
      existingWord.memorizedBy = existingWord.memorizedBy || [];
      const userIdStr = req.user._id.toString();
      const isAlreadyMemorized = existingWord.memorizedBy.some(
        (id) => id.toString() === userIdStr,
      );
      if (isMemorized && !isAlreadyMemorized) {
        existingWord.memorizedBy.push(req.user._id);
      } else if (!isMemorized && isAlreadyMemorized) {
        existingWord.memorizedBy = existingWord.memorizedBy.filter(
          (id) => id.toString() !== userIdStr,
        );
      }
    }

    await existingWord.save();

    res.status(200).json({
      success: true,
      message: 'Word updated successfully',
      data: {
        word: formatWordForUser(existingWord, req.user._id),
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
    const word = await Word.findOne({
      _id: req.params.id,
      owners: req.user._id,
    });

    if (!word) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    word.owners = (word.owners || []).filter(
      (id) => id.toString() !== req.user._id.toString(),
    );

    word.memorizedBy = (word.memorizedBy || []).filter(
      (id) => id.toString() !== req.user._id.toString(),
    );

    if (!word.owners.length) {
      await word.deleteOne();
    } else {
      await word.save();
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
      owners: req.user._id,
    });

    if (!word) {
      return res.status(404).json({
        success: false,
        message: 'Word not found',
      });
    }

    word.memorizedBy = word.memorizedBy || [];
    const userIdStr = req.user._id.toString();
    const currentlyMemorized = word.memorizedBy.some(
      (id) => id.toString() === userIdStr,
    );

    if (currentlyMemorized) {
      word.memorizedBy = word.memorizedBy.filter(
        (id) => id.toString() !== userIdStr,
      );
    } else {
      word.memorizedBy.push(req.user._id);
    }

    await word.save();

    const updatedMemorized = !currentlyMemorized;

    res.status(200).json({
      success: true,
      message: `Word marked as ${updatedMemorized ? 'memorized' : 'not memorized'}`,
      data: {
        word: formatWordForUser(word, req.user._id),
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
