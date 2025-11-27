const mongoose = require('mongoose');

/**
 * Word Model - Global Dictionary (3000 pre-loaded words)
 * Represents word definitions shared across all users
 * No ownership - public dictionary for everyone
 */
const wordSchema = new mongoose.Schema(
  {
    word: {
      type: String,
      required: true,
      trim: true,
    },
    normalizedWord: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    meaning: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ['noun', 'verb', 'adj', 'adv', 'other'],
      default: 'other',
      trim: true,
    },
    example: {
      type: String,
      trim: true,
    },
    topic: {
      type: String,
      trim: true,
      default: 'General',
    },
    // NEW: Enhanced fields for learning
    level: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'intermediate',
    },
    frequency: {
      type: Number,
      default: 0,
      comment: 'Word frequency rank (lower = more common)',
    },
    pronunciation: {
      type: String,
      trim: true,
      comment: 'IPA phonetic notation',
    },
    synonyms: [String],
    antonyms: [String],
    // Analytics
    totalLearners: {
      type: Number,
      default: 0,
      comment: 'Count of users who added this word',
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      versionKey: false,
      transform: (_, ret) => {
        ret.id = ret._id;
        delete ret._id;
        return ret;
      },
    },
    toObject: {
      virtuals: true,
      versionKey: false,
    },
  },
);

// Indexes for performance
wordSchema.index({ normalizedWord: 1 });
wordSchema.index({ topic: 1, level: 1 });
wordSchema.index({ frequency: 1 });

// Indexes for performance
wordSchema.index({ normalizedWord: 1 });
wordSchema.index({ topic: 1, level: 1 });
wordSchema.index({ frequency: 1 });

// Pre-validate hook to auto-generate normalizedWord
wordSchema.pre('validate', function normalizeWord(next) {
  if (this.word) {
    const trimmed = this.word.trim();
    this.word = trimmed;
    this.normalizedWord = trimmed.toLowerCase();
  }
  next();
});

// Static method to search words
wordSchema.statics.searchWords = async function (query, filters = {}) {
  const searchQuery = {
    $or: [
      { normalizedWord: new RegExp(query.toLowerCase(), 'i') },
      { word: new RegExp(query, 'i') },
      { meaning: new RegExp(query, 'i') },
    ],
  };

  if (filters.topic) searchQuery.topic = filters.topic;
  if (filters.level) searchQuery.level = filters.level;
  if (filters.type) searchQuery.type = filters.type;

  return this.find(searchQuery)
    .limit(filters.limit || 50)
    .sort({ frequency: 1 });
};

const Word = mongoose.model('Word', wordSchema);

module.exports = Word;
