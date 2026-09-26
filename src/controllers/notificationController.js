const pool = require("../../db");
const Notification = require("../models/Notification");
const { sendPushNotification } = require("../services/fcmService");

// =====================================================
// RESOLVE USER ID
// =====================================================

const resolveUserId = async (userId) => {
  const cleanUserId = String(userId || "").trim();

  if (!cleanUserId) {
    throw new Error("userId is required");
  }

  if (/^\d+$/.test(cleanUserId)) {
    const numericId = Number(cleanUserId);

    const result = await pool.query(
      `
      SELECT id
      FROM user_login
      WHERE id = $1
        AND is_active = true
      LIMIT 1
      `,
      [numericId]
    );

    if (result.rowCount === 0) {
      throw new Error("User not found");
    }

    return result.rows[0].id;
  }
  const result = await pool.query(
    `
    SELECT id
    FROM user_login
    WHERE user_id = $1
      AND is_active = true
    LIMIT 1
    `,
    [cleanUserId]
  );

  if (result.rowCount === 0) {
    throw new Error("User not found");
  }

  return result.rows[0].id;
};

// =====================================================
// GET ALL NOTIFICATIONS
// =====================================================

const getNotifications = async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const resolvedUserId = await resolveUserId(userId);

    if (!resolvedUserId) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const notifications =
      await Notification.getUserNotifications(
        resolvedUserId
      );

    res.status(200).json({
      success: true,
      notifications,
    });
  } catch (error) {
    console.error(
      "Get Notifications Error:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// GET UNREAD NOTIFICATION COUNT
// =====================================================

const getUnreadCount = async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const resolvedUserId = await resolveUserId(userId);

    if (!resolvedUserId) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const count =
      await Notification.getUnreadCount(
        resolvedUserId
      );

    res.status(200).json({
      success: true,
      count,
    });
  } catch (error) {
    console.error(
      "Get Unread Count Error:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// MARK ONE NOTIFICATION AS READ
// =====================================================

const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const resolvedUserId =
      await resolveUserId(userId);

    if (!resolvedUserId) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const notification =
      await Notification.markAsRead(
        id,
        resolvedUserId
      );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      });
    }

    res.status(200).json({
      success: true,
      notification,
    });
  } catch (error) {
    console.error(
      "Mark Notification Read Error:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// MARK ALL NOTIFICATIONS AS READ
// =====================================================

const markAllAsRead = async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const resolvedUserId =
      await resolveUserId(userId);

    if (!resolvedUserId) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    await Notification.markAllAsRead(
      resolvedUserId
    );

    res.status(200).json({
      success: true,
      message: "All notifications marked as read",
    });
  } catch (error) {
    console.error(
      "Mark All Notifications Read Error:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// CREATE TEST NOTIFICATION + PUSH
// =====================================================

const createTestNotification = async (
  req,
  res
) => {
  try {
    const {
      userId,
      title,
      message,
      type,
      referenceId,
    } = req.body;

    if (!userId || !title || !message) {
      return res.status(400).json({
        success: false,
        message:
          "userId, title and message are required",
      });
    }

    const resolvedUserId =
      await resolveUserId(userId);

    if (!resolvedUserId) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Save notification in database
    const notification =
      await Notification.createNotification({
        userId: resolvedUserId,
        title,
        message,
        type: type || "GENERAL",
        referenceId:
          referenceId || null,
      });

    // Get user's FCM token
    const result = await pool.query(
      `
      SELECT
        user_id,
        fcm_token
      FROM user_login
      WHERE id = $1
      LIMIT 1
      `,
      [resolvedUserId]
    );

    const user = result.rows[0];

    console.log(
      "👤 Notification User:",
      user
    );

    if (!user?.fcm_token) {
      return res.status(400).json({
        success: false,
        message:
          "User does not have an FCM token",
        notification,
      });
    }

    // Send push notification
    const fcmResponse =
      await sendPushNotification({
        fcmToken: user.fcm_token,
        title,
        body: message,
        data: {
          notificationId:
            notification.id,
          type:
            type || "GENERAL",
        },
      });

    console.log(
      "🔥 REAL PUSH SENT:",
      fcmResponse
    );

    res.status(201).json({
      success: true,
      message:
        "Notification created and push sent",
      notification,
      fcmResponse,
    });
  } catch (error) {
    console.error(
      "❌ Create/Send Notification Error:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// SEND TEST PUSH ONLY
// =====================================================

const sendTestPushNotification = async (
  req,
  res
) => {
  try {
    const {
      userId,
      title,
      message,
    } = req.body;

    if (!userId || !title || !message) {
      return res.status(400).json({
        success: false,
        message:
          "userId, title and message are required",
      });
    }

    const result = await pool.query(
      `
      SELECT
        user_id,
        username,
        mobile_no,
        role,
        fcm_token
      FROM user_login
      WHERE user_id = $1
      LIMIT 1
      `,
      [userId]
    );

    const user = result.rows[0];

    console.log(
      "👤 Notification User:",
      user
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (!user.fcm_token) {
      return res.status(400).json({
        success: false,
        message:
          "User does not have an FCM token",
      });
    }

    const firebaseResponse =
      await sendPushNotification({
        fcmToken: user.fcm_token,
        title,
        body: message,
        data: {
          userId: user.user_id,
          type: "TEST",
        },
      });

    console.log(
      "🔥 TEST PUSH SENT:",
      firebaseResponse
    );

    res.status(200).json({
      success: true,
      message:
        "Push notification sent successfully",
      firebaseResponse,
    });
  } catch (error) {
    console.error(
      "❌ Send Test Push Error:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =====================================================
// EXPORTS
// =====================================================

module.exports = {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  createTestNotification,
  sendTestPushNotification,
};