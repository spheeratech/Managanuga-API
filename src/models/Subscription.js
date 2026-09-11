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
    [userId],
  );

  if (result.rows.length === 0) {
    throw new Error("Membership record not found");
  }

  return result.rows[0];
};
const getAdminPlans = async () => {
  const result = await pool.query(`
    SELECT *
    FROM subscription_plans
    ORDER BY display_order ASC, id ASC
  `);

  return result.rows;
};
// ADMIN: CREATE PLAN
const createPlan = async ({
  plan_name,
  plan_price,
  wallet_bonus = 0,
  monthly_claim = 0,
  discount_percentage = 0,
  monthly_limit_litres = 0,
  validity_months,
  description = "",
  display_order = 1,
}) => {
  const result = await pool.query(
    `
    INSERT INTO subscription_plans
    (
      plan_name,
      plan_price,
      wallet_bonus,
      monthly_claim,
      discount_percentage,
      monthly_limit_litres,
      validity_months,
      description,
      display_order,
      is_active
    )
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,true)
    RETURNING *
    `,
    [
      plan_name,
      plan_price,
      wallet_bonus,
      monthly_claim,
      discount_percentage,
      monthly_limit_litres,
      validity_months,
      description,
      display_order,
    ],
  );

  return result.rows[0];
};

// ADMIN: TOGGLE PLAN STATUS
const togglePlanStatus = async (planId) => {
  const result = await pool.query(
    `
    UPDATE subscription_plans
    SET
      is_active = NOT is_active,
      updated_at = CURRENT_TIMESTAMP
    WHERE id = $1
    RETURNING *
    `,
    [planId],
  );

  if (result.rows.length === 0) {
    throw new Error("Subscription plan not found");
  }

  return result.rows[0];
};

// ADMIN: DELETE PLAN
const deletePlan = async (planId) => {
  const result = await pool.query(
    `
    DELETE FROM subscription_plans
    WHERE id = $1
    RETURNING *
    `,
    [planId],
  );

  if (result.rows.length === 0) {
    throw new Error("Subscription plan not found");
  }

  return result.rows[0];
};
// ADMIN: ASSIGN SUBSCRIPTION
const assignSubscription = async (userId, planName) => {
  const result = await pool.query(
    `
    UPDATE user_info
    SET subscription = $1
    WHERE user_id = $2
    RETURNING *
    `,
    [planName, userId],
  );

  if (result.rows.length === 0) {
    throw new Error("User not found");
  }

  return result.rows[0];
};
const activatePlan = async (planId) => {
  const result = await pool.query(
    `
    UPDATE subscription_plans
    SET
      is_active = true,
      updated_at = CURRENT_TIMESTAMP
    WHERE id = $1
    RETURNING *
    `,
    [planId],
  );

  if (result.rows.length === 0) {
    throw new Error("Subscription plan not found");
  }

  return result.rows[0];
};

// =====================================================
// ADMIN: DEACTIVATE PLAN
// =====================================================

const deactivatePlan = async (planId) => {
  const result = await pool.query(
    `
    UPDATE subscription_plans
    SET
      is_active = false,
      updated_at = CURRENT_TIMESTAMP
    WHERE id = $1
    RETURNING *
    `,
    [planId],
  );

  if (result.rows.length === 0) {
    throw new Error("Subscription plan not found");
  }

  return result.rows[0];
};
module.exports = {
  getPlans,
  getAdminPlans,
  acceptTerms,
  createPlan,
  togglePlanStatus,
  deletePlan,
  assignSubscription,
  activatePlan,
  deactivatePlan,
};
