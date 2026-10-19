
const pool = require("../../db");

/*
 * ============================================================
 * GET CUSTOMERS
 * ============================================================
 */
const getCustomers = async (userId) => {
  const cleanUserId = String(userId).trim();

  /*
   * Find the requesting user's role.
   */
  const roleResult = await pool.query(
    `
    SELECT
      user_id,
      role
    FROM user_login
    WHERE
      user_id = $1
      AND is_active = 1
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
   * RESELLER CUSTOMERS — ROLE 4
   * ============================================================
   *
   * Uses the corrected database function:
   * public.get_customers_by_referalid(character varying)
   *
   * The function returns customers, their membership plan,
   * and membership status.
   */
  if (Number(currentUser.role) === 4) {
    const result = await pool.query(
      `
      SELECT *
      FROM public.get_customers_by_referalid($1);
      `,
      [cleanUserId]
    );

    return result.rows;
  }

  /*
   * ============================================================
   * VENDOR CUSTOMERS — ROLE 3
   * ============================================================
   *
   * Customer relationship:
   * user_login.assigned_by = vendor.user_id
   *
   * Uses payable_amount from orders, avoiding references to
   * nonexistent columns items_cost and total_amount.
   */
  if (Number(currentUser.role) === 3) {
    const result = await pool.query(
      `
      SELECT
        ul.user_id,
        ul.username,
        ul.mobile_no,
        ur.role_name AS role,

        COUNT(o.id)::INTEGER AS total_orders,

        COALESCE(
          SUM(COALESCE(o.payable_amount, 0)),
          0
        ) AS total_paid_amount

      FROM public.user_login ul

      LEFT JOIN public.orders o
        ON o.user_id = ul.user_id

      LEFT JOIN public.lkp_user_roles ur
        ON ur.id = ul.role

      WHERE
        ul.assigned_by = $1
        AND ul.role IN (5, 6)
        AND ul.is_active = 1

      GROUP BY
        ul.user_id,
        ul.username,
        ul.mobile_no,
        ur.role_name

      ORDER BY
        ul.username ASC;
      `,
      [cleanUserId]
    );

    return result.rows;
  }

  /*
   * Unsupported role.
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
      wt.id,
      NULLIF(
        substring(wt.description FROM 'membership_id=([^;]+)'),
        ''
      )::INTEGER AS membership_id,
      wt.benefited_by AS customer_id,
      wt.user_id AS beneficiary_id,
      'RESELLER' AS beneficiary_role,
      wt.benefit_percentage AS benefit_percent,
      wt.benefit_amount,
      'CREDITED' AS status,
      wt.created_at
    FROM public.wallet_transactions wt
    WHERE wt.user_id = $1
      AND wt.transaction_type = 'CREDIT'
      AND wt.benefit_type IN (
        'REFERRAL',
        'MEMBERSHIP_COMMISSION'
      )
      AND wt.status = 'COMPLETED'
      AND wt.is_active = 1
    ORDER BY
      wt.created_at DESC,
      wt.id DESC;
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

    FROM public.user_login ul

    INNER JOIN public.user_info ui
      ON ui.user_id = ul.user_id

    WHERE
      ul.user_id = $1
      AND ul.role = 4
      AND ul.is_active = 1

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
