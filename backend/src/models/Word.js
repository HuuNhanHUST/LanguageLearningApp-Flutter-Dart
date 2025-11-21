const mongoose = require('mongoose');

const wordSchema = new mongoose.Schema(
  {
    word: {
      type: String,
      required: true,
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
        trim: true
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
    isMemorized: {
      type: Boolean,
      default: false,
    },
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
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

wordSchema.index({ owner: 1, word: 1 }, { unique: true });

const Word = mongoose.model('Word', wordSchema);

module.exports = Word;
