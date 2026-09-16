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
    WHERE ul.user_id = $1
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
  getProfile
};