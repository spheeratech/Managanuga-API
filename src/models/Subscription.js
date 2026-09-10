const pool = require("../../db");

const getPlans = async () => {
  const result = await pool.query(`
    SELECT *
    FROM subscription_plans
    WHERE is_active = TRUE
    ORDER BY display_order ASC
  `);

  return result.rows;
};

// Accept membership Terms & Conditions
const acceptTerms = async (userId) => {
  const result = await pool.query(
    `
    UPDATE membership
    SET terms_conditions = TRUE
    WHERE user_id = $1
    RETURNING *
    `,
    [userId]
  );

  if (result.rows.length === 0) {
    throw new Error("Membership record not found");
  }

  return result.rows[0];
};

module.exports = {
  getPlans,
  acceptTerms,
};