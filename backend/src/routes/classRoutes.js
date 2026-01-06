const express = require('express');
const router = express.Router();
const classController = require('../controllers/classController');
const { auth, isTeacherOrAdmin } = require('../middleware/auth');

// Tất cả routes đều cần authentication
router.use(auth);

/**
 * @route   POST /api/classes
 * @desc    Tạo lớp học mới
 * @access  Private (Teacher/Admin)
 */
router.post('/', isTeacherOrAdmin, classController.createClass);

/**
 * @route   GET /api/classes/my-classes
 * @desc    Lấy danh sách lớp học của giáo viên
 * @access  Private (Teacher)
 */
router.get('/my-classes', isTeacherOrAdmin, classController.getMyClasses);

/**
 * @route   GET /api/classes/enrolled
 * @desc    Lấy danh sách lớp học mà học sinh tham gia
 * @access  Private (Student)
 */
router.get('/enrolled', classController.getEnrolledClasses);

/**
 * @route   GET /api/classes/teacher
 * @desc    Lấy danh sách lớp học của giáo viên (alias for my-classes)
 * @access  Private (Teacher)
 */
router.get('/teacher', isTeacherOrAdmin, classController.getMyClasses);

/**
 * @route   GET /api/classes/student
 * @desc    Lấy danh sách lớp học của học sinh (alias for enrolled)
 * @access  Private (Student)
 */
router.get('/student', classController.getEnrolledClasses);

/**
 * @route   POST /api/classes/join
 * @desc    Tham gia lớp học bằng mã lớp
 * @access  Private (Student)
 */
router.post('/join', classController.joinClass);

/**
 * @route   GET /api/classes/:id
 * @desc    Lấy thông tin chi tiết lớp học
 * @access  Private
 */
router.get('/:id', classController.getClassById);

/**
 * @route   PUT /api/classes/:id
 * @desc    Cập nhật thông tin lớp học
 * @access  Private (Teacher - owner)
 */
router.put('/:id', classController.updateClass);

/**
 * @route   DELETE /api/classes/:id
 * @desc    Xóa lớp học
 * @access  Private (Teacher - owner hoặc Admin)
 */
router.delete('/:id', classController.deleteClass);

/**
 * @route   DELETE /api/classes/:id/students/:studentId
 * @desc    Xóa học sinh khỏi lớp
 * @access  Private (Teacher - owner)
 */
router.delete('/:id/students/:studentId', classController.removeStudent);

/**
 * @route   POST /api/classes/:id/leave
 * @desc    Rời khỏi lớp học
 * @access  Private (Student)
 */
router.post('/:id/leave', classController.leaveClass);

/**
 * @route   GET /api/classes/:id/assignments
 * @desc    Lấy danh sách bài tập của lớp
 * @access  Private
 */
router.get('/:id/assignments', classController.getClassAssignments);

module.exports = router;
