const pool = require("../../db");

/*
 * ============================================================
 * GET CUSTOMERS - VENDOR
 *
 * Customer relationship:
 *   user_login.assigned_by = vendor public user_id
 *
 * Membership:
 *   user_memberships.user_id = customer public user_id
 * ============================================================
 */
const getCustomers = async (vendorId) => {
  const cleanVendorId = String(vendorId).trim();

  const result = await pool.query(
    `
    SELECT
      ul.user_id,
      ul.username,
      ul.mobile_no,
      ul.role,

      COUNT(DISTINCT o.id)::INTEGER AS total_orders,

      COALESCE(
        SUM(DISTINCT o.total_amount),
        0
      ) AS total_order_amount,

      COALESCE(
        MAX(
          CASE
            WHEN ums.status = 'ACTIVE'
            THEN sp.plan_name
          END
        ),
        'No Membership'
      ) AS plan_name,

      COALESCE(
        MAX(
          CASE
            WHEN ums.status = 'ACTIVE'
            THEN ums.status
          END
        ),
        'INACTIVE'
      ) AS membership_status

    FROM user_login ul

    LEFT JOIN orders o
      ON o.user_id = ul.user_id

    LEFT JOIN user_memberships ums
      ON ums.user_id = ul.user_id

    LEFT JOIN subscription_plans sp
      ON sp.id = ums.plan_id

    WHERE ul.assigned_by = $1
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
    [cleanVendorId]
  );

  return result.rows;
};


/*
 * ============================================================
 * GET ORDERS
 * ============================================================
 */
const getOrders = async (vendorId) => {
  const result = await pool.query(
    `
    SELECT
      o.id,
      ul.user_id AS customer_user_id,
      ul.username AS customer_name,
      ul.mobile_no AS customer_mobile,
      o.total_amount,
      o.items_cost,
      o.membership_discount,
      o.wallet_claim,
      o.delivery_charge,
      o.status,
      o.payment_status,
      o.tracking_number,
      o.courier_name,
      o.delivery_method,
      o.address_id,
      o.warehouse_id,
      o.admin_verified,
      o.admin_accepted,
      o.created_at
    FROM orders o
    INNER JOIN user_login ul
      ON ul.user_id = o.user_id
    WHERE ul.assigned_by = $1
      AND ul.role IN ('USER', 'CUSTOMER')
      AND ul.is_active = true
    ORDER BY o.created_at DESC;
    `,
    [String(vendorId).trim()]
  );

  return result.rows;
};


/*
 * ============================================================
 * GET BENEFITS
 * ============================================================
 */
const getBenefits = async (vendorId) => {
  const result = await pool.query(
    `
    SELECT
      b.id,
      b.membership_id,
      b.customer_id,
      b.beneficiary_id,
      b.beneficiary_role,
      b.benefit_percent,
      b.benefit_amount,
      b.status,
      b.created_at
    FROM benefits b
    WHERE b.beneficiary_id = $1
      AND b.beneficiary_role = 'VENDOR'
    ORDER BY b.created_at DESC;
    `,
    [String(vendorId).trim()]
  );

  return result.rows;
};


/*
 * ============================================================
 * GET PROFILE
 * ============================================================
 */
const getProfile = async (userId) => {
  const result = await pool.query(
    `
    SELECT
      ul.user_id,
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
    WHERE ul.user_id = $1
      AND ul.role = 'VENDOR'
      AND ul.is_active = true
    LIMIT 1;
    `,
    [String(userId).trim()]
  );

  return result.rows[0] || null;
};


module.exports = {
  getCustomers,
  getOrders,
  getBenefits,
  getProfile,
};