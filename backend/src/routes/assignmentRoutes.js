const express = require('express');
const router = express.Router();
const { 
    createAssignment, 
    getClassAssignments, 
    getAssignmentById,
    deleteAssignment,
    togglePublish
} = require('../controllers/assignmentController');
const { auth, isTeacherOrAdmin } = require('../middleware/auth');

router.use(auth);

// Teacher routes
router.post('/', isTeacherOrAdmin, createAssignment);
router.delete('/:id', isTeacherOrAdmin, deleteAssignment);
router.put('/:id/publish', isTeacherOrAdmin, togglePublish);

// Public routes (students + teachers)
router.get('/class/:classId', getClassAssignments);
router.get('/:id', getAssignmentById);

module.exports = router;
