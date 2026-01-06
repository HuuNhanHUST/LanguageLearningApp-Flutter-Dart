const mongoose = require('mongoose');

const assignmentSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    classId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Class',
      required: true,
      index: true,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    questions: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'GrammarQuestion',
    }],
    dueDate: {
      type: Date,
    },
    isPublished: {
      type: Boolean,
      default: false,
    },
    totalPoints: {
      type: Number,
      default: 10,
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
  }
);

assignmentSchema.index({ classId: 1, createdAt: -1 });
assignmentSchema.index({ createdBy: 1 });

const Assignment = mongoose.model('Assignment', assignmentSchema);

module.exports = Assignment;
