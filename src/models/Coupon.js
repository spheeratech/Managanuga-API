
const pool = require("../../db");

const findByCode = async (couponCode) => {
  const result = await pool.query(
    `
    SELECT
      coupon_id,
      coupon_name,
      coupon_code,
      coupon_eligible,
      coupon_percentage,
      is_active
    FROM coupons
    WHERE UPPER(TRIM(coupon_code)) = UPPER(TRIM($1))
    LIMIT 1
    `,
    [couponCode]
  );

  return result.rows[0] || null;
};


const createTransaction = async (
  {
    transactionId,
    userId,
    orderId,
    paymentId,
    couponId,
    status = "APPLIED",
    createdBy = null,
    updatedBy = null,
  },
  client = pool
) => {
  const existing = await client.query(
    `
    SELECT *
    FROM coupon_transactions
    WHERE payment_id = $1
      AND coupon_id = $2
    LIMIT 1
    `,
    [paymentId, couponId]
  );

  if (existing.rows.length > 0) {
    return existing.rows[0];
  }

  const result = await client.query(
    `
    INSERT INTO coupon_transactions (
      transaction_id,
      user_id,
      order_id,
      payment_id,
      coupon_id,
      status,
      created_at,
      updated_at,
      created_by,
      updated_by,
      is_active
    )
    VALUES (
      $1, $2, $3, $4, $5, $6,
      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
      $7, $8, 1
    )
    RETURNING *
    `,
    [
      transactionId,
      userId,
      orderId,
      paymentId,
      couponId,
      status,
      createdBy,
      updatedBy,
    ]
  );

  return result.rows[0];
};


module.exports = {
  findByCode,
  createTransaction,
};
