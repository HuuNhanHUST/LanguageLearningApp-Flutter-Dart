const express = require('express');
const { body, query } = require('express-validator');
const lessonController = require('../controllers/lessonController');
const auth = require('../middleware/auth');

const router = express.Router();

// Public routes (browsing lessons)
router.get('/', lessonController.getAllLessons);
router.get('/:id', lessonController.getLessonById);
router.get('/language/:language', lessonController.getLessonsByLanguage);
router.get('/category/:category', lessonController.getLessonsByCategory);

// Protected routes
router.use(auth);

// Lesson interaction routes
router.post('/:id/start', lessonController.startLesson);
router.post('/:id/complete', lessonController.completeLesson);
router.post('/:id/rate', lessonController.rateLesson);

// Search and filter routes
router.get('/search/query', lessonController.searchLessons);
router.get('/recommended/for-user', lessonController.getRecommendedLessons);

module.exports = router;