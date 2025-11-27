const mongoose = require('mongoose');

/**
 * UserWord Model - User's Personal Vocabulary
 * Tracks relationship between User and Word (from dictionary)
 * Stores learning progress, memorization status, and review schedule
 */
const userWordSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    wordId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Word',
      required: true,
    },
    
    // Learning Status
    isMemorized: {
      type: Boolean,
      default: false,
    },
    
    // Timestamps
    addedAt: {
      type: Date,
      default: Date.now,
    },
    lastReviewedAt: {
      type: Date,
    },
    memorizedAt: {
      type: Date,
    },
    
    // Review Statistics
    reviewCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    correctCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    incorrectCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    
    // Spaced Repetition (SM-2 Algorithm)
    easinessFactor: {
      type: Number,
      default: 2.5,
      min: 1.3,
      comment: 'SM-2 easiness factor (1.3 - 3.0)',
    },
    interval: {
      type: Number,
      default: 0,
      min: 0,
      comment: 'Days until next review',
    },
    repetitions: {
      type: Number,
      default: 0,
      min: 0,
    },
    nextReviewDate: {
      type: Date,
      comment: 'When user should review this word',
    },
    
    // User Customization
    personalNote: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    personalExample: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    
    // Source tracking
    source: {
      type: String,
      enum: ['lookup', 'manual', 'lesson', 'import'],
      default: 'lookup',
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

// Compound indexes for efficient queries
userWordSchema.index({ userId: 1, wordId: 1 }, { unique: true });
userWordSchema.index({ userId: 1, isMemorized: 1 });
userWordSchema.index({ userId: 1, nextReviewDate: 1 });
userWordSchema.index({ userId: 1, addedAt: -1 });

// Virtual for accuracy rate
userWordSchema.virtual('accuracyRate').get(function () {
  const total = this.correctCount + this.incorrectCount;
  if (total === 0) return 0;
  return Math.round((this.correctCount / total) * 100);
});

// Virtual to check if review is due
userWordSchema.virtual('isDueForReview').get(function () {
  if (!this.nextReviewDate) return true;
  return new Date() >= this.nextReviewDate;
});

// Instance method to mark as memorized
userWordSchema.methods.toggleMemorized = function () {
  this.isMemorized = !this.isMemorized;
  if (this.isMemorized) {
    this.memorizedAt = new Date();
  } else {
    this.memorizedAt = null;
  }
  return this.save();
};

// Instance method to update review (SM-2 Algorithm)
userWordSchema.methods.updateReview = function (quality) {
  this.reviewCount += 1;
  this.lastReviewedAt = new Date();
  
  if (quality >= 3) {
    this.correctCount += 1;
    
    if (this.repetitions === 0) {
      this.interval = 1;
    } else if (this.repetitions === 1) {
      this.interval = 6;
    } else {
      this.interval = Math.round(this.interval * this.easinessFactor);
    }
    this.repetitions += 1;
  } else {
    this.incorrectCount += 1;
    this.repetitions = 0;
    this.interval = 1;
  }
  
  // Update easiness factor
  this.easinessFactor = Math.max(
    1.3,
    this.easinessFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)),
  );
  
  // Calculate next review date
  this.nextReviewDate = new Date(Date.now() + this.interval * 24 * 60 * 60 * 1000);
  
  return this.save();
};

// Static method to get user stats
userWordSchema.statics.getUserStats = async function (userId) {
  const total = await this.countDocuments({ userId });
  const memorized = await this.countDocuments({ userId, isMemorized: true });
  const dueForReview = await this.countDocuments({
    userId,
    nextReviewDate: { $lte: new Date() },
  });
  
  return {
    total,
    memorized,
    learning: total - memorized,
    dueForReview,
    memorizedPercentage: total > 0 ? Math.round((memorized / total) * 100) : 0,
  };
};

// Static method to get words due for review
userWordSchema.statics.getDueWords = async function (userId, limit = 20) {
  return this.find({
    userId,
    nextReviewDate: { $lte: new Date() },
  })
    .populate('wordId')
    .sort({ nextReviewDate: 1 })
    .limit(limit);
};

const UserWord = mongoose.model('UserWord', userWordSchema);

module.exports = UserWord;
