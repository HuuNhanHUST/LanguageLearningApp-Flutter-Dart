const Submission = require('../models/Submission');
const Assignment = require('../models/Assignment');
const GrammarQuestion = require('../models/GrammarQuestion');
const Class = require('../models/Class');

/**
 * @desc    Submit assignment
 * @route   POST /api/submissions
 * @access  Private (Student)
 */
exports.submitAssignment = async (req, res) => {
    try {
        const { assignmentId, classId, answers } = req.body;
        const studentId = req.user._id;

        // Validate required fields
        if (!assignmentId || !classId || !answers || !Array.isArray(answers)) {
            return res.status(400).json({
                success: false,
                message: 'Missing required fields'
            });
        }

        // Check if assignment exists and is published
        const assignment = await Assignment.findById(assignmentId)
            .populate('questions');
        
        if (!assignment) {
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }

        if (!assignment.isPublished) {
            return res.status(400).json({
                success: false,
                message: 'Assignment is not published yet'
            });
        }

        // Check if student is enrolled in the class
        const classDoc = await Class.findById(classId);
        if (!classDoc) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }

        const isEnrolled = classDoc.students.some(
            studentId => studentId.toString() === req.user._id.toString()
        );

        if (!isEnrolled) {
            return res.status(403).json({
                success: false,
                message: 'You are not enrolled in this class'
            });
        }

        // Check if already submitted
        const existingSubmission = await Submission.findOne({
            student: studentId,
            assignmentId: assignmentId
        });

        if (existingSubmission) {
            return res.status(400).json({
                success: false,
                message: 'You have already submitted this assignment'
            });
        }

        // Process answers and calculate score
        const processedAnswers = [];
        let correctCount = 0;

        for (const answer of answers) {
            const question = assignment.questions.find(
                q => q._id.toString() === answer.questionId.toString()
            );

            if (!question) {
                return res.status(400).json({
                    success: false,
                    message: `Question ${answer.questionId} not found in assignment`
                });
            }

            const isCorrect = question.correctIndex === answer.selectedIndex;
            if (isCorrect) correctCount++;

            processedAnswers.push({
                questionId: answer.questionId,
                selectedIndex: answer.selectedIndex,
                isCorrect
            });
        }

        // Calculate score (0-10)
        const totalQuestions = assignment.questions.length;
        const score = (correctCount / totalQuestions) * 10;

        // Create submission
        const submission = await Submission.create({
            student: studentId,
            assignmentId,
            classId,
            answers: processedAnswers,
            score: parseFloat(score.toFixed(2)),
            correctAnswers: correctCount,
            totalQuestions
        });

        res.status(201).json({
            success: true,
            message: 'Assignment submitted successfully',
            data: submission
        });

    } catch (error) {
        console.error('Submit assignment error:', error);
        res.status(500).json({
            success: false,
            message: 'Error submitting assignment',
            error: error.message
        });
    }
};

/**
 * @desc    Get my submission for an assignment
 * @route   GET /api/submissions/my/:assignmentId
 * @access  Private (Student)
 */
exports.getMySubmission = async (req, res) => {
    try {
        const { assignmentId } = req.params;
        const studentId = req.user._id;

        const submission = await Submission.findOne({
            student: studentId,
            assignmentId: assignmentId
        })
        .populate({
            path: 'answers.questionId',
            select: 'question options correctIndex explanation difficulty'
        })
        .populate('student', 'firstName lastName email avatar');

        if (!submission) {
            return res.status(404).json({
                success: false,
                message: 'Submission not found'
            });
        }

        res.json({
            success: true,
            data: submission
        });

    } catch (error) {
        console.error('Get my submission error:', error);
        res.status(500).json({
            success: false,
            message: 'Error getting submission',
            error: error.message
        });
    }
};

/**
 * @desc    Get all submissions for an assignment (Teacher only)
 * @route   GET /api/submissions/assignment/:assignmentId
 * @access  Private (Teacher)
 */
exports.getAssignmentSubmissions = async (req, res) => {
    try {
        const { assignmentId } = req.params;

        // Verify assignment exists and user is the teacher
        const assignment = await Assignment.findById(assignmentId);
        if (!assignment) {
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }

        // Get class to verify teacher
        const classDoc = await Class.findById(assignment.classId);
        if (!classDoc) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }

        if (classDoc.teacher.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Access denied'
            });
        }

        const submissions = await Submission.find({ assignmentId })
            .populate('student', 'firstName lastName email avatar')
            .sort({ score: -1, submittedAt: 1 });

        // Calculate statistics
        const stats = {
            totalSubmissions: submissions.length,
            averageScore: submissions.length > 0 
                ? (submissions.reduce((sum, s) => sum + s.score, 0) / submissions.length).toFixed(2)
                : 0,
            highestScore: submissions.length > 0 
                ? Math.max(...submissions.map(s => s.score))
                : 0,
            lowestScore: submissions.length > 0 
                ? Math.min(...submissions.map(s => s.score))
                : 0
        };

        res.json({
            success: true,
            data: {
                submissions,
                stats
            }
        });

    } catch (error) {
        console.error('Get assignment submissions error:', error);
        res.status(500).json({
            success: false,
            message: 'Error getting submissions',
            error: error.message
        });
    }
};

/**
 * @desc    Check if student has submitted assignment
 * @route   GET /api/submissions/check/:assignmentId
 * @access  Private (Student)
 */
exports.checkSubmission = async (req, res) => {
    try {
        const { assignmentId } = req.params;
        const studentId = req.user._id;

        const submission = await Submission.findOne({
            student: studentId,
            assignmentId: assignmentId
        }).select('score submittedAt');

        res.json({
            success: true,
            data: {
                hasSubmitted: !!submission,
                submission: submission || null
            }
        });

    } catch (error) {
        console.error('Check submission error:', error);
        res.status(500).json({
            success: false,
            message: 'Error checking submission',
            error: error.message
        });
    }
};
