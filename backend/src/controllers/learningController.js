const User = require('../models/User');
const { calculateLevel, getXPForNextLevel } = require('../services/gamificationService');
const { checkAndAwardBadges } = require('../services/badgeService');

/**
 * @desc    Mark word as learned and earn XP
 * @route   POST /api/learning/word-learned
 * @access  Private
 */
exports.markWordLearned = async (req, res) => {
  try {
    const { wordId } = req.body;
    const userId = req.user._id;

    if (!wordId) {
      return res.status(400).json({
        success: false,
        message: 'wordId is required',
      });
    }

    // Find user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Initialize learnedWords array if undefined
    if (!user.learnedWords) {
      user.learnedWords = [];
    }

    // Check if word already learned
    const alreadyLearned = user.learnedWords.some(
      (item) => item.wordId.toString() === wordId
    );

    if (alreadyLearned) {
      console.log(`⚠️  Word ${wordId} already learned by ${user.username}`);
      return res.status(400).json({
        success: false,
        message: 'Word already learned',
      });
    }

    // Check daily limit
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const lastLearningDate = user.lastLearningDate ? new Date(user.lastLearningDate) : null;
    let lastLearningDateNormalized = null;
    if (lastLearningDate) {
      lastLearningDateNormalized = new Date(lastLearningDate);
      lastLearningDateNormalized.setHours(0, 0, 0, 0);
    }
    
    const isNewDay = !lastLearningDateNormalized || lastLearningDateNormalized.getTime() < today.getTime();

    if (isNewDay) {
      // Reset daily count for new day
      user.wordsLearnedToday = 0;
      
      // Update streak BEFORE setting new lastLearningDate
      if (lastLearningDateNormalized) {
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        const daysDiff = Math.floor((today.getTime() - lastLearningDateNormalized.getTime()) / (1000 * 60 * 60 * 24));
        
        console.log(`📅 Streak check: lastLearning=${lastLearningDateNormalized.toISOString()}, today=${today.toISOString()}, daysDiff=${daysDiff}`);
        
        if (daysDiff === 1) {
          // Continuous streak - học liên tục
          user.streak = (user.streak || 0) + 1;
          console.log(`🔥 Streak increased to ${user.streak}`);
        } else if (daysDiff > 1) {
          // Streak broken - bỏ lỡ ngày
          console.log(`💔 Streak broken, resetting to 1`);
          user.streak = 1;
        }
        // daysDiff === 0 không thể xảy ra vì isNewDay đã check
      } else {
        // Lần đầu học
        user.streak = 1;
        console.log(`🆕 First time learning, streak = 1`);
      }
      
      // Set new lastLearningDate AFTER streak calculation
      user.lastLearningDate = today;
    }

    // Check if reached daily limit (30 words/day)
    const DAILY_LIMIT = 30;
    if (user.wordsLearnedToday >= DAILY_LIMIT) {
      return res.status(429).json({
        success: false,
        message: 'Daily word limit reached (30 words/day)',
        data: {
          wordsLearnedToday: user.wordsLearnedToday,
          remaining: 0,
        },
      });
    }

    // Award XP (5 XP per word)
    const XP_PER_WORD = 5;
    const oldLevel = user.level || 1;
    user.xp = (user.xp || 0) + XP_PER_WORD;
    
    // Calculate new level
    const newLevel = calculateLevel(user.xp);
    const leveledUp = newLevel > oldLevel;
    user.level = newLevel;

    // Add word to learned list
    user.learnedWords.push({
      wordId: wordId,
      learnedAt: new Date(),
    });

    // Update counters
    user.totalWordsLearned = (user.totalWordsLearned || 0) + 1;
    user.wordsLearnedToday = (user.wordsLearnedToday || 0) + 1;

    await user.save();
    
    console.log(`✅ Word learned! User: ${user.username}, XP: ${user.xp}, Level: ${user.level}, Total: ${user.totalWordsLearned}, Today: ${user.wordsLearnedToday}, Streak: ${user.streak}`);

    // Check for new badges after learning word
    let badgeResult = null;
    try {
      badgeResult = await checkAndAwardBadges(userId.toString(), 'learn_word');
    } catch (badgeError) {
      console.error('Error checking badges:', badgeError);
      // Don't fail the word learning if badge check fails
    }

    // Calculate remaining words for today
    const remaining = DAILY_LIMIT - user.wordsLearnedToday;

    res.status(200).json({
      success: true,
      message: leveledUp
        ? `🎉 Level Up! You are now Level ${newLevel}! (+${XP_PER_WORD} XP)`
        : `+${XP_PER_WORD} XP earned!`,
      data: {
        xpGained: XP_PER_WORD,
        totalXp: user.xp,
        level: newLevel,
        leveledUp: leveledUp,
        oldLevel: oldLevel,
        newLevel: newLevel,
        wordsLearnedToday: user.wordsLearnedToday,
        totalWordsLearned: user.totalWordsLearned,
        remaining: remaining,
        streak: user.streak,
        badges: badgeResult
      },
    });
  } catch (error) {
    console.error('Error marking word as learned:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

/**
 * @desc    Get learning progress
 * @route   GET /api/learning/progress
 * @access  Private
 */
exports.getProgress = async (req, res) => {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId).select(
      'xp level totalWordsLearned wordsLearnedToday lastLearningDate streak learnedWords'
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Check if new day
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const lastLearningDate = user.lastLearningDate ? new Date(user.lastLearningDate) : null;
    let lastLearningDateNormalized = null;
    if (lastLearningDate) {
      lastLearningDateNormalized = new Date(lastLearningDate);
      lastLearningDateNormalized.setHours(0, 0, 0, 0);
    }
    
    const isNewDay = !lastLearningDateNormalized || lastLearningDateNormalized.getTime() < today.getTime();

    let wordsLearnedToday = user.wordsLearnedToday || 0;
    let streak = user.streak || 0;

    if (isNewDay) {
      wordsLearnedToday = 0;
      
      // Kiểm tra nếu bỏ lỡ nhiều ngày thì streak = 0 (chưa học hôm nay)
      if (lastLearningDateNormalized) {
        const daysDiff = Math.floor((today.getTime() - lastLearningDateNormalized.getTime()) / (1000 * 60 * 60 * 24));
        if (daysDiff > 1) {
          // Bỏ lỡ nhiều ngày - streak sẽ reset về 1 khi học từ đầu tiên
          streak = 0;
        }
      }
    }

    const DAILY_LIMIT = 30;
    const remaining = Math.max(0, DAILY_LIMIT - wordsLearnedToday);
    const xpForNextLevel = getXPForNextLevel(user.level || 1);

    console.log(`📊 Progress requested: User: ${user.username}, XP: ${user.xp}, Level: ${user.level}, Total: ${user.totalWordsLearned}, Today: ${wordsLearnedToday}, Streak: ${streak}`);

    res.status(200).json({
      success: true,
      data: {
        xp: user.xp || 0,
        level: user.level || 1,
        totalWordsLearned: user.totalWordsLearned || 0,
        wordsLearnedToday: wordsLearnedToday,
        remaining: remaining,
        dailyLimit: DAILY_LIMIT,
        streak: streak,
        xpForNextLevel: xpForNextLevel,
        learnedWordsCount: user.learnedWords ? user.learnedWords.length : 0,
      },
    });
  } catch (error) {
    console.error('Error getting progress:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

/**
 * @desc    Get list of learned word IDs
 * @route   GET /api/learning/learned-words
 * @access  Private
 */
exports.getLearnedWords = async (req, res) => {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId).select('learnedWords');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Extract word IDs from learned words array
    const learnedWordIds = user.learnedWords
      ? user.learnedWords.map((item) => item.wordId.toString())
      : [];

    res.status(200).json({
      success: true,
      data: {
        learnedWordIds: learnedWordIds,
        count: learnedWordIds.length,
      },
    });
  } catch (error) {
    console.error('Error getting learned words:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};
