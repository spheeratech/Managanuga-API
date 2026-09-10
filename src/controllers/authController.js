const {
  sendOtp,
  verifyOtp,
  markForgotPasswordVerified,
  isForgotPasswordVerified,
  clearForgotPasswordVerified,
} = require("../services/otpService");
const User = require("../models/User");
const UserLogin = require("../models/UserLogin");
const generateToken = require("../utils/generateToken");
const { sendSMS } = require("../services/smsService");

// SEND OTP
exports.sendOtp = async (req, res) => {
  console.log("SEND OTP ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const { mobile } = req.body;
    const loginUser = await UserLogin.findByMobile(mobile);

if (loginUser) {
  return res.status(200).json({
    success: true,
    existingUser: true,
    message: "Please login with your password.",
  });
}

    if (!mobile) {
      return res.status(400).json({ message: "Mobile required" });
    }

    await sendOtp(mobile);

    res.json({ message: "OTP sent successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
// FORGOT PASSWORD - SEND OTP
exports.sendForgotPasswordOtp = async (req, res) => {
  console.log("FORGOT PASSWORD OTP ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const { mobile } = req.body;

    if (!mobile) {
      return res.status(400).json({
        success: false,
        message: "Mobile required",
      });
    }

    // Check that this is an existing account
    const loginUser = await UserLogin.findByMobile(mobile);

    if (!loginUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Send OTP
    await sendOtp(mobile);

    res.json({
      success: true,
      message: "OTP sent successfully",
    });

  } catch (err) {
    console.error("FORGOT PASSWORD OTP ERROR:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};
// FORGOT PASSWORD - VERIFY OTP AND RESET PASSWORD
exports.resetPasswordWithOtp = async (req, res) => {
  console.log("RESET PASSWORD ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const {
      mobile,
      otp,
      newPassword,
      confirmPassword,
    } = req.body;

    if (!mobile || !otp || !newPassword || !confirmPassword) {
      return res.status(400).json({
        success: false,
        message:
          "Mobile, OTP, new password and confirm password are required",
      });
    }

    // Check password match
    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: "Passwords do not match",
      });
    }

    // Minimum password length
    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 6 characters",
      });
    }

    // Verify OTP
  // Check that the OTP was already verified
const verified = isForgotPasswordVerified(mobile);

if (!verified) {
  return res.status(400).json({
    success: false,
    message: "OTP verification required",
  });
}

  

    // Find existing login account
    const loginUser = await UserLogin.findByMobile(mobile);

    if (!loginUser) {
      return res.status(404).json({
        success: false,
        message: "User account not found",
      });
    }

    // Update password chosen by the user
    const updatedLoginUser =
      await UserLogin.updatePassword(
        loginUser.user_id,
        newPassword
      );

    if (!updatedLoginUser) {
      return res.status(500).json({
        success: false,
        message: "Failed to update password",
      });
    }
    clearForgotPasswordVerified(mobile);

    console.log(
      "PASSWORD RESET SUCCESSFUL FOR USER:",
      loginUser.user_id
    );

    return res.json({
      success: true,
      message: "Password reset successfully",
    });

  } catch (err) {
    console.error("RESET PASSWORD ERROR:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// VERIFY OTP + LOGIN
exports.verifyOtp = async (req, res) => {
  console.log("VERIFY OTP ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const {
      mobile,
      otp,
      vendorId,
    } = req.body;

    if (!mobile || !otp) {
      return res.status(400).json({
        success: false,
        message: "Mobile and OTP are required",
      });
    }

    // Verify OTP first
    const result = verifyOtp(mobile, otp);

    console.log("VERIFY RESULT:", result);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        message: result.message,
      });
    }

    // Check for an ACTIVE account only.
    const loginUser = await UserLogin.findByMobile(mobile);

    console.log("ACTIVE LOGIN USER:", loginUser);

    // --------------------------------------------------
    // EXISTING ACTIVE USER
    // --------------------------------------------------
    if (loginUser) {
     const authenticatedUser = { 
  id: loginUser.user_id, 
  user_id: loginUser.user_id, 
  login_id: loginUser.id,
  username: loginUser.username, 
  mobile: loginUser.mobile_no, 
  role: loginUser.role, 
  requiresName: false, 
};

      const token = generateToken(authenticatedUser);

      return res.json({
        message: "Login successful",
        token,
        user: authenticatedUser,
        requiresName: false,
      });
    }

    // --------------------------------------------------
    // NEW USER / PREVIOUSLY DELETED USER
    // --------------------------------------------------

    const chars = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";

    let randomPassword = "";

    for (let i = 0; i < 8; i++) {
      randomPassword += chars.charAt(
        Math.floor(Math.random() * chars.length)
      );
    }

    // Create new user_login record.
    // UserLogin.create() now generates:
    // MGUYYMMDD01
    // MGUYYMMDD02
    // etc.
    const createdLoginUser = await UserLogin.create(
      mobile,
      randomPassword,
      vendorId
    );

    console.log(
      "NEW USER CREATED:",
      createdLoginUser
    );

    if (!createdLoginUser) {
      return res.status(500).json({
        success: false,
        message: "Failed to create user account",
      });
    }

    // Send initial password SMS
    const passwordMessage =
      `We are delighted to have you with us. Your account for managanuga has been created successfully.\n` +
      `User ID: ${createdLoginUser.mobile_no}\n` +
      `Password: ${randomPassword}\n` + 
      `For your peace of mind, we recommend updating your password after your first login.\n` +
      `managanuga`;

    console.log(
      "PASSWORD SMS TEMPLATE:",
      process.env.SMS_PASSWORD_TEMPLATE_ID
    );

    console.log(
      "PASSWORD SMS MOBILE:",
      mobile
    );

    console.log(
      "PASSWORD SMS USER ID:",
      createdLoginUser.user_id
    );

    console.log(
      "PASSWORD SMS PASSWORD:",
      randomPassword
    );

    await sendSMS(
      mobile,
      passwordMessage,
      process.env.SMS_PASSWORD_TEMPLATE_ID
    );

   const authenticatedUser = { 
  id: createdLoginUser.user_id, 
  user_id: createdLoginUser.user_id, 
  login_id: createdLoginUser.id,
  username: createdLoginUser.username, 
  mobile: createdLoginUser.mobile_no, 
  role: createdLoginUser.role, 
  requiresName: true, 
};

    const token = generateToken(authenticatedUser);

    return res.json({
      message: "Login successful",
      token,
      user: authenticatedUser,
      requiresName: true,
    });

  } catch (err) {
    console.log("VERIFY ERROR:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};

// LOGIN WITH PASSWORD
exports.loginWithPassword = async (req, res) => {
  console.log("PASSWORD LOGIN ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const { mobile, password } = req.body;

if (!mobile || !password) {
  return res.status(400).json({
    message: "Mobile and password are required",
  });
}

// Remove only accidental spaces at the beginning/end.
// DO NOT change uppercase/lowercase.
const cleanPassword = password.trim();

console.log(
  "PASSWORD FROM APP:",
  JSON.stringify(password)
);

console.log(
  "CLEAN PASSWORD:",
  JSON.stringify(cleanPassword)
);

// Find login record
const loginUser = await UserLogin.findByMobile(mobile);

if (!loginUser) {
  return res.status(404).json({
    message: "User not found",
  });
}

console.log(
  "PASSWORD FROM DATABASE:",
  JSON.stringify(loginUser.password)
);

console.log(
  "PASSWORD MATCH:",
  loginUser.password === cleanPassword
);

// Verify password
if (loginUser.password !== cleanPassword) {
  return res.status(401).json({
    message: "Invalid password",
  });
}
    // Find user
   // Build authenticated user from PostgreSQL user_login record
const user = { 
  id: loginUser.user_id, 
  user_id: loginUser.user_id, 
  login_id: loginUser.id,
  username: loginUser.username, 
  mobile: loginUser.mobile_no, 
  role: loginUser.role, 
};

// Generate token
const token = generateToken(user);

res.json({
  message: "Login successful",
  token,
  user,
});
  } catch (err) {
    console.log("PASSWORD LOGIN ERROR:", err);
    res.status(500).json({
      message: err.message,
    });
  }
};
// SAVE FCM TOKEN
exports.updateFcmToken = async (req, res) => {
  console.log("FCM TOKEN ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const { userId, fcmToken } = req.body;

    if (!userId || !fcmToken) {
      return res.status(400).json({
        success: false,
        message: "userId and fcmToken are required",
      });
    }

    const user = await UserLogin.updateFcmToken(userId, fcmToken);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.json({
      success: true,
      message: "FCM token saved successfully",
      user,
    });

  } catch (err) {
    console.error("FCM TOKEN ERROR:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};
// UPDATE USERNAME
exports.updateUsername = async (req, res) => {
  console.log("UPDATE USERNAME ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const { userId, username } = req.body;

    if (!userId || !username || !username.trim()) {
      return res.status(400).json({
        success: false,
        message: "User ID and name are required",
      });
    }

    const cleanUsername = username.trim();

    const updatedUser = await UserLogin.updateUsername(
      userId,
      cleanUsername
    );

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.json({
      success: true,
      message: "Name updated successfully",
      user: updatedUser,
    });

   } catch (err) {
    console.error("UPDATE USERNAME ERROR:", err);

    // Duplicate username
    if (
      err.code === "23505" &&
      err.constraint === "user_login_username_key"
    ) {
      return res.status(409).json({
        success: false,
        message: "This name is already registered. Please choose a different name.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Unable to update your name. Please try again.",
    });
  }
};
exports.verifyForgotPasswordOtp = async (req, res) => {
  console.log("VERIFY FORGOT PASSWORD OTP ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const { mobile, otp } = req.body;

    if (!mobile || !otp) {
      return res.status(400).json({
        success: false,
        message: "Mobile and OTP are required",
      });
    }

    const result = verifyOtp(mobile, otp);

    console.log("FORGOT PASSWORD OTP RESULT:", result);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        message: result.message,
      });
    }
    markForgotPasswordVerified(mobile);

    // Confirm account still exists
    const loginUser = await UserLogin.findByMobile(mobile);

    if (!loginUser) {
      return res.status(404).json({
        success: false,
        message: "User account not found",
      });
    }

    return res.json({
      success: true,
      message: "OTP verified successfully",
    });

  } catch (err) {
    console.error("VERIFY FORGOT PASSWORD OTP ERROR:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};
// CHANGE PASSWORD
exports.changePassword = async (req, res) => {
  console.log("CHANGE PASSWORD ROUTE HIT");
  console.log("BODY:", req.body);

  try {
    const {
      userId,
      currentPassword,
      newPassword,
      confirmPassword,
    } = req.body;

    if (
      !userId ||
      !currentPassword ||
      !newPassword ||
      !confirmPassword
    ) {
      return res.status(400).json({
        success: false,
        message: "All password fields are required",
      });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: "New passwords do not match",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: "New password must be at least 6 characters",
      });
    }

    const loginUser = await UserLogin.findByUserId(userId);

    if (!loginUser) {
      return res.status(404).json({
        success: false,
        message: "User account not found",
      });
    }

    if (loginUser.password !== currentPassword.trim()) {
      return res.status(401).json({
        success: false,
        message: "Current password is incorrect",
      });
    }

    const updatedUser = await UserLogin.updatePassword(
      userId,
      newPassword
    );

    if (!updatedUser) {
      return res.status(500).json({
        success: false,
        message: "Failed to update password",
      });
    }

    console.log(
      "PASSWORD CHANGED SUCCESSFULLY FOR USER:",
      userId
    );

    return res.json({
      success: true,
      message: "Password changed successfully",
    });

  } catch (error) {
    console.error("CHANGE PASSWORD ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
exports.deleteAccount = async (req, res) => {
  try {
    const {userId} = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const deletedUser =
      await UserLogin.deactivateAccount(userId);

    if (!deletedUser) {
      return res.status(404).json({
        success: false,
        message: "Active account not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Account deleted successfully",
      data: deletedUser,
    });

  } catch (error) {
    console.error(
      "DELETE ACCOUNT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Failed to delete account",
    });
  }
};
