const mongoose = require('mongoose');
const crypto = require('crypto');

const classSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Class name is required'],
        trim: true,
        maxlength: [100, 'Class name cannot exceed 100 characters']
    },
    description: {
        type: String,
        trim: true,
        maxlength: [500, 'Description cannot exceed 500 characters']
    },
    classCode: {
        type: String,
        required: false, // Will be auto-generated in pre-save hook
        unique: true,
        sparse: true, // Allow null before generation
        uppercase: true,
        index: true
    },
    teacher: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    students: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }],
    // Danh sách các bài tập được gán cho lớp này
    assignments: [{
        grammarQuestionSetId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'GrammarQuestionSet'
        },
        title: String,
        dueDate: Date,
        assignedAt: {
            type: Date,
            default: Date.now
        }
    }],
    isActive: {
        type: Boolean,
        default: true
    },
    maxStudents: {
        type: Number,
        default: 100
    },
    settings: {
        allowLateSubmission: {
            type: Boolean,
            default: true
        },
        showResults: {
            type: Boolean,
            default: true
        },
        randomizeQuestions: {
            type: Boolean,
            default: false
        }
    }
}, {
    timestamps: true
});

// Tạo mã lớp học tự động trước khi save
classSchema.pre('save', async function(next) {
    if (this.isNew && !this.classCode) {
        // Tạo mã ngẫu nhiên 6 ký tự
        let code;
        let isUnique = false;
        
        while (!isUnique) {
            code = crypto.randomBytes(3).toString('hex').toUpperCase();
            const existingClass = await mongoose.model('Class').findOne({ classCode: code });
            if (!existingClass) {
                isUnique = true;
            }
        }
        
        this.classCode = code;
    }
    next();
});

// Virtual để lấy số lượng học sinh
classSchema.virtual('studentCount').get(function() {
    return this.students ? this.students.length : 0;
});

// Virtual để lấy số lượng bài tập
classSchema.virtual('assignmentCount').get(function() {
    return this.assignments ? this.assignments.length : 0;
});

// Index cho performance
classSchema.index({ teacher: 1, isActive: 1 });
classSchema.index({ students: 1 });

// Method để thêm học sinh vào lớp
classSchema.methods.addStudent = async function(studentId) {
    if (this.students.includes(studentId)) {
        throw new Error('Student is already enrolled in this class');
    }
    
    if (this.students.length >= this.maxStudents) {
        throw new Error('Class is full');
    }
    
    this.students.push(studentId);
    await this.save();
    return this;
};

// Method để xóa học sinh khỏi lớp
classSchema.methods.removeStudent = async function(studentId) {
    this.students = this.students.filter(id => !id.equals(studentId));
    await this.save();
    return this;
};

// Method để kiểm tra user có phải học sinh của lớp không
classSchema.methods.isStudent = function(userId) {
    return this.students.some(id => id.equals(userId));
};

// Method để thêm bài tập
classSchema.methods.addAssignment = async function(assignment) {
    this.assignments.push(assignment);
    await this.save();
    return this;
};

// Configure toJSON to include virtuals
classSchema.set('toJSON', {
    virtuals: true,
    versionKey: false,
    transform: function(doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        return ret;
    }
});

classSchema.set('toObject', {
    virtuals: true,
    versionKey: false
});

const Class = mongoose.model('Class', classSchema);

module.exports = Class;
