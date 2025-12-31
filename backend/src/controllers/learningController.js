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
      user.flashcardLearnedToday = 0;
      user.pronunciationLearnedToday = 0;
      
      // Update streak BEFORE setting new lastLearningDate
      if (lastLearningDateNormalized) {
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        const daysDiff = Math.floor((today.getTime() - lastLearningDateNormalized.getTime()) / (1000 * 60 * 60 * 24));
        
        console.log(`📅 Streak check: lastLearning=${lastLearningDateNormalized.toISOString()}, today=${today.toISOString()}, daysDiff=${daysDiff}`);
        
        if (daysDiff === 1) {
          // Continuous streak - học liên tục
          user.streak = (user.streak || 0) + 1;
          // Update longest streak if current is higher
          if (user.streak > (user.longestStreak || 0)) {
            user.longestStreak = user.streak;
            console.log(`🏆 New longest streak: ${user.longestStreak}`);
          }
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
        if (!user.longestStreak || user.longestStreak < 1) {
          user.longestStreak = 1;
        }
        console.log(`🆕 First time learning, streak = 1`);
      }
      
      // Set new lastLearningDate AFTER streak calculation
      user.lastLearningDate = today;
    }

    // Check daily limit based on lessonType
    const FLASHCARD_LIMIT = 20;
    const PRONUNCIATION_LIMIT = 10;
    const lessonType = req.body.lessonType || 'pronunciation'; // default pronunciation for backward compatibility
    
    if (lessonType === 'flashcard') {
      if (user.flashcardLearnedToday >= FLASHCARD_LIMIT) {
        return res.status(429).json({
          success: false,
          message: 'Đã hoàn thành 20 flashcards hôm nay!',
          data: {
            flashcardLearnedToday: user.flashcardLearnedToday,
            flashcardRemaining: 0,
          },
        });
      }
    } else if (lessonType === 'pronunciation') {
      if (user.pronunciationLearnedToday >= PRONUNCIATION_LIMIT) {
        return res.status(429).json({
          success: false,
          message: 'Đã hoàn thành 10 từ phát âm hôm nay!',
          data: {
            pronunciationLearnedToday: user.pronunciationLearnedToday,
            pronunciationRemaining: 0,
          },
        });
      }
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

    // Update counters based on lessonType
    user.totalWordsLearned = (user.totalWordsLearned || 0) + 1;
    user.wordsLearnedToday = (user.wordsLearnedToday || 0) + 1;
    
    if (lessonType === 'flashcard') {
      user.flashcardLearnedToday = (user.flashcardLearnedToday || 0) + 1;
    } else if (lessonType === 'pronunciation') {
      user.pronunciationLearnedToday = (user.pronunciationLearnedToday || 0) + 1;
    }

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
    const TOTAL_LIMIT = 30;
    const remaining = TOTAL_LIMIT - user.wordsLearnedToday;
    const flashcardRemaining = FLASHCARD_LIMIT - (user.flashcardLearnedToday || 0);
    const pronunciationRemaining = PRONUNCIATION_LIMIT - (user.pronunciationLearnedToday || 0);

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
        flashcardLearnedToday: user.flashcardLearnedToday || 0,
        pronunciationLearnedToday: user.pronunciationLearnedToday || 0,
        totalWordsLearned: user.totalWordsLearned,
        remaining: remaining,
        flashcardRemaining: flashcardRemaining,
        pronunciationRemaining: pronunciationRemaining,
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
 * @desc    Add XP only (for grammar practice - không đánh dấu từ là đã học)
 * @route   POST /api/learning/xp-only
 * @access  Private
 */
exports.addXpOnly = async (req, res) => {
  try {
    const { xpAmount, activityType, difficulty } = req.body;
    const userId = req.user._id;

    if (!xpAmount || typeof xpAmount !== 'number' || xpAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid xpAmount',
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

    // Check if new day for grammar questions
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
      // Reset daily grammar count for new day
      user.grammarQuestionsToday = 0;
    }

    // Check daily limit for grammar (10 questions/day)
    const GRAMMAR_DAILY_LIMIT = 10;
    if (user.grammarQuestionsToday >= GRAMMAR_DAILY_LIMIT) {
      return res.status(429).json({
        success: false,
        message: '🎉 Đã hoàn thành 10 câu ngữ pháp hôm nay! Quay lại vào ngày mai nhé!',
        data: {
          grammarQuestionsToday: user.grammarQuestionsToday,
          grammarDailyLimit: GRAMMAR_DAILY_LIMIT,
        },
      });
    }

    // Award XP
    const oldLevel = user.level || 1;
    user.xp = (user.xp || 0) + xpAmount;
    
    // Calculate new level
    const newLevel = calculateLevel(user.xp);
    const leveledUp = newLevel > oldLevel;
    user.level = newLevel;

    // Increment grammar questions count
    user.grammarQuestionsToday = (user.grammarQuestionsToday || 0) + 1;

    await user.save();
    
    console.log(`✅ XP only added! User: ${user.username}, XP: +${xpAmount}, Total XP: ${user.xp}, Level: ${user.level}, Grammar today: ${user.grammarQuestionsToday}/${GRAMMAR_DAILY_LIMIT}`);

    res.status(200).json({
      success: true,
      message: leveledUp
        ? `🎉 Level Up! You are now Level ${newLevel}! (+${xpAmount} XP)`
        : `+${xpAmount} XP earned!`,
      data: {
        xpGained: xpAmount,
        totalXp: user.xp,
        level: newLevel,
        leveledUp: leveledUp,
        oldLevel: oldLevel,
        newLevel: newLevel,
        grammarQuestionsToday: user.grammarQuestionsToday,
        grammarDailyLimit: GRAMMAR_DAILY_LIMIT,
      },
    });
  } catch (error) {
    console.error('Error adding XP:', error);
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
      'xp level totalWordsLearned wordsLearnedToday flashcardLearnedToday pronunciationLearnedToday grammarQuestionsToday lastLearningDate streak learnedWords'
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
    let flashcardLearnedToday = user.flashcardLearnedToday || 0;
    let pronunciationLearnedToday = user.pronunciationLearnedToday || 0;
    let grammarQuestionsToday = user.grammarQuestionsToday || 0;
    let streak = user.streak || 0;

    if (isNewDay) {
      wordsLearnedToday = 0;
      flashcardLearnedToday = 0;
      pronunciationLearnedToday = 0;
      grammarQuestionsToday = 0;
      
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
    const FLASHCARD_LIMIT = 20;
    const PRONUNCIATION_LIMIT = 10;
    const GRAMMAR_DAILY_LIMIT = 10;
    const remaining = Math.max(0, DAILY_LIMIT - wordsLearnedToday);
    const flashcardRemaining = Math.max(0, FLASHCARD_LIMIT - flashcardLearnedToday);
    const pronunciationRemaining = Math.max(0, PRONUNCIATION_LIMIT - pronunciationLearnedToday);
    const grammarRemaining = Math.max(0, GRAMMAR_DAILY_LIMIT - grammarQuestionsToday);
    const xpForNextLevel = getXPForNextLevel(user.level || 1);

    console.log(`📊 Progress: User: ${user.username}, Total: ${wordsLearnedToday}/30, Flashcard: ${flashcardLearnedToday}/20, Pronunciation: ${pronunciationLearnedToday}/10, Grammar: ${grammarQuestionsToday}/10`);

    res.status(200).json({
      success: true,
      data: {
        xp: user.xp || 0,
        level: user.level || 1,
        totalWordsLearned: user.totalWordsLearned || 0,
        wordsLearnedToday: wordsLearnedToday,
        remaining: remaining,
        dailyLimit: DAILY_LIMIT,
        flashcardLearnedToday: flashcardLearnedToday,
        flashcardRemaining: flashcardRemaining,
        flashcardLimit: FLASHCARD_LIMIT,
        pronunciationLearnedToday: pronunciationLearnedToday,
        pronunciationRemaining: pronunciationRemaining,
        pronunciationLimit: PRONUNCIATION_LIMIT,
        grammarQuestionsToday: grammarQuestionsToday,
        grammarRemaining: grammarRemaining,
        grammarDailyLimit: GRAMMAR_DAILY_LIMIT,
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

/**
 * @desc    Get today's learning progress
 * @route   GET /api/learning/today-progress
 * @access  Private
 */
exports.getTodayProgress = async (req, res) => {
  try {
    const userId = req.user._id;
    const user = await User.findById(userId).select(
      'learnedWords pronunciationHistory streak lastLearningDate wordsLearnedToday'
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Get today's start and end
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Filter words learned today
    const wordsLearnedToday = user.learnedWords?.filter(item => {
      const learnedDate = new Date(item.learnedAt);
      return learnedDate >= today && learnedDate < tomorrow;
    }) || [];

    // Filter pronunciation practiced today
    const pronunciationToday = user.pronunciationHistory?.filter(item => {
      const practiceDate = new Date(item.practiceDate);
      return practiceDate >= today && practiceDate < tomorrow;
    }) || [];

    // Calculate XP earned today (10 XP per word + pronunciation bonuses)
    const xpFromWords = wordsLearnedToday.length * 10;
    const xpFromPronunciation = pronunciationToday.reduce((sum, item) => {
      if (item.score >= 80) return sum + 5;
      if (item.score >= 60) return sum + 3;
      return sum + 1;
    }, 0);

    // Calculate study time (estimate: 2 minutes per word + 1 minute per pronunciation)
    const minutesStudied = (wordsLearnedToday.length * 2) + pronunciationToday.length;

    // Get longest streak
    const longestStreak = user.longestStreak || user.streak || 0;

    res.status(200).json({
      success: true,
      data: {
        wordsLearnedToday: wordsLearnedToday.length,
        pronunciationPracticedToday: pronunciationToday.length,
        xpEarnedToday: xpFromWords + xpFromPronunciation,
        minutesStudiedToday: minutesStudied,
        currentStreak: user.streak || 0,
        longestStreak: longestStreak,
        vocabularyDetails: wordsLearnedToday.map(w => ({
          word: w.word || 'Unknown',
          learnedAt: w.learnedAt,
        })),
        pronunciationDetails: pronunciationToday.map(p => ({
          word: p.word || 'Unknown',
          score: p.score || 0,
          practiceDate: p.practiceDate,
        })),
      },
    });
  } catch (error) {
    console.error('Error getting today progress:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};
