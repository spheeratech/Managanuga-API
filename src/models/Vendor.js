const pool = require("../../db");

const getCustomers = async (vendorId) => {
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

    FROM user_login ul

    LEFT JOIN orders o
      ON o.user_id = ul.user_id
    LEFT JOIN lkp_user_roles ur
      ON ur.id = ul.role

    WHERE ul.assigned_by = $1
      AND ul.role IN (5, 6)
      AND ul.is_active = 1

    GROUP BY
      ul.user_id,
      ul.username,
      ul.mobile_no,
      ur.role_name

    ORDER BY ul.username ASC;
    `,
    [String(vendorId).trim()]
  );

  return result.rows;
};


const getOrders = async (vendorId) => {
  const result = await pool.query(
    `
    SELECT
      o.id,

      ul.user_id AS customer_user_id,
      ul.username AS customer_name,
      ul.mobile_no AS customer_mobile,

      o.actual_amount,
      o.membership_discount,
      o.wallet_claim,
      o.delivery_charge,
      o.payable_amount,

      COALESCE(o.payable_amount, 0) AS paid_amount,

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
      AND ul.role IN (5, 6)
      AND ul.is_active = 1

    ORDER BY o.created_at DESC;
    `,
    [String(vendorId).trim()]
  );

  return result.rows;
};



const getBenefits = async (vendorId) => {
  const cleanVendorId = String(vendorId || "").trim();

  if (!cleanVendorId) {
    return [];
  }

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
      'VENDOR' AS beneficiary_role,
      wt.benefit_percentage AS benefit_percent,
      wt.benefit_amount,
      'CREDITED' AS status,
      wt.created_at,
      wt.benefit_type,
      wt.description
    FROM public.wallet_transactions wt
    INNER JOIN public.user_wallet uw
      ON uw.wallet_id = wt.wallet_id
     AND uw.user_id = wt.user_id
    WHERE wt.user_id = $1
      AND wt.transaction_type = 'CREDIT'
      AND wt.benefit_type IN (
        'REFERRAL',
        'MEMBERSHIP_COMMISSION'
      )
      AND wt.status = 'COMPLETED'
      AND wt.is_active = 1
      AND uw.is_active = 1
    ORDER BY wt.created_at DESC, wt.id DESC;
    `,
    [cleanVendorId]
  );

  return result.rows;
};




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
      AND ul.role = 3
      AND ul.is_active = 1

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