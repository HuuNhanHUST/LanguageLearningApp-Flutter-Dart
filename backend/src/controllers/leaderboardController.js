const User = require('../models/User');

/**
 * @desc    Get top 100 users by XP
 * @route   GET /api/leaderboard/top100
 * @access  Private
 */
const getTop100 = async (req, res) => {
  try {
    const startTime = Date.now();

    // Query top 100 users sorted by XP (descending)
    // Only select necessary fields for performance and security
    const topUsers = await User.find({ isActive: true })
      .select('username avatar xp level streak createdAt')
      .sort({ xp: -1 })
      .limit(100)
      .lean(); // Use lean() for better performance (returns plain JS objects)

    // Calculate current user's rank (optional)
    let currentUserRank = null;
    if (req.user) {
      const currentUser = await User.findById(req.user.id).select('xp');
      
      if (currentUser) {
        // Count how many users have more XP than current user
        const usersAbove = await User.countDocuments({
          xp: { $gt: currentUser.xp },
          isActive: true
        });
        currentUserRank = usersAbove + 1;
      }
    }

    // Add rank to each user in the leaderboard
    const leaderboard = topUsers.map((user, index) => ({
      rank: index + 1,
      userId: user._id,
      username: user.username,
      avatar: user.avatar,
      xp: user.xp,
      level: user.level,
      streak: user.streak,
      joinedAt: user.createdAt
    }));

    const responseTime = Date.now() - startTime;

    res.status(200).json({
      success: true,
      data: {
        leaderboard,
        currentUserRank,
        totalUsers: topUsers.length,
        responseTime: `${responseTime}ms`
      }
    });
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch leaderboard',
      error: error.message
    });
  }
};

/**
 * @desc    Get user's current rank
 * @route   GET /api/leaderboard/my-rank
 * @access  Private
 */
const getMyRank = async (req, res) => {
  try {
    const currentUser = await User.findById(req.user.id).select('username avatar xp level streak');

    if (!currentUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Count users with more XP
    const usersAbove = await User.countDocuments({
      xp: { $gt: currentUser.xp },
      isActive: true
    });

    const rank = usersAbove + 1;

    // Get total active users for percentage calculation
    const totalUsers = await User.countDocuments({ isActive: true });

    res.status(200).json({
      success: true,
      data: {
        rank,
        username: currentUser.username,
        avatar: currentUser.avatar,
        xp: currentUser.xp,
        level: currentUser.level,
        streak: currentUser.streak,
        totalUsers,
        percentile: totalUsers > 0 ? ((totalUsers - rank + 1) / totalUsers * 100).toFixed(2) : 0
      }
    });
  } catch (error) {
    console.error('Error fetching user rank:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user rank',
      error: error.message
    });
  }
};

module.exports = {
  getTop100,
  getMyRank
};
