const pool = require("../../db");

const AdminUser = {
  async findByUsername(username) {
    const result = await pool.query(
      `
      SELECT *
      FROM user_login
      WHERE username = $1
      LIMIT 1
      `,
      [username],
    );

    return result.rows[0] || null;
  },

  async findByMobile(mobileNo) {
    const result = await pool.query(
      `
      SELECT *
      FROM user_login
      WHERE mobile_no = $1
      LIMIT 1
      `,
      [mobileNo],
    );

    return result.rows[0] || null;
  },

  async findByEmail(email) {
    const result = await pool.query(
      `
      SELECT *
      FROM user_info
      WHERE email = $1
      LIMIT 1
      `,
      [email],
    );

    return result.rows[0] || null;
  },

  // --------------------------------------------------
  // CREATE USER
  // --------------------------------------------------
  async createUser(client, loginData, infoData) {
    const defaultPassword = "123456";

    const loginResult = await client.query(
      `
      INSERT INTO user_login (
        user_id,
        username,
        mobile_no,
        password,
        role,
        is_active,
        created_by,
        assigned_by,
        relationship_type
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
      `,
      [
        loginData.userId,
        loginData.username,
        loginData.mobileNo,
        // defaultPassword,
        loginData.password,
        loginData.role,
        loginData.isActive,
        loginData.createdBy || null,
        loginData.assignedBy || null,
        loginData.relationshipType || null,
      ],
    );
    console.log("========================================");
    console.log("CREATE USER - PRODUCTION DEBUG");

    console.log("INFO DATA BEFORE INSERT:");
    console.log(JSON.stringify(infoData, null, 2));
    console.log("========================================");

    const infoResult = await client.query(
      `
      INSERT INTO user_info (
        user_id,
        first_name,
        last_name,
        email,
        address,
        city,
        state,
        pincode,
        subscription,
        mobile,
        bank_account_no,
        ifsc_code,
        bank_holder_name,
        bank_name,
        contact_person_name,
        contact_person_mobile
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9,$10,
    $11, $12, $13, $14, $15, $16)
      RETURNING *
      `,
      [
        infoData.userId,
        infoData.firstName,
        infoData.lastName || null,
        infoData.email || null,
        infoData.address || null,
        infoData.city || null,
        infoData.state || null,
        infoData.pincode || null,
        infoData.subscription || null,
        infoData.mobile || null,
        infoData.bankAccountNumber || null,
        infoData.ifscCode || null,
        infoData.bankHolderName || null,
        infoData.bankName || null,
        infoData.contactPersonName || null,
        infoData.contactPersonNumber || null,
      ],
    );
    console.log("INSERTED USER_INFO:", infoResult.rows[0]);

    return {
      login: loginResult.rows[0],
      info: infoResult.rows[0],
    };
  },

  // --------------------------------------------------
  // GET ALL USERS
  // --------------------------------------------------
  async getAllUsers() {
    const result = await pool.query(
      `
      SELECT
        l.user_id,
        l.username,
        COALESCE(l.mobile_no, i.mobile) AS mobile_no,
        l.role,
        l.is_active,
        l.created_by,
        l.assigned_by,
        l.relationship_type,
        l.created_at,

        i.first_name,
        i.last_name,
        i.email,
        i.address,
        i.city,
        i.state,
        i.pincode,
        i.subscription,
        COALESCE(i.mobile, l.mobile_no) AS mobile,
        i.bank_account_no,
        i.ifsc_code,
        i.bank_holder_name,
        i.bank_name,
        i.contact_person_name,
        i.contact_person_mobile

      FROM user_login l

      LEFT JOIN user_info i
        ON l.user_id = i.user_id

      ORDER BY l.created_at DESC
      `,
    );

    return result.rows;
  },

  // --------------------------------------------------
  // GET USER BY ID
  // --------------------------------------------------
  async getUserById(userId) {
    const result = await pool.query(
      `
      SELECT
        l.user_id,
        l.username,
        l.mobile_no,
        l.role,
        l.is_active,
        l.created_by,
        l.assigned_by,
        l.relationship_type,
        l.created_at,

        i.first_name,
        i.last_name,
        i.email,
        i.address,
        i.city,
        i.state,
        i.pincode,
        i.subscription,
        COALESCE(i.mobile, l.mobile_no) AS mobile,
        i.bank_account_no,
        i.ifsc_code,
        i.bank_holder_name,
        i.bank_name,
        i.contact_person_name,
        i.contact_person_mobile


      FROM user_login l

      LEFT JOIN user_info i
        ON l.user_id = i.user_id

      WHERE l.user_id = $1

      LIMIT 1
      `,
      [userId],
    );

    return result.rows[0] || null;
  },

  // --------------------------------------------------
  // UPDATE STATUS
  // --------------------------------------------------
  async updateStatus(userId, isActive) {
    const result = await pool.query(
      `
      UPDATE user_login
      SET is_active = $1
      WHERE user_id = $2
      RETURNING *
      `,
      [isActive, userId],
    );

    return result.rows[0] || null;
  },

  // --------------------------------------------------
  // UPDATE USER
  // --------------------------------------------------
  async updateUser(client, userId, data) {
    await client.query(
      `
      UPDATE user_login
      SET 
        mobile_no = COALESCE($1, mobile_no),
        role = COALESCE($2, role),
        is_active = COALESCE($3, is_active)
      WHERE user_id = $4
      `,
      [data.mobileNo, data.role, data.isActive, userId],
    );

    const infoResult = await client.query(
      `
      UPDATE user_info
      SET 
        first_name = $1,
        last_name = $2,
        email = $3,
        address = $4,
        city = $5,
        state = $6,
        pincode = $7,
        subscription = $8,
        mobile = $9,
        bank_account_no = $10,
        ifsc_code = $11,
        bank_holder_name = $12,
        bank_name = $13,
        contact_person_name = $14,
        contact_person_mobile = $15
        WHERE user_id = $16
        RETURNING *
      `,
      [
        data.firstName,
        data.lastName,
        data.email,
        data.address,
        data.city,
        data.state,
        data.pincode,
        data.subscription,
        data.mobileNo,
        data.bankAccountNumber,
        data.ifscCode,
        data.bankHolderName,
        data.bankName,
        data.contactPersonName,
        data.contactPersonNumber,
        userId,
      ],
    );

    return infoResult.rows[0] || null;
  },

  // --------------------------------------------------
  // DELETE USER
  // --------------------------------------------------
  async deleteUser(client, userId) {
    await client.query(`DELETE FROM user_info WHERE user_id = $1`, [userId]);

    const result = await client.query(
      `DELETE FROM user_login WHERE user_id = $1 RETURNING *`,
      [userId],
    );

    return result.rows[0] || null;
  },
};

module.exports = AdminUser;
