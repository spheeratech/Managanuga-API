const pool = require("../../db");
const { sendPushNotification } = require("../services/fcmService");
// Create notification
const createNotification = async ({
  userId,
  title,
  message,
  type,
  referenceId = null,
}) => {
  const result = await pool.query(
    `
    INSERT INTO inapp_notifications
    (
      user_id,
      title,
      message,
      type,
      reference_id
    )
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
    `,
    [userId, title, message, type, referenceId],
  );

  return result.rows[0];
};

// Get user's notifications
const getUserNotifications = async (userId) => {
  const result = await pool.query(
    `
    SELECT *
    FROM inapp_notifications
    WHERE user_id = $1
    ORDER BY created_at DESC
    `,
    [userId],
  );

  return result.rows;
};

// Get unread count
const getUnreadCount = async (userId) => {
  const result = await pool.query(
    `
    SELECT COUNT(*)::INTEGER AS count
    FROM inapp_notifications
    WHERE user_id = $1
      AND is_read = FALSE
    `,
    [userId],
  );

  return result.rows[0].count;
};

// Mark notification as read
const markAsRead = async (notificationId, userId) => {
  const result = await pool.query(
    `
    UPDATE inapp_notifications
    SET is_read = TRUE,
     is_active = 0
    WHERE id = $1
      AND user_id = $2
    RETURNING *;
    `,
    [notificationId, userId],
  );

  return result.rows[0];
};

// Mark all notifications as read
const markAllAsRead = async (userId) => {
  const result = await pool.query(
    `
    UPDATE inapp_notifications
    SET is_read = TRUE,
     is_active = 0
    WHERE user_id = $1
      AND is_read = FALSE
    RETURNING *;
    `,
    [userId],
  );

  return result.rows;
};

// Notify all active SUPER_ADMIN users
const notifySuperAdmins = async ({
  title,
  message,
  type = "ORDER_PLACED",
  referenceId = null,
}) => {
  try {
    const result = await pool.query(`
      SELECT user_id, fcm_token
      FROM user_login
      WHERE role = 1
        AND is_active = 1
    `);

    console.log("SUPER_ADMIN QUERY ROW COUNT:", result.rows.length);
    console.log("SUPER_ADMIN QUERY RESULTS:", result.rows);
    console.log(
      "ACTIVE SUPER_ADMINS:",
      result.rows.map((admin) => admin.user_id),
    );

    let notifiedAdmins = 0;
    const failedAdmins = [];

    for (const admin of result.rows) {
      try {
        // Create in-app notification for each SUPER_ADMIN
        const notification = await createNotification({
          userId: admin.user_id,
          title,
          message,
          type,
          referenceId,
        });

        notifiedAdmins++;

        console.log(
          "ORDER NOTIFICATION CREATED:",
          admin.user_id,
          notification.id,
        );

        // Send push notification if FCM token exists
        if (admin.fcm_token) {
          try {
            await sendPushNotification({
              fcmToken: admin.fcm_token,
              title,
              body: message,
              data: {
                notificationId: String(notification.id),
                userId: String(admin.user_id),
                type: String(type),
                referenceId: String(referenceId || ""),
              },
            });
          } catch (pushError) {
            console.error(
              "SUPER_ADMIN push failed:",
              admin.user_id,
              pushError.message,
            );
          }
        }
      } catch (adminError) {
        failedAdmins.push(admin.user_id);

        console.error(
          "SUPER_ADMIN notification creation failed:",
          admin.user_id,
          adminError.message,
        );
      }
    }

    const response = {
      success: failedAdmins.length === 0,
      notifiedAdmins,
      failedAdmins,
    };

    console.log("SUPER_ADMIN NOTIFICATION RESULT:", response);

    return response;
  } catch (error) {
    console.error("SUPER_ADMIN notification service error:", error);

    return {
      success: false,
      notifiedAdmins: 0,
      error: error.message,
    };
  }
};

module.exports = {
  createNotification,
  getUserNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  notifySuperAdmins,
};
