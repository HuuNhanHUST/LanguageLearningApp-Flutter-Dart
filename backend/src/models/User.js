const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: [true, 'Username is required'],
        unique: true,
        trim: true,
        minlength: [3, 'Username must be at least 3 characters'],
        maxlength: [30, 'Username cannot exceed 30 characters'],
        match: [/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores']
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        unique: true,
        lowercase: true,
        trim: true,
        match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email address']
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
        minlength: [6, 'Password must be at least 6 characters'],
        select: false // Don't return password by default
    },
    firstName: {
        type: String,
        required: [true, 'First name is required'],
        trim: true
    },
    lastName: {
        type: String,
        required: [true, 'Last name is required'],
        trim: true
    },
    avatar: {
        type: String,
        default: null
    },
    
    // Social Login Fields
    facebookId: {
        type: String,
        unique: true,
        sparse: true // Allow multiple null values (no default, will be undefined if not set)
    },
    googleId: {
        type: String,
        unique: true,
        sparse: true // Allow multiple null values (no default, will be undefined if not set)
    },
    provider: {
        type: String,
        enum: ['local', 'facebook', 'google'],
        default: 'local'
    },
    
    // Language Learning Specific Fields
    nativeLanguage: {
        type: String,
        default: 'en'
    },
    learningLanguages: [{
        language: String,
        level: {
            type: String,
            enum: ['beginner', 'intermediate', 'advanced'],
            default: 'beginner'
        },
        startedAt: {
            type: Date,
            default: Date.now
        }
    }],
    
    // Gamification Fields (for future sprints)
    xp: {
        type: Number,
        default: 0
    },
    level: {
        type: Number,
        default: 1
    },
    streak: {
        type: Number,
        default: 0
    },
    longestStreak: {
        type: Number,
        default: 0
    },
    lastActiveDate: {
        type: Date,
        default: Date.now
    },
    
    // Learning Progress Fields
    totalWordsLearned: {
        type: Number,
        default: 0
    },
    wordsLearnedToday: {
        type: Number,
        default: 0
    },
    flashcardLearnedToday: {
        type: Number,
        default: 0
    },
    pronunciationLearnedToday: {
        type: Number,
        default: 0
    },
    grammarQuestionsToday: {
        type: Number,
        default: 0
    },
    lastLearningDate: {
        type: Date,
        default: null
    },
    learnedWords: [{
        wordId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Word'
        },
        learnedAt: {
            type: Date,
            default: Date.now
        },
        timesReviewed: {
            type: Number,
            default: 0
        }
    }],
    
    // Badges - Achievement system
    badges: [{
        badgeId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Badge',
            required: true
        },
        earnedAt: {
            type: Date,
            default: Date.now
        }
    }],
    
    // Additional statistics for badge criteria
    lessonsCompleted: {
        type: Number,
        default: 0
    },
    perfectScores: {
        type: Number,
        default: 0
    },
    dailyGoalStreak: {
        type: Number,
        default: 0
    },
    
    // User Preferences
    preferences: {
        dailyGoal: {
            type: Number,
            default: 10 // minutes per day
        },
        notifications: {
            type: Boolean,
            default: true
        },
        soundEffects: {
            type: Boolean,
            default: true
        }
    },
    
    // Account Status
    isActive: {
        type: Boolean,
        default: true
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    
    // Security
    loginAttempts: {
        type: Number,
        default: 0
    },
    lockUntil: {
        type: Date
    },
    refreshTokens: [{
        token: String,
        createdAt: {
            type: Date,
            default: Date.now
        }
    }]
}, {
    timestamps: true // Adds createdAt and updatedAt
});

// Virtual for full name
userSchema.virtual('fullName').get(function() {
    return `${this.firstName} ${this.lastName}`;
});

// Indexes for performance optimization
// Note: email, username, facebookId, googleId already have unique: true in schema
// So we only need to add additional indexes here
// Learning languages index
userSchema.index({ 'learningLanguages.language': 1 });
// Index for leaderboard queries (DESC order for top scores)
userSchema.index({ xp: -1 });

// Check if account is locked
userSchema.virtual('isLocked').get(function() {
    return !!(this.lockUntil && this.lockUntil > Date.now());
});

// Pre-save middleware to hash password
userSchema.pre('save', async function(next) {
    // Only hash password if it's modified
    if (!this.isModified('password')) {
        return next();
    }
    
    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
    try {
        return await bcrypt.compare(candidatePassword, this.password);
    } catch (error) {
        throw new Error('Password comparison failed');
    }
};

// Method to generate JWT access token
userSchema.methods.generateAccessToken = function() {
    return jwt.sign(
        { 
            id: this._id,
            email: this.email,
            username: this.username
        },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );
};

// Method to generate JWT refresh token
userSchema.methods.generateRefreshToken = function() {
    const refreshToken = jwt.sign(
        { id: this._id },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_REFRESH_EXPIRE || '30d' }
    );
    
    // Initialize refreshTokens array if it doesn't exist
    if (!this.refreshTokens) {
        this.refreshTokens = [];
    }
    
    // Store refresh token in database
    this.refreshTokens.push({ token: refreshToken });
    
    // Keep only last 5 refresh tokens
    if (this.refreshTokens.length > 5) {
        this.refreshTokens = this.refreshTokens.slice(-5);
    }
    
    return refreshToken;
};

// Method to handle failed login attempts
userSchema.methods.incLoginAttempts = function() {
    // Reset attempts if lock has expired
    if (this.lockUntil && this.lockUntil < Date.now()) {
        return this.updateOne({
            $set: { loginAttempts: 1 },
            $unset: { lockUntil: 1 }
        });
    }
    
    const updates = { $inc: { loginAttempts: 1 } };
    const maxAttempts = parseInt(process.env.MAX_LOGIN_ATTEMPTS) || 5;
    const lockTime = parseInt(process.env.LOCK_TIME) || 15; // minutes
    
    // Lock account if max attempts reached
    if (this.loginAttempts + 1 >= maxAttempts && !this.isLocked) {
        updates.$set = { lockUntil: Date.now() + lockTime * 60 * 1000 };
    }
    
    return this.updateOne(updates);
};

// Method to reset login attempts
userSchema.methods.resetLoginAttempts = function() {
    return this.updateOne({
        $set: { loginAttempts: 0 },
        $unset: { lockUntil: 1 }
    });
};

// Method to get public profile
userSchema.methods.getPublicProfile = function() {
    return {
        id: this._id,
        username: this.username,
        email: this.email,
        firstName: this.firstName,
        lastName: this.lastName,
        avatar: this.avatar,
        nativeLanguage: this.nativeLanguage,
        learningLanguages: this.learningLanguages || [],
        xp: this.xp,
        level: this.level,
        streak: this.streak,
        preferences: {
            dailyGoal: this.preferences?.dailyGoal || 10,
            notifications: this.preferences?.notifications !== false,
            soundEffects: this.preferences?.soundEffects !== false
        },
        createdAt: this.createdAt
    };
};

const User = mongoose.model('User', userSchema);

module.exports = User;
