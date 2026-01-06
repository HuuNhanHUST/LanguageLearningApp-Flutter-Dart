const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * JWT Authentication Middleware
 * Verifies JWT token and attaches user to request object
 */
const auth = async (req, res, next) => {
    try {
        // Get token from header
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'Access denied. No token provided.'
            });
        }
        
        // Extract token
        const token = authHeader.split(' ')[1];
        
        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Access denied. Invalid token format.'
            });
        }
        
        try {
            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            
            // Get user from database (exclude password)
            const user = await User.findById(decoded.id).select('-password');
            
            if (!user) {
                return res.status(401).json({
                    success: false,
                    message: 'User not found. Token is invalid.'
                });
            }
            
            if (!user.isActive) {
                return res.status(401).json({
                    success: false,
                    message: 'Account has been deactivated.'
                });
            }
            
            // Attach user to request object
            req.user = user;
            next();
            
        } catch (error) {
            if (error.name === 'JsonWebTokenError') {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid token.'
                });
            }
            
            if (error.name === 'TokenExpiredError') {
                return res.status(401).json({
                    success: false,
                    message: 'Token has expired. Please login again.'
                });
            }
            
            throw error;
        }
        
    } catch (error) {
        console.error('Auth middleware error:', error);
        return res.status(500).json({
            success: false,
            message: 'Authentication failed.',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

/**
 * Optional Authentication Middleware
 * Attaches user if token is valid, but doesn't block if no token
 */
const optionalAuth = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return next();
        }
        
        const token = authHeader.split(' ')[1];
        
        if (!token) {
            return next();
        }
        
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const user = await User.findById(decoded.id).select('-password');
            
            if (user && user.isActive) {
                req.user = user;
            }
        } catch (error) {
            // Silently fail for optional auth
            console.log('Optional auth failed:', error.message);
        }
        
        next();
        
    } catch (error) {
        console.error('Optional auth middleware error:', error);
        next();
    }
};

/**
 * Role-based authorization middleware
 * Usage: authorize('admin', 'moderator')
 */
const authorize = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required.'
            });
        }
        
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: 'You do not have permission to perform this action.'
            });
        }
        
        next();
    };
};

/**
 * Middleware để kiểm tra quyền admin
 */
const isAdmin = (req, res, next) => {
    console.log('🔐 isAdmin middleware - User:', req.user?.username, 'Role:', req.user?.role);
    
    if (!req.user) {
        console.log('❌ No user in request');
        return res.status(401).json({
            success: false,
            message: 'Authentication required.'
        });
    }
    
    if (req.user.role !== 'admin') {
        console.log(`❌ Access denied: ${req.user.username} has role '${req.user.role}', needs 'admin'`);
        return res.status(403).json({
            success: false,
            message: 'Admin access required.'
        });
    }
    
    console.log('✅ Admin access granted');
    next();
};

/**
 * Middleware để kiểm tra quyền teacher hoặc admin
 */
const isTeacherOrAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: 'Authentication required.'
        });
    }
    
    if (req.user.role !== 'teacher' && req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: 'Teacher or admin access required.'
        });
    }
    
    next();
};

/**
 * Middleware để kiểm tra quyền teacher
 */
const isTeacher = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: 'Authentication required.'
        });
    }
    
    if (req.user.role !== 'teacher') {
        return res.status(403).json({
            success: false,
            message: 'Teacher access required.'
        });
    }
    
    next();
};

module.exports = { auth, optionalAuth, authorize, isAdmin, isTeacher, isTeacherOrAdmin };
