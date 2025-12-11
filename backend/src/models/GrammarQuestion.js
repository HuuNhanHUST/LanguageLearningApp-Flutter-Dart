const mongoose = require('mongoose');

const grammarQuestionSchema = new mongoose.Schema(
  {
    wordId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Word',
      required: true,
      index: true,
    },
    word: {
      type: String,
      required: true,
      trim: true,
    },
    question: {
      type: String,
      required: true,
      trim: true,
    },
    options: {
      type: [String],
      validate: {
        validator(value) {
          return Array.isArray(value) && value.length === 4;
        },
        message: 'Options must contain exactly 4 choices',
      },
      required: true,
    },
    correctIndex: {
      type: Number,
      required: true,
      min: 0,
      max: 3,
    },
    explanation: {
      type: String,
      trim: true,
    },
    targetSkill: {
      type: String,
      default: 'grammar',
      trim: true,
    },
    difficulty: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'beginner',
    },
    source: {
      type: String,
      default: 'gemini',
      trim: true,
    },
    createdForLesson: {
      type: String,
      trim: true,
    },
    metadata: {
      type: Map,
      of: String,
      default: undefined,
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

grammarQuestionSchema.index({ wordId: 1, createdAt: -1 });
grammarQuestionSchema.index({ targetSkill: 1, difficulty: 1 });

const GrammarQuestion = mongoose.model('GrammarQuestion', grammarQuestionSchema);

module.exports = GrammarQuestion;
