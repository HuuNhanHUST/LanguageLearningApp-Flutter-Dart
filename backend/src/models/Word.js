const mongoose = require('mongoose');

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
    difficulty: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'beginner',
      trim: true,
    },
    difficultyLevel: {
      type: Number,
      min: 1,
      max: 10,
      default: 1,
    },
    owners: {
      type: [
        {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
        },
      ],
      default: [],
    },
    memorizedBy: {
      type: [
        {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
        },
      ],
      default: [],
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

// Regular indexes for exact match and filtering
wordSchema.index({ normalizedWord: 1 });
wordSchema.index({ owners: 1 });
wordSchema.index({ topic: 1 });

// Full-Text Search Index for fast search
// Supports case-insensitive search on word, meaning, example, and topic
wordSchema.index({ 
  word: 'text', 
  meaning: 'text', 
  example: 'text',
  topic: 'text'
}, {
  name: 'word_fulltext_search',
  default_language: 'english',
  weights: {
    word: 10,        // Highest priority for word field
    meaning: 5,      // Medium-high priority for meaning
    topic: 3,        // Medium priority for topic
    example: 1       // Lowest priority for example
  }
});

wordSchema.pre('validate', function normalizeWord(next) {
  if (this.word) {
    const trimmed = this.word.trim();
    this.word = trimmed;
    this.normalizedWord = trimmed.toLowerCase();
  }
  next();
});

const Word = mongoose.model('Word', wordSchema);

module.exports = Word;
