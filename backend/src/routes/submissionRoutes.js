const express = require('express');
const router = express.Router();
const submissionController = require('../controllers/submissionController');
const { auth } = require('../middleware/auth');

// @route   POST /api/submissions
// @desc    Submit assignment
// @access  Private
router.post('/', auth, submissionController.submitAssignment);

// @route   GET /api/submissions/my/:assignmentId
// @desc    Get my submission for an assignment
// @access  Private
router.get('/my/:assignmentId', auth, submissionController.getMySubmission);

// @route   GET /api/submissions/check/:assignmentId
// @desc    Check if student has submitted
// @access  Private
router.get('/check/:assignmentId', auth, submissionController.checkSubmission);

// @route   GET /api/submissions/assignment/:assignmentId
// @desc    Get all submissions for an assignment (Teacher only)
// @access  Private (Teacher)
router.get('/assignment/:assignmentId', auth, submissionController.getAssignmentSubmissions);

module.exports = router;
