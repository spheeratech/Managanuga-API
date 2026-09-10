const pool = require("../../db");

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
    INSERT INTO notifications
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
    [
      userId,
      title,
      message,
      type,
      referenceId,
    ]
  );

  return result.rows[0];
};

// Get user's notifications
const getUserNotifications = async (userId) => {
  const result = await pool.query(
    `
    SELECT *
    FROM notifications
    WHERE user_id = $1
    ORDER BY created_at DESC
    `,
    [userId]
  );

  return result.rows;
};

// Get unread count
const getUnreadCount = async (userId) => {
  const result = await pool.query(
    `
    SELECT COUNT(*)::INTEGER AS count
    FROM notifications
    WHERE user_id = $1
      AND is_read = FALSE
    `,
    [userId]
  );

  return result.rows[0].count;
};

// Mark notification as read
const markAsRead = async (notificationId, userId) => {
  const result = await pool.query(
    `
    UPDATE notifications
    SET is_read = TRUE
    WHERE id = $1
      AND user_id = $2
    RETURNING *;
    `,
    [notificationId, userId]
  );

  return result.rows[0];
};

// Mark all notifications as read
const markAllAsRead = async (userId) => {
  const result = await pool.query(
    `
    UPDATE notifications
    SET is_read = TRUE
    WHERE user_id = $1
      AND is_read = FALSE
    RETURNING *;
    `,
    [userId]
  );

  return result.rows;
};

module.exports = {
  createNotification,
  getUserNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
};