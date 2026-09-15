const pool = require("../../db");

const getCustomers = async (vendorId) => {
  const result = await pool.query(
    `
    SELECT
      ul.user_id,
      ul.username,
      ul.mobile_no,
      COUNT(o.id) AS total_orders
    FROM user_login ul
    LEFT JOIN users u
      ON u.mobile = ul.mobile_no
    LEFT JOIN orders o
      ON o.entity_id = u.id
    WHERE
      ul.assigned_by = $1
      AND ul.role IN ('USER','CUSTOMER')
    GROUP BY
      ul.user_id,
      ul.username,
      ul.mobile_no
    ORDER BY
      ul.username ASC;
    `,
    [vendorId]
  );

  return result.rows;
};

const getOrders = async (vendorId) => {
  const result = await pool.query(
    `
    SELECT
      o.id,
      ul.user_id,
      ul.username,
      ul.mobile_no,
      o.total_amount,
      o.status,
      o.payment_status,
      o.created_at
    FROM orders o
    INNER JOIN users u
      ON u.id = o.entity_id
    INNER JOIN user_login ul
  ON ul.mobile_no = u.mobile
    WHERE
      ul.assigned_by = $1
      AND ul.role IN ('USER','CUSTOMER')
    ORDER BY
      o.created_at DESC;
    `,
    [vendorId]
  );

  return result.rows;
};

// Get vendor membership benefits
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

    WHERE

      b.beneficiary_id = $1

      AND b.beneficiary_role = 'VENDOR'

    ORDER BY

      b.created_at DESC;
    `,
    [vendorId]
  );

  return result.rows;

};

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
      ui.bank_account_no,
      ui.ifsc_code,
      ui.bank_name,
      ui.bank_holder_name
    FROM user_login ul
    INNER JOIN user_info ui
      ON ui.mobile = ul.mobile_no
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
