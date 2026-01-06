const Assignment = require('../models/Assignment');
const Class = require('../models/Class');
const GrammarQuestion = require('../models/GrammarQuestion');

/**
 * @desc    Tạo assignment (bài tập)
 * @route   POST /api/assignments
 * @access  Private (Teacher)
 */
exports.createAssignment = async (req, res) => {
    try {
        const { title, description, classId, questionIds, dueDate, isPublished } = req.body;
        
        if (!title || !classId || !questionIds || questionIds.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Title, classId, and at least one question are required'
            });
        }
        
        // Check class exists và user là teacher
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
                message: 'Only the teacher can create assignments'
            });
        }
        
        // Verify all questions exist
        const questions = await GrammarQuestion.find({ _id: { $in: questionIds } });
        if (questions.length !== questionIds.length) {
            return res.status(400).json({
                success: false,
                message: 'Some questions do not exist'
            });
        }
        
        const assignment = await Assignment.create({
            title,
            description: description || '',
            classId,
            createdBy: req.user._id,
            questions: questionIds,
            dueDate: dueDate ? new Date(dueDate) : undefined,
            isPublished: isPublished || false,
        });
        
        res.status(201).json({
            success: true,
            message: 'Assignment created successfully',
            data: assignment.toJSON()
        });
        
    } catch (error) {
        console.error('Create assignment error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create assignment',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy danh sách assignments của lớp
 * @route   GET /api/assignments/class/:classId
 * @access  Private
 */
exports.getClassAssignments = async (req, res) => {
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
        
        // Students only see published assignments
        const query = { classId };
        if (!isTeacher && !isAdmin) {
            query.isPublished = true;
        }
        
        const assignments = await Assignment.find(query)
            .populate('createdBy', 'username')
            .sort({ createdAt: -1 });
        
        res.json({
            success: true,
            count: assignments.length,
            data: assignments.map(a => a.toJSON())
        });
        
    } catch (error) {
        console.error('Get class assignments error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch assignments',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy chi tiết assignment với câu hỏi
 * @route   GET /api/assignments/:id
 * @access  Private
 */
exports.getAssignmentById = async (req, res) => {
    try {
        const assignment = await Assignment.findById(req.params.id)
            .populate('questions')
            .populate('createdBy', 'username');
        
        if (!assignment) {
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }
        
        // Check access
        const classData = await Class.findById(assignment.classId);
        const isTeacher = classData.teacher.equals(req.user._id);
        const isStudent = classData.students.some(s => s.equals(req.user._id));
        const isAdmin = req.user.role === 'admin';
        
        if (!isTeacher && !isStudent && !isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'Access denied'
            });
        }
        
        // Students can't see unpublished assignments
        if (!isTeacher && !isAdmin && !assignment.isPublished) {
            return res.status(403).json({
                success: false,
                message: 'This assignment is not published yet'
            });
        }
        
        res.json({
            success: true,
            data: assignment.toJSON()
        });
        
    } catch (error) {
        console.error('Get assignment error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch assignment',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Xóa assignment
 * @route   DELETE /api/assignments/:id
 * @access  Private (Teacher)
 */
exports.deleteAssignment = async (req, res) => {
    try {
        const assignment = await Assignment.findById(req.params.id);
        
        if (!assignment) {
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }
        
        // Check quyền
        const classData = await Class.findById(assignment.classId);
        if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Only the teacher can delete assignments'
            });
        }
        
        await assignment.deleteOne();
        
        res.json({
            success: true,
            message: 'Assignment deleted successfully'
        });
        
    } catch (error) {
        console.error('Delete assignment error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete assignment',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Publish/unpublish assignment
 * @route   PUT /api/assignments/:id/publish
 * @access  Private (Teacher)
 */
exports.togglePublish = async (req, res) => {
    try {
        const assignment = await Assignment.findById(req.params.id);
        
        if (!assignment) {
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }
        
        // Check quyền
        const classData = await Class.findById(assignment.classId);
        if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Only the teacher can publish assignments'
            });
        }
        
        assignment.isPublished = !assignment.isPublished;
        await assignment.save();
        
        res.json({
            success: true,
            message: `Assignment ${assignment.isPublished ? 'published' : 'unpublished'} successfully`,
            data: assignment.toJSON()
        });
        
    } catch (error) {
        console.error('Toggle publish error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update assignment',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

module.exports = exports;
