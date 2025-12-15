const mongoose = require('mongoose');

/**
 * Badge Model - Achievement Badges
 * Defines badges that users can earn by reaching milestones
 */
const badgeSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Badge name is required'],
        unique: true,
        trim: true
    },
    description: {
        type: String,
        required: [true, 'Badge description is required'],
        trim: true
    },
    iconUrl: {
        type: String,
        required: [true, 'Badge icon URL is required'],
        trim: true
    },
    
    // Criteria for earning the badge
    criteria: {
        // Type of criteria: 'xp', 'words_learned', 'streak', 'lessons_completed', 'perfect_scores'
        type: {
            type: String,
            required: true,
            enum: ['xp', 'words_learned', 'streak', 'lessons_completed', 'perfect_scores', 'daily_goal', 'level']
        },
        
        // Target value to reach
        target: {
            type: Number,
            required: true,
            min: 1
        },
        
        // Optional: Additional conditions
        conditions: {
            type: Map,
            of: mongoose.Schema.Types.Mixed,
            default: {}
        }
    },
    
    // Badge rarity/category
    category: {
        type: String,
        enum: ['bronze', 'silver', 'gold', 'platinum', 'special'],
        default: 'bronze'
    },
    
    // Order for display
    displayOrder: {
        type: Number,
        default: 0
    },
    
    // Is this badge currently active/available
    isActive: {
        type: Boolean,
        default: true
    },
    
    // XP bonus when earning this badge (optional)
    xpBonus: {
        type: Number,
        default: 0,
        min: 0
    }
}, {
    timestamps: true
});

// Indexes
badgeSchema.index({ 'criteria.type': 1 });
badgeSchema.index({ category: 1 });
badgeSchema.index({ isActive: 1 });
badgeSchema.index({ displayOrder: 1 });

// Virtual for badge tier/level (based on target)
badgeSchema.virtual('tier').get(function() {
    if (this.criteria.target >= 1000) return 'expert';
    if (this.criteria.target >= 500) return 'advanced';
    if (this.criteria.target >= 100) return 'intermediate';
    return 'beginner';
});

// Method to check if user meets criteria
badgeSchema.methods.checkCriteria = function(userStats) {
    const { type, target } = this.criteria;
    
    switch (type) {
        case 'xp':
            return userStats.xp >= target;
        
        case 'words_learned':
            return userStats.totalWordsLearned >= target;
        
        case 'streak':
            return userStats.streak >= target;
        
        case 'lessons_completed':
            return userStats.lessonsCompleted >= target;
        
        case 'perfect_scores':
            return userStats.perfectScores >= target;
        
        case 'daily_goal':
            return userStats.dailyGoalStreak >= target;
        
        case 'level':
            return userStats.level >= target;
        
        default:
            return false;
    }
};

// Static method to get all active badges
badgeSchema.statics.getActiveBadges = async function() {
    return await this.find({ isActive: true }).sort({ displayOrder: 1, 'criteria.target': 1 });
};

// Static method to get badges by category
badgeSchema.statics.getBadgesByCategory = async function(category) {
    return await this.find({ isActive: true, category }).sort({ displayOrder: 1, 'criteria.target': 1 });
};

const Badge = mongoose.model('Badge', badgeSchema);

module.exports = Badge;
