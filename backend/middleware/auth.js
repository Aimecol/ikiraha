const jwt = require('jsonwebtoken');
const { executeQuery } = require('../config/database');
require('dotenv').config();

// Generate JWT token
const generateToken = (payload, expiresIn = process.env.JWT_EXPIRES_IN) => {
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
};

// Generate refresh token
const generateRefreshToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, { 
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN 
  });
};

// Verify JWT token
const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid or expired token');
  }
};

// Authentication middleware
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token required'
      });
    }

    // Verify token
    const decoded = verifyToken(token);
    
    // Check if user still exists
    const user = await executeQuery(
      'SELECT id, email, first_name, last_name, phone_number, profile_image_url, is_email_verified FROM users WHERE id = ?',
      [decoded.userId]
    );

    if (user.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    // Add user to request object
    req.user = user[0];
    next();
  } catch (error) {
    console.error('Authentication error:', error.message);
    return res.status(403).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

// Optional authentication middleware (doesn't fail if no token)
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      const decoded = verifyToken(token);
      const user = await executeQuery(
        'SELECT id, email, first_name, last_name, phone_number, profile_image_url, is_email_verified FROM users WHERE id = ?',
        [decoded.userId]
      );

      if (user.length > 0) {
        req.user = user[0];
      }
    }
    
    next();
  } catch (error) {
    // Continue without authentication
    next();
  }
};

// Store refresh token in database
const storeRefreshToken = async (userId, refreshToken) => {
  try {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30); // 30 days

    await executeQuery(
      'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
      [userId, refreshToken, expiresAt]
    );
  } catch (error) {
    console.error('Error storing refresh token:', error.message);
    throw error;
  }
};

// Validate refresh token
const validateRefreshToken = async (refreshToken) => {
  try {
    // Verify token signature
    const decoded = verifyToken(refreshToken);
    
    // Check if token exists in database and is not expired
    const tokenRecord = await executeQuery(
      'SELECT user_id FROM refresh_tokens WHERE token = ? AND expires_at > NOW()',
      [refreshToken]
    );

    if (tokenRecord.length === 0) {
      throw new Error('Invalid or expired refresh token');
    }

    return decoded;
  } catch (error) {
    throw new Error('Invalid or expired refresh token');
  }
};

// Remove refresh token from database
const removeRefreshToken = async (refreshToken) => {
  try {
    await executeQuery(
      'DELETE FROM refresh_tokens WHERE token = ?',
      [refreshToken]
    );
  } catch (error) {
    console.error('Error removing refresh token:', error.message);
  }
};

// Clean expired refresh tokens
const cleanExpiredTokens = async () => {
  try {
    await executeQuery(
      'DELETE FROM refresh_tokens WHERE expires_at <= NOW()'
    );
  } catch (error) {
    console.error('Error cleaning expired tokens:', error.message);
  }
};

// Admin authentication middleware
const requireAdmin = async (req, res, next) => {
  try {
    // First authenticate the user
    await authenticateToken(req, res, () => {});
    
    // Check if user is admin (you can add an is_admin field to users table)
    const user = await executeQuery(
      'SELECT is_admin FROM users WHERE id = ?',
      [req.user.id]
    );

    if (user.length === 0 || !user[0].is_admin) {
      return res.status(403).json({
        success: false,
        message: 'Admin access required'
      });
    }

    next();
  } catch (error) {
    return res.status(403).json({
      success: false,
      message: 'Admin authentication failed'
    });
  }
};

// Email verification middleware
const requireEmailVerification = (req, res, next) => {
  if (!req.user.is_email_verified) {
    return res.status(403).json({
      success: false,
      message: 'Email verification required'
    });
  }
  next();
};

module.exports = {
  generateToken,
  generateRefreshToken,
  verifyToken,
  authenticateToken,
  optionalAuth,
  storeRefreshToken,
  validateRefreshToken,
  removeRefreshToken,
  cleanExpiredTokens,
  requireAdmin,
  requireEmailVerification
};
