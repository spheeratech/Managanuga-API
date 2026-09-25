const pool = require("../../db");

const getCustomers = async (resellerId) => {
  const result = await pool.query(
    `
    SELECT
      ul.user_id,
      ul.username,
      ul.mobile_no,
      ul.role,

      COUNT(DISTINCT o.id) AS total_orders,

      COALESCE(
        SUM(
          CASE
            WHEN o.id IS NOT NULL
            THEN o.total_amount
            ELSE 0
          END
        ),
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
      ul.id,
      ul.user_id,
      ul.username,
      ul.mobile_no,
      ul.role

    ORDER BY
      ul.username ASC;
    `,
    [String(resellerId).trim()]
  );

  return result.rows;
};


const getOrders = async (resellerId) => {
  const result = await pool.query(
    `
    SELECT
      o.id,
      o.user_id AS customer_user_id,

      customer.username AS customer_name,
      customer.mobile_no AS customer_mobile,

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

    INNER JOIN LATERAL (
      SELECT
        ul.user_id,
        ul.username,
        ul.mobile_no

      FROM user_login ul

      WHERE
        ul.user_id = o.user_id
        AND ul.assigned_by = $1
        AND ul.role IN ('USER', 'CUSTOMER')
        AND ul.is_active = true

      ORDER BY
        ul.id DESC

      LIMIT 1
    ) customer ON true

    ORDER BY
      o.created_at DESC,
      o.id DESC;
    `,
    [String(resellerId).trim()]
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
    [String(resellerId).trim()]
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
  getOrders,
  getBenefits,
  getProfile,
};