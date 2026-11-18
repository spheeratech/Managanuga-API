
const { logException } = require("../utils/exceptionLogger.js");
const pool = require("../../db");
const { getRoleName } = require("../utils/userRoles");

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
  // async createUser(client, loginData, infoData) {
  //   // Resolve the numeric role ID from lkp_user_roles
  //   const roleResult = await client.query(
  //     `
  //     SELECT id
  //     FROM lkp_user_roles
  //     WHERE UPPER(TRIM(role_name)) = UPPER(TRIM($1))
  //     LIMIT 1
  //     `,
  //     [loginData.role],
  //   );

  //   if (roleResult.rows.length === 0) {
  //     throw new Error(`Role "${loginData.role}" not found in lkp_user_roles`);
  //   }

  //   const roleId = roleResult.rows[0].id;

  //   // Store the numeric role ID in the existing role column.
  //   // Store the ID directly in the role column.
  //   const loginResult = await client.query(
  //     `
  //     INSERT INTO user_login (
  //       user_id,
  //       username,
  //       mobile_no,
  //       password,
  //       role,
  //       is_active,
  //       created_by,
  //       assigned_by,
  //       relationship_type
  //     )
  //     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
  //     RETURNING *
  //     `,
  //     [
  //       loginData.userId,
  //       loginData.username,
  //       loginData.mobileNo,
  //       loginData.password,
  //       roleId,
  //       loginData.isActive,
  //       loginData.createdBy || null,
  //       loginData.assignedBy || null,
  //       loginData.relationshipType || null,
  //     ],
  //   );

  //   console.log("========================================");
  //   console.log("CREATE USER");
  //   console.log("Role ID:", roleId);
  //   console.log("========================================");

  //   const infoResult = await client.query(
  //     `
  //     INSERT INTO user_info (
  //       user_id,
  //       first_name,
  //       last_name,
  //       email,
  //       address,
  //       city,
  //       state,
  //       pincode,
  //       subscription,
  //       mobile,
  //       bank_account_no,
  //       ifsc_code,
  //       bank_holder_name,
  //       bank_name,
  //       contact_person_name,
  //       contact_person_mobile,
  //       referral_benefit
  //     )
  //     VALUES (
  //       $1, $2, $3, $4, $5, $6, $7, $8,
  //       $9, $10, $11, $12, $13, $14, $15, $16, $17
  //     )
  //     RETURNING *
  //     `,
  //     [
  //       infoData.userId,
  //       infoData.firstName,
  //       infoData.lastName || null,
  //       infoData.email || null,
  //       infoData.address || null,
  //       infoData.city || null,
  //       infoData.state || null,
  //       infoData.pincode || null,
  //       infoData.subscription || null,
  //       infoData.mobile || null,
  //       infoData.bankAccountNumber || null,
  //       infoData.ifscCode || null,
  //       infoData.bankHolderName || null,
  //       infoData.bankName || null,
  //       infoData.contactPersonName || null,
  //       infoData.contactPersonNumber || null,
  //       infoData.referralBenefit ?? null,
  //     ],
  //   );

  //   return {
  //     login: loginResult.rows[0],
  //     info: infoResult.rows[0],
  //   };
  // },
  // --------------------------------------------------
  // CREATE USER USING DATABASE FUNCTION
  // --------------------------------------------------
  async createUser(client, loginData, infoData) {
    // 1. Resolve numeric role ID
    const roleResult = await client.query(
      `
    SELECT id
    FROM public.lkp_user_roles
    WHERE UPPER(TRIM(role_name)) = UPPER(TRIM($1))
    LIMIT 1
    `,
      [loginData.role],
    );

    if (roleResult.rows.length === 0) {
      throw new Error(`Role "${loginData.role}" not found in lkp_user_roles`);
    }

    const roleId = Number(roleResult.rows[0].id);

    // 2. Call PostgreSQL function
    const result = await client.query(
      `
    SELECT *
    FROM public.create_admin_user(
      $1, $2, $3, $4, $5,
      $6, $7, $8, $9, $10,
      $11, $12, $13, $14, $15,
      $16, $17, $18, $19, $20,
      $21, $22, $23, $24, $25
    )
    `,
      [
        loginData.userId, // $1
        loginData.username, // $2
        loginData.mobileNo, // $3
        loginData.password, // $4
        roleId, // $5
        loginData.isActive, // $6
        loginData.createdBy || null, // $7
        loginData.assignedBy || null, // $8
        loginData.relationshipType || null, // $9

        infoData.firstName, // $10
        infoData.lastName || null, // $11
        infoData.email || null, // $12
        infoData.address || null, // $13
        infoData.city || null, // $14
        infoData.state || null, // $15
        infoData.pincode || null, // $16
        infoData.subscription || null, // $17
        infoData.mobile || null, // $18

        infoData.bankAccountNumber || null, // $19
        infoData.ifscCode || null, // $20
        infoData.bankHolderName || null, // $21
        infoData.bankName || null, // $22
        infoData.contactPersonName || null, // $23
        infoData.contactPersonNumber || null, // $24
        infoData.referralBenefit ?? null, // $25
      ],
    );

    if (!result.rows.length) {
      throw new Error("User creation function returned no data");
    }

    const createdUser = result.rows[0];

    console.log("========================================");
    console.log("USER CREATED USING DATABASE FUNCTION");
    console.log("Role ID:", roleId);
    console.log("Referral Code:", createdUser.info_data?.referral_code || null);
    console.log("========================================");

    return {
      login: createdUser.login_data,
      info: createdUser.info_data,
    };
  },
  //------------------------------------------------------
  //   GET Users by User ID (all users,vendor & reseller users)
  //----------------------------------------------------------

  async getUsersByUserId(userId, roleId) {
    const result = await pool.query(
      `
      SELECT *
      FROM public.get_users_by_user_id($1, $2)
    `,
      [userId, roleId],
    );

    return result.rows.map((user) => ({
      user_id: user.customer_user_id,
      username: user.customer_name,
      first_name: user.customer_first_name,
      last_name: user.customer_last_name,
      mobile_no: user.customer_mobile,
      email: user.customer_email,
      role: user.customer_role,
      is_active: user.customer_status,
      created_at: user.created_at,
      subscription: user.subscription || null,
      // Existing profile information
      address: user.address ?? null,
      city: user.city ?? null,
      state: user.state ?? null,
      pincode: user.pincode ?? null,
      subscription: user.subscription ?? null,

      bank_account_no: user.bank_account_no ?? null,
      ifsc_code: user.ifsc_code ?? null,
      bank_holder_name: user.bank_holder_name ?? null,
      bank_name: user.bank_name ?? null,

      contact_person_name: user.contact_person_name ?? null,
      contact_person_number: user.contact_person_mobile ?? null,

      referral_benefit: user.referral_benefit ?? null,
    }));
  },

  // --------------------------------------------------
  // UPDATE STATUS IN BOTH TABLES
  // --------------------------------------------------
  async updateStatus(userId, isActive) {
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Update user_login
      const result = await client.query(
        `
        WITH updated AS (
          UPDATE user_login
          SET is_active = $1
          WHERE user_id = $2
          RETURNING
            id,
            user_id,
            username,
            mobile_no,
            role,
            is_active,
            created_by,
            assigned_by,
            relationship_type,
            created_at,
            deleted_at,
            deleted_by
        )
        SELECT
          updated.*,
          ur.role_name AS role_name
        FROM updated
        LEFT JOIN lkp_user_roles ur
          ON ur.id = updated.role
        `,
        [isActive, userId],
      );

      if (result.rows.length === 0) {
        await client.query("ROLLBACK");
        return null;
      }

      // Update user_info
      await client.query(
        `
        UPDATE user_info
        SET is_active = $1
        WHERE user_id = $2
        `,
        [isActive, userId],
      );

      await client.query("COMMIT");

      const user = result.rows[0];

      // Return the role name without exposing the numeric role ID
      user.role = user.role_name;
      delete user.role_name;

      return user;
    } catch (error) {
      void logException(error);
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  },

  // --------------------------------------------------
  // UPDATE USER
  // --------------------------------------------------
  async updateUser(client, userId, data) {
    let roleId = null;
    if (data.role) {
      const roleResult = await client.query(
        `
        SELECT id
        FROM lkp_user_roles
        WHERE UPPER(TRIM(role_name)) = UPPER(TRIM($1))
        LIMIT 1
        `,
        [data.role],
      );

      if (roleResult.rows.length === 0) {
        throw new Error(`Role "${data.role}" not found in lkp_user_roles`);
      }

      roleId = roleResult.rows[0].id;
    }

    await client.query(
      `
      UPDATE user_login
      SET 
        mobile_no = COALESCE($1, mobile_no),
        role = COALESCE($2, role),
        is_active = COALESCE($3, is_active)
      WHERE user_id = $4
      `,
      [data.mobileNo, roleId, data.isActive, userId],
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
        contact_person_mobile = $15,
         is_active = COALESCE($16, is_active),
      referral_benefit = COALESCE($17, referral_benefit)
    WHERE user_id = $18
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
        data.isActive,
        data.referralBenefit ?? null,
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
