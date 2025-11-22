const { validationResult } = require('express-validator');
const User = require('../models/User');
const axios = require('axios');
const crypto = require('crypto');
const { OAuth2Client } = require('google-auth-library');

/**
 * @desc    Register new user
 * @route   POST /api/users/register
 * @access  Public
 */
exports.register = async (req, res) => {
    try {
        // Validate input
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: errors.array()
            });
        }
        
        const { username, email, password, firstName, lastName, nativeLanguage } = req.body;
        
        // Check if user already exists
        const existingUser = await User.findOne({
            $or: [{ email }, { username }]
        });
        
        if (existingUser) {
            const field = existingUser.email === email ? 'Email' : 'Username';
            return res.status(400).json({
                success: false,
                message: `${field} already exists. Please use a different ${field.toLowerCase()}.`
            });
        }
        
        // Create new user
        const user = new User({
            username,
            email,
            password,
            firstName,
            lastName,
            nativeLanguage: nativeLanguage || 'en'
        });
        
        await user.save();
        
        // Generate tokens
        const accessToken = user.generateAccessToken();
        const refreshToken = user.generateRefreshToken();
        await user.save(); // Save refresh token
        
        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
                user: user.getPublicProfile(),
                accessToken,
                refreshToken
            }
        });
        
    } catch (error) {
        console.error('Register error:', error);
        res.status(500).json({
            success: false,
            message: 'Registration failed. Please try again.',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Login user
 * @route   POST /api/users/login
 * @access  Public
 */
exports.login = async (req, res) => {
    try {
        // Validate input
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: errors.array()
            });
        }
        
        const { email, password } = req.body;
        
        // Find user (include password for comparison)
        const user = await User.findOne({ email }).select('+password');
        
        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password.'
            });
        }
        
        // Check if account is locked
        if (user.isLocked) {
            const lockTimeRemaining = Math.ceil((user.lockUntil - Date.now()) / 60000);
            return res.status(423).json({
                success: false,
                message: `Account is locked. Please try again in ${lockTimeRemaining} minutes.`
            });
        }
        
        // Verify password
        const isPasswordValid = await user.comparePassword(password);
        
        if (!isPasswordValid) {
            // Increment login attempts
            await user.incLoginAttempts();
            
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password.'
            });
        }
        
        // Check if account is active
        if (!user.isActive) {
            return res.status(403).json({
                success: false,
                message: 'Account has been deactivated. Please contact support.'
            });
        }
        
        // Reset login attempts on successful login
        if (user.loginAttempts > 0) {
            await user.resetLoginAttempts();
        }
        
        // Update last active date
        user.lastActiveDate = Date.now();
        
        // Generate tokens
        const accessToken = user.generateAccessToken();
        const refreshToken = user.generateRefreshToken();
        await user.save();
        
        res.status(200).json({
            success: true,
            message: 'Login successful',
            data: {
                user: user.getPublicProfile(),
                accessToken,
                refreshToken
            }
        });
        
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Login failed. Please try again.',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Get user profile
 * @route   GET /api/users/profile
 * @access  Private
 */
exports.getProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        res.status(200).json({
            success: true,
            data: {
                user: user.getPublicProfile()
            }
        });
        
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to retrieve profile',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Update user profile
 * @route   PUT /api/users/profile
 * @access  Private
 */
exports.updateProfile = async (req, res) => {
    try {
        const allowedUpdates = ['firstName', 'lastName', 'avatar', 'nativeLanguage'];
        const updates = {};
        
        // Filter allowed updates
        Object.keys(req.body).forEach(key => {
            if (allowedUpdates.includes(key)) {
                updates[key] = req.body[key];
            }
        });
        
        const user = await User.findByIdAndUpdate(
            req.user._id,
            { $set: updates },
            { new: true, runValidators: true }
        );
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            data: {
                user: user.getPublicProfile()
            }
        });
        
    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update profile',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Change password
 * @route   PUT /api/users/change-password
 * @access  Private
 */
exports.changePassword = async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;
        
        if (!currentPassword || !newPassword) {
            return res.status(400).json({
                success: false,
                message: 'Current password and new password are required'
            });
        }
        
        if (newPassword.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'New password must be at least 6 characters'
            });
        }
        
        // Get user with password
        const user = await User.findById(req.user._id).select('+password');
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        // Verify current password
        const isPasswordValid = await user.comparePassword(currentPassword);
        
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Current password is incorrect'
            });
        }
        
        // Update password
        user.password = newPassword;
        
        // Clear refresh tokens for security
        user.refreshTokens = [];
        
        await user.save();
        
        // Generate new tokens
        const accessToken = user.generateAccessToken();
        const refreshToken = user.generateRefreshToken();
        await user.save();
        
        res.status(200).json({
            success: true,
            message: 'Password changed successfully. Please login with new credentials.',
            data: {
                accessToken,
                refreshToken
            }
        });
        
    } catch (error) {
        console.error('Change password error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to change password',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Delete user account
 * @route   DELETE /api/users/account
 * @access  Private
 */
exports.deleteAccount = async (req, res) => {
    try {
        const { password } = req.body;
        
        if (!password) {
            return res.status(400).json({
                success: false,
                message: 'Password is required to delete account'
            });
        }
        
        // Get user with password
        const user = await User.findById(req.user._id).select('+password');
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        // Verify password
        const isPasswordValid = await user.comparePassword(password);
        
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Incorrect password'
            });
        }
        
        // Soft delete: deactivate account instead of deleting
        user.isActive = false;
        user.refreshTokens = [];
        await user.save();
        
        res.status(200).json({
            success: true,
            message: 'Account deactivated successfully'
        });
        
    } catch (error) {
        console.error('Delete account error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete account',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Add learning language
 * @route   POST /api/users/learning-languages
 * @access  Private
 */
exports.addLearningLanguage = async (req, res) => {
    try {
        const { language, level } = req.body;
        
        if (!language) {
            return res.status(400).json({
                success: false,
                message: 'Language is required'
            });
        }
        
        const user = await User.findById(req.user._id);
        
        // Check if language already exists
        const existingLanguage = user.learningLanguages.find(
            l => l.language === language
        );
        
        if (existingLanguage) {
            return res.status(400).json({
                success: false,
                message: 'Language already in your learning list'
            });
        }
        
        user.learningLanguages.push({
            language,
            level: level || 'beginner'
        });
        
        await user.save();
        
        res.status(200).json({
            success: true,
            message: 'Language added successfully',
            data: {
                learningLanguages: user.learningLanguages
            }
        });
        
    } catch (error) {
        console.error('Add learning language error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to add language',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Remove learning language
 * @route   DELETE /api/users/learning-languages/:language
 * @access  Private
 */
exports.removeLearningLanguage = async (req, res) => {
    try {
        const { language } = req.params;
        
        const user = await User.findById(req.user._id);
        
        user.learningLanguages = user.learningLanguages.filter(
            l => l.language !== language
        );
        
        await user.save();
        
        res.status(200).json({
            success: true,
            message: 'Language removed successfully',
            data: {
                learningLanguages: user.learningLanguages
            }
        });
        
    } catch (error) {
        console.error('Remove learning language error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to remove language',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Update user preferences
 * @route   PUT /api/users/preferences
 * @access  Private
 */
exports.updatePreferences = async (req, res) => {
    try {
        const { dailyGoal, notifications, soundEffects } = req.body;
        
        const updates = {};
        if (dailyGoal !== undefined) updates['preferences.dailyGoal'] = dailyGoal;
        if (notifications !== undefined) updates['preferences.notifications'] = notifications;
        if (soundEffects !== undefined) updates['preferences.soundEffects'] = soundEffects;
        
        const user = await User.findByIdAndUpdate(
            req.user._id,
            { $set: updates },
            { new: true }
        );
        
        res.status(200).json({
            success: true,
            message: 'Preferences updated successfully',
            data: {
                preferences: user.preferences
            }
        });
        
    } catch (error) {
        console.error('Update preferences error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update preferences',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Get user statistics
 * @route   GET /api/users/stats
 * @access  Private
 */
exports.getUserStats = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        
        res.status(200).json({
            success: true,
            data: {
                xp: user.xp,
                level: user.level,
                streak: user.streak,
                learningLanguages: user.learningLanguages,
                lastActiveDate: user.lastActiveDate,
                preferences: user.preferences
            }
        });
        
    } catch (error) {
        console.error('Get user stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to retrieve statistics',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Update daily goal
 * @route   PUT /api/users/daily-goal
 * @access  Private
 */
exports.updateDailyGoal = async (req, res) => {
    try {
        const { dailyGoal } = req.body;
        
        if (!dailyGoal || dailyGoal < 1) {
            return res.status(400).json({
                success: false,
                message: 'Daily goal must be at least 1 minute'
            });
        }
        
        const user = await User.findByIdAndUpdate(
            req.user._id,
            { $set: { 'preferences.dailyGoal': dailyGoal } },
            { new: true }
        );
        
        res.status(200).json({
            success: true,
            message: 'Daily goal updated successfully',
            data: {
                dailyGoal: user.preferences.dailyGoal
            }
        });
        
    } catch (error) {
        console.error('Update daily goal error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update daily goal',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Login with Facebook
 * @route   POST /api/auth/facebook
 * @access  Public
 */
exports.facebookLogin = async (req, res) => {
    try {
        const { facebookToken } = req.body;

        if (!facebookToken) {
            return res.status(400).json({
                success: false,
                message: 'Facebook token is required'
            });
        }

        console.log('🔐 Facebook Login Request');
        console.log('Token received:', facebookToken.substring(0, 20) + '...');

        // Verify token with Facebook Graph API
        let facebookUser;
        try {
            console.log('📱 Calling Facebook Graph API...');
            const response = await axios.get(
                `https://graph.facebook.com/me`,
                {
                    params: {
                        fields: 'id,name,picture,first_name,last_name',
                        access_token: facebookToken
                    }
                }
            );
            facebookUser = response.data;
            console.log('✅ Facebook API Response:', facebookUser);
        } catch (error) {
            console.error('❌ Facebook token verification failed:', error.response?.data || error.message);
            return res.status(401).json({
                success: false,
                message: 'Invalid Facebook token',
                error: error.response?.data?.error?.message
            });
        }

        // Check if user already exists by Facebook ID
        let user = await User.findOne({
            facebookId: facebookUser.id
        });

        if (user) {
            // Existing user - just generate tokens
            const accessToken = user.generateAccessToken();
            const refreshToken = user.generateRefreshToken();
            await user.save();

            return res.status(200).json({
                success: true,
                message: 'Facebook login successful',
                data: {
                    user: user.getPublicProfile(),
                    accessToken,
                    refreshToken
                }
            });
        }

        // Check if user exists by email
        if (facebookUser.email) {
            user = await User.findOne({ email: facebookUser.email });
            
            if (user) {
                // Link Facebook account to existing user
                user.facebookId = facebookUser.id;
                user.provider = 'facebook';
                await user.save();

                const accessToken = user.generateAccessToken();
                const refreshToken = user.generateRefreshToken();
                await user.save();

                return res.status(200).json({
                    success: true,
                    message: 'Facebook login successful',
                    data: {
                        user: user.getPublicProfile(),
                        accessToken,
                        refreshToken
                    }
                });
            }
        }

        // Create new user from Facebook login
        const username = `fb_${facebookUser.id.substring(0, 8)}`;
        const email = facebookUser.email || `${username}@facebook.local`;
        const firstName = facebookUser.first_name || facebookUser.name || 'Facebook';
        const lastName = facebookUser.last_name || 'User';
        
        // Generate random password for social login
        const crypto = require('crypto');
        const randomPassword = crypto.randomBytes(16).toString('hex');

        user = new User({
            username,
            email,
            password: randomPassword,
            firstName,
            lastName,
            facebookId: facebookUser.id,
            provider: 'facebook',
            avatar: facebookUser.picture?.data?.url || null
        });

        await user.save();

        // Generate tokens
        const accessToken = user.generateAccessToken();
        const refreshToken = user.generateRefreshToken();
        await user.save();

        res.status(201).json({
            success: true,
            message: 'User created and logged in with Facebook successfully',
            data: {
                user: user.getPublicProfile(),
                accessToken,
                refreshToken
            }
        });

    } catch (error) {
        console.error('Facebook login error:', error);
        res.status(500).json({
            success: false,
            message: 'Facebook login failed',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * @desc    Login with Google
 * @route   POST /api/auth/google
 * @access  Public
 */
exports.googleLogin = async (req, res) => {
    try {
        const { googleToken } = req.body;

        if (!googleToken) {
            return res.status(400).json({
                success: false,
                message: 'Google token is required'
            });
        }

        console.log('🔐 Google Login Request');

        const clientId = process.env.GOOGLE_CLIENT_ID;
        if (!clientId) {
            console.error('Missing GOOGLE_CLIENT_ID in environment');
            return res.status(500).json({ success: false, message: 'Server not configured for Google sign-in' });
        }

        const client = new OAuth2Client(clientId);
        let payload;
        try {
            const ticket = await client.verifyIdToken({ idToken: googleToken, audience: clientId });
            payload = ticket.getPayload();
            console.log('✅ Google token verified:', { sub: payload.sub, email: payload.email });
        } catch (err) {
            console.error('❌ Google token verification failed:', err.message || err);
            return res.status(401).json({ success: false, message: 'Invalid Google token' });
        }

        // payload contains user info
        const googleId = payload.sub;

        // Check if user already exists by Google ID
        let user = await User.findOne({ googleId });

        if (user) {
            const accessToken = user.generateAccessToken();
            const refreshToken = user.generateRefreshToken();
            await user.save();

            return res.status(200).json({
                success: true,
                message: 'Google login successful',
                data: {
                    user: user.getPublicProfile(),
                    accessToken,
                    refreshToken
                }
            });
        }

        // If email exists, link to existing user
        if (payload.email) {
            user = await User.findOne({ email: payload.email });
            if (user) {
                user.googleId = googleId;
                user.provider = 'google';
                await user.save();

                const accessToken = user.generateAccessToken();
                const refreshToken = user.generateRefreshToken();
                await user.save();

                return res.status(200).json({
                    success: true,
                    message: 'Google login successful',
                    data: {
                        user: user.getPublicProfile(),
                        accessToken,
                        refreshToken
                    }
                });
            }
        }

        // Create new user
        const username = `gp_${googleId.substring(0, 8)}`;
        const email = payload.email || `${username}@google.local`;
        const firstName = payload.given_name || payload.name || 'Google';
        const lastName = payload.family_name || '';

        const randomPassword = crypto.randomBytes(16).toString('hex');

        user = new User({
            username,
            email,
            password: randomPassword,
            firstName,
            lastName,
            googleId,
            provider: 'google',
            avatar: payload.picture || null
        });

        await user.save();

        const accessToken = user.generateAccessToken();
        const refreshToken = user.generateRefreshToken();
        await user.save();

        res.status(201).json({
            success: true,
            message: 'User created and logged in with Google successfully',
            data: {
                user: user.getPublicProfile(),
                accessToken,
                refreshToken
            }
        });

    } catch (error) {
        console.error('Google login error:', error);
        res.status(500).json({
            success: false,
            message: 'Google login failed',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};
