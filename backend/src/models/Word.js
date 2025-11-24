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

wordSchema.index({ normalizedWord: 1 });
wordSchema.index({ owners: 1 });

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
