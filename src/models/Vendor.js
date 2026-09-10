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

    LEFT JOIN orders o
      ON o.user_id = ul.user_id

    WHERE

      ul.created_by = $1

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

    INNER JOIN user_login ul
      ON ul.user_id = o.user_id

    WHERE

      ul.created_by = $1

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

module.exports = {
  getCustomers,
  getOrders,
  getBenefits,
};