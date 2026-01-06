const GrammarQuestion = require('../models/GrammarQuestion');
const Class = require('../models/Class');
const Submission = require('../models/Submission');

/**
 * @desc    Giáo viên tạo câu hỏi cho lớp
 * @route   POST /api/grammar/teacher/questions
 * @access  Private (Teacher)
 */
exports.createClassQuestion = async (req, res) => {
    try {
        const { word, question, options, correctIndex, explanation, difficulty, classId } = req.body;
        
        // Validate
        if (!question || !options || options.length !== 4 || correctIndex < 0 || correctIndex > 3) {
            return res.status(400).json({
                success: false,
                message: 'Invalid question format. Need question, 4 options, and correct index (0-3)'
            });
        }
        
        // Check class exists và user là teacher của lớp
        const classData = await Class.findById(classId);
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Only the teacher of this class can create questions'
            });
        }
        
        const newQuestion = await GrammarQuestion.create({
            word: word || '',
            question,
            options,
            correctIndex,
            explanation: explanation || '',
            difficulty: difficulty || 'intermediate',
            createdBy: req.user._id,
            classId,
            isPublic: false
        });
        
        res.status(201).json({
            success: true,
            message: 'Question created successfully',
            data: newQuestion.toJSON()
        });
        
    } catch (error) {
        console.error('Create class question error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create question',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy câu hỏi của lớp (cho student làm bài)
 * @route   GET /api/grammar/class/:classId/questions
 * @access  Private
 */
exports.getClassQuestions = async (req, res) => {
    try {
        const { classId } = req.params;
        
        // Check user có trong lớp không
        const classData = await Class.findById(classId);
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        const isTeacher = classData.teacher.equals(req.user._id);
        const isStudent = classData.students.some(s => s.equals(req.user._id));
        const isAdmin = req.user.role === 'admin';
        
        if (!isTeacher && !isStudent && !isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'You are not a member of this class'
            });
        }
        
        const questions = await GrammarQuestion.find({ classId })
            .select('-__v')
            .sort({ createdAt: -1 });
        
        res.json({
            success: true,
            count: questions.length,
            data: questions.map(q => q.toJSON())
        });
        
    } catch (error) {
        console.error('Get class questions error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch questions',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Học sinh submit bài làm
 * @route   POST /api/grammar/submit
 * @access  Private (Student)
 */
exports.submitAnswers = async (req, res) => {
    try {
        const { classId, assignmentId, answers } = req.body;
        
        // Validate
        if (!classId || !assignmentId || !answers || !Array.isArray(answers)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid submission format'
            });
        }
        
        // Check đã submit chưa
        const existingSubmission = await Submission.findOne({
            student: req.user._id,
            assignmentId
        });
        
        if (existingSubmission) {
            return res.status(400).json({
                success: false,
                message: 'You have already submitted this assignment'
            });
        }
        
        // Lấy tất cả câu hỏi để chấm điểm
        const questionIds = answers.map(a => a.questionId);
        const questions = await GrammarQuestion.find({ _id: { $in: questionIds } });
        
        if (questions.length !== answers.length) {
            return res.status(400).json({
                success: false,
                message: 'Invalid question IDs'
            });
        }
        
        // Chấm điểm
        let correctCount = 0;
        const gradedAnswers = answers.map(answer => {
            const question = questions.find(q => q._id.toString() === answer.questionId);
            const isCorrect = question.correctIndex === answer.selectedIndex;
            if (isCorrect) correctCount++;
            
            return {
                questionId: answer.questionId,
                selectedIndex: answer.selectedIndex,
                isCorrect
            };
        });
        
        // Tính điểm: 10 câu = 10 điểm, 20 câu = 10 điểm
        const totalQuestions = answers.length;
        const score = (correctCount / totalQuestions) * 10;
        
        const submission = await Submission.create({
            student: req.user._id,
            classId,
            assignmentId,
            answers: gradedAnswers,
            score: Math.round(score * 100) / 100, // Làm tròn 2 số thập phân
            totalQuestions,
            correctAnswers: correctCount
        });
        
        await submission.populate('student', 'username firstName lastName avatar');
        
        res.status(201).json({
            success: true,
            message: 'Assignment submitted successfully',
            data: submission.toJSON()
        });
        
    } catch (error) {
        console.error('Submit answers error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to submit answers',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy kết quả của học sinh
 * @route   GET /api/grammar/submissions/:assignmentId
 * @access  Private
 */
exports.getSubmission = async (req, res) => {
    try {
        const { assignmentId } = req.params;
        
        const submission = await Submission.findOne({
            student: req.user._id,
            assignmentId
        }).populate('student', 'username firstName lastName avatar');
        
        if (!submission) {
            return res.status(404).json({
                success: false,
                message: 'Submission not found'
            });
        }
        
        res.json({
            success: true,
            data: submission.toJSON()
        });
        
    } catch (error) {
        console.error('Get submission error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch submission',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Giáo viên xem tất cả bài làm của lớp
 * @route   GET /api/grammar/class/:classId/submissions
 * @access  Private (Teacher)
 */
exports.getClassSubmissions = async (req, res) => {
    try {
        const { classId } = req.params;
        
        // Check quyền
        const classData = await Class.findById(classId);
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Only the teacher can view submissions'
            });
        }
        
        const submissions = await Submission.find({ classId })
            .populate('student', 'username firstName lastName avatar')
            .sort({ score: -1, submittedAt: -1 });
        
        res.json({
            success: true,
            count: submissions.length,
            data: submissions.map(s => s.toJSON())
        });
        
    } catch (error) {
        console.error('Get class submissions error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch submissions',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

module.exports = exports;
