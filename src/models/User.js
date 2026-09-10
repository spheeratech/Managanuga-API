const pool = require("../../db");

const findOne = async ({ mobile }) => {
  const result = await pool.query(
    "SELECT * FROM users WHERE mobile = $1",
    [mobile]
  );

  return result.rows[0];
};

const findById = async (userId) => {
  const result = await pool.query(
    "SELECT * FROM users WHERE id = $1",
    [userId]
  );

  return result.rows[0];
};

const create = async ({ mobile }) => {
  const result = await pool.query(
    "INSERT INTO users (mobile) VALUES ($1) RETURNING *",
    [mobile]
  );

  return result.rows[0];
};

// Save / update Firebase Cloud Messaging token
const updateFcmToken = async (userId, fcmToken) => {
  const result = await pool.query(
    `UPDATE users
     SET fcm_token = $1
     WHERE id = $2
     RETURNING id, mobile, fcm_token`,
    [fcmToken, userId]
  );

  return result.rows[0];
};


module.exports = {
  findOne,
  findById,
  create,
  updateFcmToken,
};