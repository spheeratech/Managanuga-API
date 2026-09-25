const pool = require("../../db");

/*
 * ============================================================
 * GET RESELLER CUSTOMERS
 * ============================================================
 *
 * A reseller customer is ONLY a customer who:
 *
 * 1. Has an ACTIVE membership
 * 2. That membership was purchased using this reseller's
 *    referral code
 * 3. The referral_code contains the reseller's public user_id
 *
 * We intentionally DO NOT use user_login.assigned_by here.
 *
 * This prevents users who were manually assigned to a reseller
 * from appearing in the reseller Customers screen unless they
 * actually purchased a membership through the reseller referral.
 */
const getCustomers = async (userId) => {
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
      --AND ul.role IN ('USER', 'CUSTOMER')
      AND ul.is_active = true

    ORDER BY
      ul.user_id,
      ums.id DESC;
    `,
    [String(userId).trim()]
  );

  return result.rows;
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
    [String(resellerId).trim()]
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