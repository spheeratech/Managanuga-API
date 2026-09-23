const pool = require("../../db");


// Find user by mobile number
const findOne = async ({ mobile }) => {
  const result = await pool.query(
    `
    SELECT *
    FROM user_login
    WHERE mobile_no = $1
      AND is_active = true
    LIMIT 1
    `,
    [mobile]
  );

  return result.rows[0];
};


// Find user by numeric user_login.id
const findById = async (userId) => {
  const result = await pool.query(
    `
    SELECT *
    FROM user_login
    WHERE id = $1
      AND is_active = true
    LIMIT 1
    `,
    [userId]
  );

  return result.rows[0];
};


// Create user
//
// User creation should now happen through UserLogin.create()
// because user_login is the single source of truth.
//
// This function is kept for compatibility with any old
// controller that may still call User.create().
const create = async ({ mobile }) => {
  const result = await pool.query(
    `
    INSERT INTO user_login (
      mobile_no,
      is_active
    )
    VALUES ($1, true)
    RETURNING *
    `,
    [mobile]
  );

  return result.rows[0];
};


// Save / update Firebase Cloud Messaging token
const updateFcmToken = async (userId, fcmToken) => {
  const result = await pool.query(
    `
    UPDATE user_login
    SET fcm_token = $1
    WHERE id = $2
      AND is_active = true
    RETURNING
      id,
      user_id,
      mobile_no,
      fcm_token
    `,
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