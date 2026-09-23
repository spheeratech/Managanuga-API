const pool = require("../../db");

const UserLogin = {
  async findByUserId(userId) {
    const result = await pool.query(
      `
      SELECT *
      FROM user_login
      WHERE user_id = $1
      `,
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

      // Prevent two registrations for the same mobile at the same time.
      await client.query(
        `SELECT pg_advisory_xact_lock(hashtext($1))`,
        [`USER_REGISTRATION:${mobile}`]
      );

      // If an active account already exists for this mobile,
      // do not create another account.
      const activeUserResult = await client.query(
        `
        SELECT id, user_id, username, mobile_no, role, is_active
        FROM user_login
        WHERE mobile_no = $1
          AND is_active = true
        LIMIT 1
        `,
        [mobile]
      );

      if (activeUserResult.rows.length > 0) {
        throw new Error("An active account already exists for this mobile number");
      }

      // Lock MGU ID generation.
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

      // user_login is now the ONLY user/customer table.
      // Its numeric primary key (id) is used internally by
      // memberships, cart, orders and wallet transactions.
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

        // user_login.id is now the internal numeric user ID.
        numeric_user_id: createdLoginUser.id,
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

      // userId is the public MGU ID.
      // Resolve it directly to user_login.id.
      const userResult = await client.query(
        `
        SELECT id
        FROM user_login
        WHERE user_id = $1
          AND is_active = true
        LIMIT 1
        `,
        [userId]
      );

      if (userResult.rows.length === 0) {
        await client.query("ROLLBACK");
        return null;
      }

      const numericUserId = userResult.rows[0].id;

      // Deactivate active memberships using user_login.id.
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
        RETURNING
          user_id,
          mobile_no,
          is_active,
          deleted_at,
          deleted_by
        `,
        [userId]
      );

      if (result.rows.length === 0) {
        await client.query("ROLLBACK");
        return null;
      }

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