const pool = require("../../db");

/*
 * ============================================================
 * GET CUSTOMERS - COMMON VENDOR / RESELLER API
 * ============================================================
 *
 * Endpoint:
 *
 *   /reseller/customers?userId=...
 *
 * The user's role determines which customer relationship is used.
 *
 * RESELLER:
 *   Customer must have an ACTIVE membership purchased through
 *   this reseller's referral link.
 *
 *   user_memberships.referral_code = reseller.user_id
 *
 * VENDOR:
 *   Preserve the existing Vendor customer relationship.
 *
 *   user_login.assigned_by = vendor.user_id
 *
 * IMPORTANT:
 *   The frontend API does NOT need to change.
 */
const getCustomers = async (userId) => {
  const cleanUserId = String(userId).trim();

  /*
   * ------------------------------------------------------------
   * Find the requesting user's role.
   * ------------------------------------------------------------
   */
  const roleResult = await pool.query(
    `
    SELECT
      user_id,
      role
    FROM user_login
    WHERE
      user_id = $1
      AND is_active = true
    LIMIT 1;
    `,
    [cleanUserId]
  );

  const currentUser = roleResult.rows[0];

  if (!currentUser) {
    return [];
  }


  /*
   * ============================================================
   * RESELLER CUSTOMERS
   * ============================================================
   *
   * Only customers who actually purchased an ACTIVE membership
   * through this reseller's referral code.
   */
  if (currentUser.role === "RESELLER") {
    const result = await pool.query(
      `
      SELECT DISTINCT ON (ul.user_id)

        ul.user_id AS customer_user_id,
        ul.username AS customer_name,
        ul.mobile_no AS customer_mobile,

        sp.plan_name,

        ums.status

      FROM user_memberships ums

      INNER JOIN user_login ul
        ON ul.user_id = ums.user_id

      INNER JOIN subscription_plans sp
        ON sp.id = ums.plan_id

      WHERE
        ums.referral_code = $1
        AND ums.status = 'ACTIVE'
        AND ul.role IN ('USER', 'CUSTOMER')
        AND ul.is_active = true

      ORDER BY
        ul.user_id,
        ums.id DESC;
      `,
      [cleanUserId]
    );

    return result.rows;
  }


  /*
   * ============================================================
   * VENDOR CUSTOMERS
   * ============================================================
   *
   * This is intentionally kept equivalent to the existing
   * Vendor.getCustomers() query.
   *
   * Therefore Vendor Customers will continue to show:
   *
   *   user_id
   *   username
   *   mobile_no
   *   role
   *   total_orders
   *   total_order_amount
   *
   * while using the same common API endpoint.
   */
  if (currentUser.role === "VENDOR") {
    const result = await pool.query(
      `
      SELECT
        ul.user_id,
        ul.username,
        ul.mobile_no,
        ul.role,

        COUNT(o.id)::INTEGER AS total_orders,

        COALESCE(
          SUM(o.total_amount),
          0
        ) AS total_order_amount

      FROM user_login ul

      LEFT JOIN orders o
        ON o.user_id = ul.user_id

      WHERE
        ul.assigned_by = $1
        AND ul.role IN ('USER', 'CUSTOMER')
        AND ul.is_active = true

      GROUP BY
        ul.user_id,
        ul.username,
        ul.mobile_no,
        ul.role

      ORDER BY
        ul.username ASC;
      `,
      [cleanUserId]
    );

    return result.rows;
  }


  /*
   * ============================================================
   * UNKNOWN / UNSUPPORTED ROLE
   * ============================================================
   */
  return [];
};


/*
 * ============================================================
 * GET RESELLER BENEFITS
 * ============================================================
 */
const getBenefits = async (userId) => {
  const result = await pool.query(
    `
    SELECT
      id,
      membership_id,
      customer_id,
      beneficiary_id,
      beneficiary_role,
      benefit_percent,
      benefit_amount,
      status,
      created_at

    FROM benefits

    WHERE
      beneficiary_id = $1
      AND beneficiary_role = 'RESELLER'

    ORDER BY
      created_at DESC;
    `,
    [String(userId).trim()]
  );

  return result.rows;
};


/*
 * ============================================================
 * GET RESELLER PROFILE
 * ============================================================
 */
const getProfile = async (userId) => {
  const result = await pool.query(
    `
    SELECT
      ui.user_id,
      ui.first_name,
      ui.last_name,
      ui.email,
      ui.mobile,
      ui.address,
      ui.city,
      ui.state,
      ui.pincode,
      ui.contact_person_name,
      ui.contact_person_mobile,
      ui.bank_account_no,
      ui.ifsc_code,
      ui.bank_name,
      ui.bank_holder_name

    FROM user_login ul

    INNER JOIN user_info ui
      ON ui.user_id = ul.user_id

    WHERE
      ul.user_id = $1
      AND ul.role = 'RESELLER'
      AND ul.is_active = true

    LIMIT 1;
    `,
    [String(userId).trim()]
  );

  return result.rows[0] || null;
};


module.exports = {
  getCustomers,
  getBenefits,
  getProfile,
};