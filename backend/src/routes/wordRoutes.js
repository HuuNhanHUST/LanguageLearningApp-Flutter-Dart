const express = require('express');
const { body } = require('express-validator');
const wordController = require('../controllers/wordController');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Validation middleware for creating a word
const createWordValidation = [
  body('word')
    .notEmpty()
    .withMessage('Word is required')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Word must be between 1 and 100 characters'),
  body('meaning')
    .notEmpty()
    .withMessage('Meaning is required')
    .trim()
    .isLength({ min: 1, max: 500 })
    .withMessage('Meaning must be between 1 and 500 characters'),
  body('type')
    .optional()
    .isIn(['noun', 'verb', 'adj', 'adv', 'other'])
    .withMessage('Type must be one of: noun, verb, adj, adv, other'),
  body('example')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Example must not exceed 500 characters'),
  body('topic')
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage('Topic must not exceed 100 characters'),
];

const lookupValidation = [
  body('word')
    .notEmpty()
    .withMessage('Word is required')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Word must be between 1 and 100 characters'),
];

// All routes require authentication
router.use(auth);

// Word CRUD routes
router.post('/lookup', lookupValidation, wordController.lookupWord);
router.post('/create', createWordValidation, wordController.createWord);
router.get('/stats', wordController.getUserStats); // NEW: User stats
router.get('/due', wordController.getDueWords); // NEW: Words due for review
router.get('/', wordController.getWords);
router.get('/:id', wordController.getWordById);
router.put('/:id', wordController.updateWord);
router.delete('/:id', wordController.deleteWord);
router.patch('/:id/memorize', wordController.toggleMemorized);

module.exports = router;
