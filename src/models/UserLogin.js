const pool = require("../../db");

const UserLogin = {

  async findByUserId(userId) {
    const result = await pool.query(
      "SELECT * FROM user_login WHERE user_id = $1",
      [userId]
    );

    return result.rows[0];
  },


  async findByMobile(mobile) {
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
},
    async updateFcmToken(userId, fcmToken) {
    const result = await pool.query(
      `
      UPDATE user_login
      SET fcm_token = $1
      WHERE user_id = $2
      RETURNING user_id, username, mobile_no, role, fcm_token
      `,
      [fcmToken, userId]
    );

    return result.rows[0];
  },

  async create(mobile, password, createdBy = null) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // Lock registration for the same mobile number
    await client.query(
      `SELECT pg_advisory_xact_lock(hashtext($1))`,
      [`USER_REGISTRATION:${mobile}`]
    );

    // Find existing customer record, if any.
    // This allows a previously deactivated account to register again
    // without creating a duplicate users row.
    const existingUserResult = await client.query(
      `
      SELECT *
      FROM users
      WHERE mobile = $1
      FOR UPDATE
      `,
      [mobile]
    );

    let customerUser;

    if (existingUserResult.rows.length > 0) {
      customerUser = existingUserResult.rows[0];

      // Reactivate the customer record when registering again.
      const updateUserResult = await client.query(
        `
        UPDATE users
        SET
          is_active = true,
          deleted_at = NULL,
          deleted_by = NULL,
          role = 'USER'
        WHERE id = $1
        RETURNING *
        `,
        [customerUser.id]
      );

      customerUser = updateUserResult.rows[0];
    } else {
      // Create the numeric customer/entity record.
      const userResult = await client.query(
        `
        INSERT INTO users (
          mobile,
          role,
          is_active
        )
        VALUES ($1, 'USER', true)
        RETURNING *
        `,
        [mobile]
      );

      customerUser = userResult.rows[0];
    }

    // Generate the next MGU ID safely.
    await client.query(
      `SELECT pg_advisory_xact_lock(hashtext($1))`,
      ["MGU_USER_ID"]
    );

    const dateResult = await client.query(`
      SELECT TO_CHAR(CURRENT_DATE, 'YYMMDD') AS date_code
    `);

    const dateCode = dateResult.rows[0].date_code;
    const prefix = `MGU${dateCode}`;

    const sequenceResult = await client.query(
      `
      SELECT COALESCE(
        MAX(
          CAST(RIGHT(user_id, 2) AS INTEGER)
        ),
        0
      ) AS last_sequence
      FROM user_login
      WHERE user_id LIKE $1
      `,
      [`${prefix}%`]
    );

    const nextSequence =
      Number(sequenceResult.rows[0].last_sequence) + 1;

    if (nextSequence > 99) {
      throw new Error("Daily user registration limit exceeded");
    }

    const sequence = String(nextSequence).padStart(2, "0");
    const userId = `${prefix}${sequence}`;

    // Create authentication/MGU record.
    const loginResult = await client.query(
      `
      INSERT INTO user_login
      (
        user_id,
        username,
        mobile_no,
        password,
        role,
        created_by,
        is_active
      )
      VALUES
      ($1, $2, $3, $4, $5, $6, true)
      RETURNING *
      `,
      [
        userId,
        mobile,
        mobile,
        password,
        "USER",
        createdBy,
      ]
    );

    const createdLoginUser = loginResult.rows[0];

    await client.query("COMMIT");

    return {
      ...createdLoginUser,
      numeric_user_id: customerUser.id,
    };

  } catch (error) {
    await client.query("ROLLBACK");
    throw error;

  } finally {
    client.release();
  }
},
  

  async updatePassword(userId, newPassword) {
  const result = await pool.query(
    `
    UPDATE user_login
    SET password = $1
    WHERE user_id = $2
    RETURNING *
    `,
    [newPassword, userId]
  );

  return result.rows[0];
},
async updateUsername(userId, username) {
  const result = await pool.query(
    `
    UPDATE user_login
    SET username = $1
    WHERE user_id = $2
    RETURNING user_id, username, mobile_no, role
    `,
    [username, userId]
  );

  return result.rows[0];
},

async deactivateAccount(userId) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // Find the numeric customer ID linked to this MGU user ID.
    const userResult = await client.query(
      `
      SELECT u.id
      FROM users u
      INNER JOIN user_login ul
        ON ul.mobile_no = u.mobile
      WHERE ul.user_id = $1
        AND ul.is_active = true
      LIMIT 1
      `,
      [userId]
    );

    if (userResult.rows.length === 0) {
      await client.query("ROLLBACK");
      return null;
    }

    const numericUserId = userResult.rows[0].id;

    // Deactivate all active memberships belonging to this customer.
    await client.query(
      `
      UPDATE user_memberships
      SET
        status = 'INACTIVE',
        updated_at = CURRENT_TIMESTAMP
      WHERE user_id = $1
        AND status = 'ACTIVE'
      `,
      [numericUserId]
    );

    // Deactivate the login account.
    const result = await client.query(
      `
      UPDATE user_login
      SET
        is_active = false,
        deleted_at = CURRENT_TIMESTAMP,
        deleted_by = $1,
        fcm_token = NULL
      WHERE user_id = $1
        AND is_active = true
      RETURNING user_id, mobile_no, is_active, deleted_at, deleted_by;
      `,
      [userId]
    );

    if (result.rows.length === 0) {
      await client.query("ROLLBACK");
      return null;
    }

    // Also mark the numeric customer record inactive.
    await client.query(
      `
      UPDATE users
      SET
        is_active = false,
        deleted_at = CURRENT_TIMESTAMP,
        deleted_by = $1
      WHERE id = $2
      `,
      [userId, numericUserId]
    );

    await client.query("COMMIT");

    return result.rows[0];

  } catch (error) {
    await client.query("ROLLBACK");
    throw error;

  } finally {
    client.release();
  }
},
};


module.exports = UserLogin;