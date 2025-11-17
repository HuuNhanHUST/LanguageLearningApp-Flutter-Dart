const express = require('express');
const { body } = require('express-validator');
const userController = require('../controllers/userController');
const auth = require('../middleware/auth');

const router = express.Router();

// Validation middleware
const registerValidation = [
    body('username')
        .isLength({ min: 3, max: 30 })
        .withMessage('Username must be 3-30 characters long')
        .matches(/^[a-zA-Z0-9_]+$/)
        .withMessage('Username can only contain letters, numbers, and underscores'),
    body('email')
        .isEmail()
        .normalizeEmail()
        .withMessage('Please provide a valid email'),
    body('password')
        .isLength({ min: 6 })
        .withMessage('Password must be at least 6 characters long'),
    body('firstName')
        .notEmpty()
        .trim()
        .withMessage('First name is required'),
    body('lastName')
        .notEmpty()
        .trim()
        .withMessage('Last name is required')
];

const loginValidation = [
    body('email')
        .isEmail()
        .normalizeEmail()
        .withMessage('Please provide a valid email'),
    body('password')
        .notEmpty()
        .withMessage('Password is required')
];

// Public routes
router.post('/register', registerValidation, userController.register);
router.post('/login', loginValidation, userController.login);

// Protected routes (require authentication)
router.use(auth); // Apply auth middleware to all routes below

router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);
router.put('/change-password', userController.changePassword);
router.delete('/account', userController.deleteAccount);

// Language learning specific routes
router.post('/learning-languages', userController.addLearningLanguage);
router.delete('/learning-languages/:language', userController.removeLearningLanguage);
router.put('/preferences', userController.updatePreferences);

// Progress and statistics
router.get('/stats', userController.getUserStats);
router.put('/daily-goal', userController.updateDailyGoal);

module.exports = router;