const pool = require("../../db");

const getCustomers = async (resellerId) => {
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
      AND ul.role IN ('USER', 'CUSTOMER')

    GROUP BY
      ul.user_id,
      ul.username,
      ul.mobile_no

    ORDER BY
      ul.username ASC;
    `,
    [resellerId]
  );

  return result.rows;
};

const getBenefits = async (resellerId) => {
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
    [resellerId]
  );

  return result.rows;
};

module.exports = {
  getCustomers,
  getBenefits,
};