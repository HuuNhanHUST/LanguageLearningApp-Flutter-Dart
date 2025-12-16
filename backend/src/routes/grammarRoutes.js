const express = require('express');
const { auth } = require('../middleware/auth');
const grammarQuestionController = require('../controllers/grammarQuestionController');

const router = express.Router();

router.use(auth);

router.get('/questions', grammarQuestionController.getQuestions);
router.get('/questions/random', grammarQuestionController.getRandomQuestions);
router.post('/questions/generate', grammarQuestionController.generateQuestions);

module.exports = router;
