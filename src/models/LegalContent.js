const pool = require("../../db");

const LegalContent = {
  // Get the current legal content
  async get() {
    const result = await pool.query(`
      SELECT
        id,
        terms_conditions,
        privacy_policy,
        customer_care,
        refund_cancellation_policy,
        shipping_delivery,
        created_at,
        updated_at
      FROM legal_content
      WHERE id = 1
      LIMIT 1
    `);

    return result.rows[0] || null;
  },

  // Update legal content
  async update({
    terms_conditions,
    privacy_policy,
    customer_care,
    refund_cancellation_policy,
    shipping_delivery,
  }) {
    const result = await pool.query(
      `
      UPDATE legal_content
      SET
        terms_conditions = $1,
        privacy_policy = $2,
        customer_care = $3,
        refund_cancellation_policy = $4,
        shipping_delivery = $5,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = 1
      RETURNING
        id,
        terms_conditions,
        privacy_policy,
        customer_care,
        refund_cancellation_policy,
        shipping_delivery,
        created_at,
        updated_at
      `,
      [
        terms_conditions,
        privacy_policy,
        customer_care,
        refund_cancellation_policy,
        shipping_delivery,
      ]
    );

    return result.rows[0] || null;
  },
};

module.exports = LegalContent;