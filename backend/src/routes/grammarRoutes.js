const express = require('express');
const { auth, isTeacherOrAdmin } = require('../middleware/auth');
const grammarQuestionController = require('../controllers/grammarQuestionController');
const grammarController = require('../controllers/grammarController');

const router = express.Router();

router.use(auth);

// Public routes (cho tất cả authenticated users)
router.get('/questions', grammarQuestionController.getQuestions);
router.get('/questions/random', grammarQuestionController.getRandomQuestions);
router.post('/questions/generate', grammarQuestionController.generateQuestions);

// Teacher routes - Tạo và quản lý câu hỏi
router.post('/teacher/questions', isTeacherOrAdmin, grammarController.createClassQuestion);
router.post('/class-questions', isTeacherOrAdmin, grammarQuestionController.createClassQuestion);
router.get('/my-questions', isTeacherOrAdmin, grammarQuestionController.getMyQuestions);
router.get('/class/:classId/questions', grammarController.getClassQuestions);
router.get('/class/:classId', grammarQuestionController.getClassQuestions);
router.put('/:questionId', isTeacherOrAdmin, grammarQuestionController.updateQuestion);
router.delete('/:questionId', isTeacherOrAdmin, grammarQuestionController.deleteQuestion);

// Student submission routes
router.post('/submit', grammarController.submitAnswers);
router.get('/submissions/:assignmentId', grammarController.getSubmission);
router.get('/class/:classId/submissions', isTeacherOrAdmin, grammarController.getClassSubmissions);

module.exports = router;
