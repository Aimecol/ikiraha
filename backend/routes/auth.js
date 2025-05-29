const express = require("express");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const { executeQuery } = require("../config/database");
const {
  generateToken,
  generateRefreshToken,
  authenticateToken,
  storeRefreshToken,
  validateRefreshToken,
  removeRefreshToken,
} = require("../middleware/auth");
const {
  validateRegistration,
  validateLogin,
  validateForgotPassword,
  validateResetPassword,
  validateChangePassword,
  validateUpdateProfile,
  validateRefreshToken: validateRefreshTokenMiddleware,
} = require("../middleware/validation");

const router = express.Router();

// Register new user
router.post("/register", validateRegistration, async (req, res) => {
  try {
    const { email, password, firstName, lastName, phoneNumber } = req.body;

    // Check if user already exists
    const existingUser = await executeQuery(
      "SELECT id FROM users WHERE email = ?",
      [email]
    );

    if (existingUser.length > 0) {
      return res.status(409).json({
        success: false,
        message: "User with this email already exists",
      });
    }

    // Hash password
    const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS) || 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Generate email verification token
    const emailVerificationToken = crypto.randomBytes(32).toString("hex");

    // Insert user into database
    const result = await executeQuery(
      `INSERT INTO users (email, password, first_name, last_name, phone_number, email_verification_token)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        email,
        hashedPassword,
        firstName,
        lastName,
        phoneNumber || null,
        emailVerificationToken,
      ]
    );

    const userId = result.insertId;

    // Generate tokens
    const accessToken = generateToken({ userId, email });
    const refreshToken = generateRefreshToken({ userId, email });

    // Store refresh token
    await storeRefreshToken(userId, refreshToken);

    // Get user data (without password)
    const userData = await executeQuery(
      "SELECT id, email, first_name, last_name, phone_number, profile_image_url, is_email_verified, created_at FROM users WHERE id = ?",
      [userId]
    );

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: {
        user: userData[0],
        accessToken,
        refreshToken,
      },
    });

    // TODO: Send email verification email
    console.log(
      `Email verification token for ${email}: ${emailVerificationToken}`
    );
  } catch (error) {
    console.error("Registration error:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error during registration",
    });
  }
});

// Login user
router.post("/login", validateLogin, async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const users = await executeQuery(
      "SELECT id, email, password, first_name, last_name, phone_number, profile_image_url, is_email_verified FROM users WHERE email = ?",
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const user = users[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // Update last login time
    await executeQuery("UPDATE users SET last_login_at = NOW() WHERE id = ?", [
      user.id,
    ]);

    // Generate tokens
    const accessToken = generateToken({ userId: user.id, email: user.email });
    const refreshToken = generateRefreshToken({
      userId: user.id,
      email: user.email,
    });

    // Store refresh token
    await storeRefreshToken(user.id, refreshToken);

    // Remove password from response
    delete user.password;

    res.json({
      success: true,
      message: "Login successful",
      data: {
        user,
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    console.error("Login error:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error during login",
    });
  }
});

// Refresh access token
router.post(
  "/refresh-token",
  validateRefreshTokenMiddleware,
  async (req, res) => {
    try {
      const { refreshToken } = req.body;

      // Validate refresh token
      const decoded = await validateRefreshToken(refreshToken);

      // Get user data
      const users = await executeQuery(
        "SELECT id, email, first_name, last_name, phone_number, profile_image_url, is_email_verified FROM users WHERE id = ?",
        [decoded.userId]
      );

      if (users.length === 0) {
        return res.status(401).json({
          success: false,
          message: "User not found",
        });
      }

      const user = users[0];

      // Generate new access token
      const newAccessToken = generateToken({
        userId: user.id,
        email: user.email,
      });

      res.json({
        success: true,
        message: "Token refreshed successfully",
        data: {
          accessToken: newAccessToken,
          user,
        },
      });
    } catch (error) {
      console.error("Token refresh error:", error.message);
      res.status(401).json({
        success: false,
        message: "Invalid or expired refresh token",
      });
    }
  }
);

// Logout user
router.post("/logout", authenticateToken, async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (refreshToken) {
      // Remove refresh token from database
      await removeRefreshToken(refreshToken);
    }

    res.json({
      success: true,
      message: "Logout successful",
    });
  } catch (error) {
    console.error("Logout error:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error during logout",
    });
  }
});

// Get current user profile
router.get("/profile", authenticateToken, async (req, res) => {
  try {
    const user = await executeQuery(
      "SELECT id, email, first_name, last_name, phone_number, profile_image_url, is_email_verified, created_at, last_login_at FROM users WHERE id = ?",
      [req.user.id]
    );

    if (user.length === 0) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.json({
      success: true,
      data: {
        user: user[0],
      },
    });
  } catch (error) {
    console.error("Get profile error:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
});

// Update user profile
router.put(
  "/profile",
  authenticateToken,
  validateUpdateProfile,
  async (req, res) => {
    try {
      const { firstName, lastName, phoneNumber } = req.body;
      const userId = req.user.id;

      // Build update query dynamically
      const updates = [];
      const values = [];

      if (firstName !== undefined) {
        updates.push("first_name = ?");
        values.push(firstName);
      }
      if (lastName !== undefined) {
        updates.push("last_name = ?");
        values.push(lastName);
      }
      if (phoneNumber !== undefined) {
        updates.push("phone_number = ?");
        values.push(phoneNumber);
      }

      if (updates.length === 0) {
        return res.status(400).json({
          success: false,
          message: "No fields to update",
        });
      }

      values.push(userId);

      await executeQuery(
        `UPDATE users SET ${updates.join(
          ", "
        )}, updated_at = NOW() WHERE id = ?`,
        values
      );

      // Get updated user data
      const updatedUser = await executeQuery(
        "SELECT id, email, first_name, last_name, phone_number, profile_image_url, is_email_verified, created_at, updated_at FROM users WHERE id = ?",
        [userId]
      );

      res.json({
        success: true,
        message: "Profile updated successfully",
        data: {
          user: updatedUser[0],
        },
      });
    } catch (error) {
      console.error("Update profile error:", error.message);
      res.status(500).json({
        success: false,
        message: "Internal server error during profile update",
      });
    }
  }
);

// Forgot password
router.post("/forgot-password", validateForgotPassword, async (req, res) => {
  try {
    const { email } = req.body;

    // Find user by email
    const users = await executeQuery(
      "SELECT id, email, first_name FROM users WHERE email = ?",
      [email]
    );

    // Always return success for security (don't reveal if email exists)
    if (users.length === 0) {
      return res.json({
        success: true,
        message:
          "If an account with that email exists, a password reset link has been sent",
      });
    }

    const user = users[0];

    // Generate password reset token
    const resetToken = crypto.randomBytes(32).toString("hex");
    const resetExpires = new Date();
    resetExpires.setHours(resetExpires.getHours() + 1); // 1 hour expiry

    // Store reset token
    await executeQuery(
      "UPDATE users SET password_reset_token = ?, password_reset_expires = ? WHERE id = ?",
      [resetToken, resetExpires, user.id]
    );

    res.json({
      success: true,
      message:
        "If an account with that email exists, a password reset link has been sent",
    });

    // TODO: Send password reset email
    console.log(`Password reset token for ${email}: ${resetToken}`);
  } catch (error) {
    console.error("Forgot password error:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
});

// Reset password
router.post("/reset-password", validateResetPassword, async (req, res) => {
  try {
    const { token, password } = req.body;

    // Find user by reset token
    const users = await executeQuery(
      "SELECT id FROM users WHERE password_reset_token = ? AND password_reset_expires > NOW()",
      [token]
    );

    if (users.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid or expired reset token",
      });
    }

    const user = users[0];

    // Hash new password
    const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS) || 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Update password and clear reset token
    await executeQuery(
      "UPDATE users SET password = ?, password_reset_token = NULL, password_reset_expires = NULL, updated_at = NOW() WHERE id = ?",
      [hashedPassword, user.id]
    );

    res.json({
      success: true,
      message: "Password reset successful",
    });
  } catch (error) {
    console.error("Reset password error:", error.message);
    res.status(500).json({
      success: false,
      message: "Internal server error during password reset",
    });
  }
});

// Change password
router.put(
  "/change-password",
  authenticateToken,
  validateChangePassword,
  async (req, res) => {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id;

      // Get current password hash
      const users = await executeQuery(
        "SELECT password FROM users WHERE id = ?",
        [userId]
      );

      if (users.length === 0) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      // Verify current password
      const isCurrentPasswordValid = await bcrypt.compare(
        currentPassword,
        users[0].password
      );
      if (!isCurrentPasswordValid) {
        return res.status(400).json({
          success: false,
          message: "Current password is incorrect",
        });
      }

      // Hash new password
      const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS) || 12;
      const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

      // Update password
      await executeQuery(
        "UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?",
        [hashedNewPassword, userId]
      );

      res.json({
        success: true,
        message: "Password changed successfully",
      });
    } catch (error) {
      console.error("Change password error:", error.message);
      res.status(500).json({
        success: false,
        message: "Internal server error during password change",
      });
    }
  }
);

module.exports = router;
