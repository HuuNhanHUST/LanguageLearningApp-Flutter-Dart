const Class = require('../models/Class');
const User = require('../models/User');
const GrammarQuestion = require('../models/GrammarQuestion');

/**
 * @desc    Tạo lớp học mới (chỉ cho giáo viên)
 * @route   POST /api/classes
 * @access  Private (Teacher)
 */
exports.createClass = async (req, res) => {
    try {
        const { name, description, maxStudents, settings } = req.body;
        
        // Kiểm tra user có phải teacher không
        if (req.user.role !== 'teacher' && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Only teachers can create classes'
            });
        }
        
        const classData = {
            name,
            description,
            teacher: req.user._id,
            maxStudents: maxStudents || 100,
            settings: settings || {}
        };
        
        const newClass = await Class.create(classData);
        await newClass.populate('teacher', 'username email firstName lastName');
        
        res.status(201).json({
            success: true,
            message: 'Class created successfully',
            data: newClass.toJSON()
        });
        
    } catch (error) {
        console.error('Create class error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create class',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy danh sách lớp học của giáo viên
 * @route   GET /api/classes/my-classes
 * @access  Private (Teacher)
 */
exports.getMyClasses = async (req, res) => {
    try {
        const classes = await Class.find({ 
            teacher: req.user._id,
            isActive: true 
        })
        .populate('teacher', 'username email firstName lastName')
        .populate('students', 'username firstName lastName avatar')
        .sort({ createdAt: -1 });
        
        res.json({
            success: true,
            count: classes.length,
            data: classes.map(c => c.toJSON())
        });
        
    } catch (error) {
        console.error('Get my classes error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch classes',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy danh sách lớp học mà học sinh tham gia
 * @route   GET /api/classes/enrolled
 * @access  Private (Student)
 */
exports.getEnrolledClasses = async (req, res) => {
    try {
        const classes = await Class.find({ 
            students: req.user._id,
            isActive: true 
        })
        .populate('teacher', 'username email firstName lastName')
        .populate('students', 'username email firstName lastName')
        .sort({ createdAt: -1 });
        
        res.json({
            success: true,
            count: classes.length,
            data: classes.map(c => c.toJSON())
        });
        
    } catch (error) {
        console.error('Get enrolled classes error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch enrolled classes',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Tham gia lớp học bằng mã lớp
 * @route   POST /api/classes/join
 * @access  Private (Student)
 */
exports.joinClass = async (req, res) => {
    try {
        const { classCode } = req.body;
        
        if (!classCode) {
            return res.status(400).json({
                success: false,
                message: 'Class code is required'
            });
        }
        
        const classToJoin = await Class.findOne({ 
            classCode: classCode.toUpperCase(),
            isActive: true 
        }).populate('teacher', 'username email firstName lastName');
        
        if (!classToJoin) {
            return res.status(404).json({
                success: false,
                message: 'Class not found or is not active'
            });
        }
        
        // Kiểm tra đã tham gia chưa
        if (classToJoin.students.includes(req.user._id)) {
            return res.status(400).json({
                success: false,
                message: 'You are already enrolled in this class'
            });
        }
        
        // Kiểm tra lớp đã đầy chưa
        if (classToJoin.students.length >= classToJoin.maxStudents) {
            return res.status(400).json({
                success: false,
                message: 'This class is full'
            });
        }
        
        await classToJoin.addStudent(req.user._id);
        
        // Populate students after adding
        await classToJoin.populate('students', 'username email firstName lastName');
        
        res.json({
            success: true,
            message: 'Successfully joined the class',
            data: classToJoin.toJSON()
        });
        
    } catch (error) {
        console.error('Join class error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to join class',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy thông tin chi tiết lớp học
 * @route   GET /api/classes/:id
 * @access  Private
 */
exports.getClassById = async (req, res) => {
    try {
        const classData = await Class.findById(req.params.id)
            .populate('teacher', 'username email firstName lastName avatar')
            .populate('students', 'username firstName lastName avatar xp level');
        
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        // Kiểm tra quyền truy cập
        const isTeacher = classData.teacher._id.equals(req.user._id);
        const isStudent = classData.students.some(student => student._id.equals(req.user._id));
        const isAdmin = req.user.role === 'admin';
        
        if (!isTeacher && !isStudent && !isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'You do not have access to this class'
            });
        }
        
        res.json({
            success: true,
            data: classData.toJSON()
        });
        
    } catch (error) {
        console.error('Get class by ID error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch class details',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Cập nhật thông tin lớp học
 * @route   PUT /api/classes/:id
 * @access  Private (Teacher - owner)
 */
exports.updateClass = async (req, res) => {
    try {
        const classData = await Class.findById(req.params.id);
        
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        // Kiểm tra quyền (chỉ giáo viên tạo lớp mới được cập nhật)
        if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'You do not have permission to update this class'
            });
        }
        
        const { name, description, maxStudents, settings, isActive } = req.body;
        
        if (name) classData.name = name;
        if (description !== undefined) classData.description = description;
        if (maxStudents) classData.maxStudents = maxStudents;
        if (settings) classData.settings = { ...classData.settings, ...settings };
        if (isActive !== undefined) classData.isActive = isActive;
        
        await classData.save();
        await classData.populate('teacher', 'username email firstName lastName');
        
        res.json({
            success: true,
            message: 'Class updated successfully',
            data: classData.toJSON()
        });
        
    } catch (error) {
        console.error('Update class error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update class',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Xóa học sinh khỏi lớp
 * @route   DELETE /api/classes/:id/students/:studentId
 * @access  Private (Teacher - owner)
 */
exports.removeStudent = async (req, res) => {
    try {
        const classData = await Class.findById(req.params.id);
        
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        // Kiểm tra quyền
        if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'You do not have permission to remove students from this class'
            });
        }
        
        await classData.removeStudent(req.params.studentId);
        
        res.json({
            success: true,
            message: 'Student removed successfully'
        });
        
    } catch (error) {
        console.error('Remove student error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to remove student',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Rời khỏi lớp học (học sinh tự rời)
 * @route   POST /api/classes/:id/leave
 * @access  Private (Student)
 */
exports.leaveClass = async (req, res) => {
    try {
        const classData = await Class.findById(req.params.id);
        
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        // Kiểm tra có phải học sinh của lớp không
        if (!classData.students.includes(req.user._id)) {
            return res.status(400).json({
                success: false,
                message: 'You are not enrolled in this class'
            });
        }
        
        await classData.removeStudent(req.user._id);
        
        res.json({
            success: true,
            message: 'Successfully left the class'
        });
        
    } catch (error) {
        console.error('Leave class error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to leave class',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Xóa lớp học
 * @route   DELETE /api/classes/:id
 * @access  Private (Teacher - owner hoặc Admin)
 */
exports.deleteClass = async (req, res) => {
    try {
        const classData = await Class.findById(req.params.id);
        
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        // Kiểm tra quyền
        if (!classData.teacher.equals(req.user._id) && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'You do not have permission to delete this class'
            });
        }
        
        await Class.findByIdAndDelete(req.params.id);
        
        res.json({
            success: true,
            message: 'Class deleted successfully'
        });
        
    } catch (error) {
        console.error('Delete class error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete class',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Lấy danh sách bài tập của lớp
 * @route   GET /api/classes/:id/assignments
 * @access  Private (Teacher hoặc Student của lớp)
 */
exports.getClassAssignments = async (req, res) => {
    try {
        const classData = await Class.findById(req.params.id);
        
        if (!classData) {
            return res.status(404).json({
                success: false,
                message: 'Class not found'
            });
        }
        
        // Kiểm tra quyền truy cập
        const isTeacher = classData.teacher.equals(req.user._id);
        const isStudent = classData.students.includes(req.user._id);
        const isAdmin = req.user.role === 'admin';
        
        if (!isTeacher && !isStudent && !isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'You do not have access to this class'
            });
        }
        
        // Lấy các câu hỏi ngữ pháp cho lớp này
        const questions = await GrammarQuestion.find({
            classId: req.params.id,
            isPublic: false
        }).sort({ createdAt: -1 });
        
        res.json({
            success: true,
            data: {
                assignments: classData.assignments,
                questions: questions
            }
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

module.exports = exports;
