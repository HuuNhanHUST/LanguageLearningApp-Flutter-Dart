const GrammarQuestion = require('../models/GrammarQuestion');
const Word = require('../models/Word');
const geminiService = require('./geminiService');

const DEFAULT_COUNT = 3;
const MAX_COUNT = 6;

const toLowerKey = (value = '') => value.trim().toLowerCase();

const clampCount = (count) => {
  if (!Number.isInteger(count)) return DEFAULT_COUNT;
  return Math.min(Math.max(count, 1), MAX_COUNT);
};

const formatQuestionPayload = (wordDoc, rawQuestion, lessonKey) => ({
  wordId: wordDoc._id,
  word: wordDoc.word,
  question: rawQuestion.question,
  options: rawQuestion.options,
  correctIndex: rawQuestion.correctIndex,
  explanation: rawQuestion.explanation,
  targetSkill: rawQuestion.targetSkill,
  difficulty: rawQuestion.difficulty,
  source: 'gemini',
  createdForLesson: lessonKey,
});

const grammarQuestionService = {
  async ensureWord(wordId) {
    const word = await Word.findById(wordId);
    if (!word) {
      throw new Error('Word not found');
    }
    return word;
  },

  async getCachedQuestions({ wordId, limit }) {
    const safeLimit = clampCount(limit || DEFAULT_COUNT);
    return GrammarQuestion.find({ wordId })
      .sort({ createdAt: -1 })
      .limit(safeLimit)
      .lean();
  },

  async generateQuestions({
    wordId,
    count,
    difficulty = 'beginner',
    lessonKey,
  }) {
    const safeCount = clampCount(count);
    const wordDoc = await this.ensureWord(wordId);

    const existing = await GrammarQuestion.find({ wordId })
      .sort({ createdAt: -1 })
      .lean();

    const existingTexts = new Set(existing.map((q) => toLowerKey(q.question)));

    const generated = await geminiService.generateGrammarQuestions(
      {
        word: wordDoc.word,
        meaning: wordDoc.meaning,
        type: wordDoc.type,
        example: wordDoc.example,
      },
      { count: safeCount, level: difficulty },
    );

    const uniquePayloads = generated
      .filter((item) => !existingTexts.has(toLowerKey(item.question)))
      .map((item) => formatQuestionPayload(wordDoc, item, lessonKey))
      .slice(0, safeCount);

    if (!uniquePayloads.length) {
      return [];
    }

    const saved = await GrammarQuestion.insertMany(uniquePayloads, {
      ordered: false,
    }).catch((error) => {
      // If duplicate errors occur, log and continue with already inserted docs
      console.error('Failed to insert some grammar questions:', error.message);
      return [];
    });

    // Ensure return value is plain array even when insertMany returns undefined due to errors
    const fresh = Array.isArray(saved) ? saved : [];
    return fresh.length
      ? fresh
      : GrammarQuestion.find({ wordId })
          .sort({ createdAt: -1 })
          .limit(safeCount)
          .lean();
  },

  async getOrGenerate({
    wordId,
    desiredCount = DEFAULT_COUNT,
    difficulty = 'beginner',
    lessonKey,
    autoGenerate = true,
  }) {
    const safeDesired = clampCount(desiredCount);
    let questions = await this.getCachedQuestions({ wordId, limit: safeDesired });

    if (questions.length >= safeDesired || !autoGenerate) {
      return questions;
    }

    await this.generateQuestions({
      wordId,
      count: safeDesired - questions.length,
      difficulty,
      lessonKey,
    });

    questions = await this.getCachedQuestions({ wordId, limit: safeDesired });
    return questions;
  },

  /**
   * Get random grammar questions by difficulty (for grammar practice lesson)
   * No wordId needed - gets questions from all words
   */
  async getRandomQuestionsByDifficulty({ difficulty = 'beginner', limit = 10 }) {
    const safeLimit = clampCount(limit);
    
    // Get random questions matching difficulty
    let questions = await GrammarQuestion.aggregate([
      { $match: { difficulty: difficulty } },
      { $sample: { size: safeLimit } },
    ]);

    console.log(`📚 Grammar questions - Requested: ${safeLimit} ${difficulty}, Found: ${questions.length}`);

    // If not enough questions, try to get from ANY difficulty
    if (questions.length < safeLimit) {
      console.log(`⚠️ Not enough ${difficulty} questions, fetching from all difficulties...`);
      
      const additionalNeeded = safeLimit - questions.length;
      const existingIds = questions.map(q => q._id.toString());
      
      // Get random questions from ANY difficulty (excluding already selected)
      const additionalQuestions = await GrammarQuestion.aggregate([
        { $match: { _id: { $nin: questions.map(q => q._id) } } },
        { $sample: { size: additionalNeeded } },
      ]);
      
      questions = [...questions, ...additionalQuestions];
      console.log(`✅ Added ${additionalQuestions.length} questions from other difficulties. Total: ${questions.length}`);
    }

    // If still not enough, generate from random words
    if (questions.length < safeLimit) {
      console.log(`⚠️ Still need ${safeLimit - questions.length} more questions, generating...`);
      
      // Get random words (any difficulty)
      const words = await Word.aggregate([
        { $sample: { size: safeLimit - questions.length } },
      ]);

      console.log(`📝 Generating questions for ${words.length} random words`);

      // Generate questions for these words
      for (const word of words) {
        try {
          const generated = await this.generateQuestions({
            wordId: word._id,
            count: 1,
            difficulty: word.difficulty || difficulty,
            lessonKey: 'grammar-practice',
          });
          questions.push(...generated);
          console.log(`✅ Generated question for word: ${word.word}`);
        } catch (error) {
          console.error(`❌ Failed to generate question for word ${word._id}:`, error.message);
        }
      }
    }

    console.log(`🎯 Final result: ${questions.length}/${safeLimit} questions ready`);
    return questions.slice(0, safeLimit);
  },
};

module.exports = grammarQuestionService;
