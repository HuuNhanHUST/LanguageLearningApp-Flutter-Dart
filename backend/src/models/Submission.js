const mongoose = require('mongoose');

const submissionSchema = new mongoose.Schema({
    student: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    classId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Class',
        required: true,
        index: true
    },
    assignmentId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true
    },
    answers: [{
        questionId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'GrammarQuestion',
            required: true
        },
        selectedIndex: {
            type: Number,
            required: true
        },
        isCorrect: {
            type: Boolean,
            required: true
        }
    }],
    score: {
        type: Number,
        required: true,
        min: 0,
        max: 10
    },
    totalQuestions: {
        type: Number,
        required: true
    },
    correctAnswers: {
        type: Number,
        required: true
    },
    submittedAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// Index để tránh submit nhiều lần
submissionSchema.index({ student: 1, assignmentId: 1 }, { unique: true });

// Virtual để tính phần trăm
submissionSchema.virtual('percentage').get(function() {
    return ((this.correctAnswers / this.totalQuestions) * 100).toFixed(2);
});

// Configure toJSON
submissionSchema.set('toJSON', {
    virtuals: true,
    versionKey: false,
    transform: function(doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        return ret;
    }
});

const Submission = mongoose.model('Submission', submissionSchema);

module.exports = Submission;
