const pool = require("../../db");

/* --------------------------------
   CREATE PAYMENT
-------------------------------- */
const createPayment = async (data) => {
  const result = await pool.query(
    `
    INSERT INTO payments
    (
      order_id,
      tnx_order_id,
      payment_gateway,
      actual_amount,
      payable_amount,
      status,
      payment_type,
      membership_plan_id
    )
    VALUES
    ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING *
    `,
    [
      data.order_id || null,
      data.tnx_order_id || null,
      data.payment_gateway || "RAZORPAY",
      data.actual_amount ?? null,
      data.payable_amount ?? null,
      data.status || "PENDING",
      data.payment_type || "ORDER",
      data.membership_plan_id || null,
    ]
  );

  return result.rows[0];
};


/* --------------------------------
   GET ALL PAYMENTS
-------------------------------- */
const getPayments = async () => {
  const result = await pool.query(
    `
    SELECT *
    FROM payments
    ORDER BY id DESC
    `
  );

  return result.rows;
};


/* --------------------------------
   GET PAYMENT BY ID
-------------------------------- */
const getPaymentById = async (id) => {
  const result = await pool.query(
    `
    SELECT *
    FROM payments
    WHERE id = $1
    `,
    [id]
  );

  return result.rows[0];
};


/* --------------------------------
   UPDATE PAYMENT BY RAZORPAY ORDER ID
-------------------------------- */
const updateByTnxOrderId = async (
  tnx_order_id,
  data
) => {
  const result = await pool.query(
    `
    UPDATE payments
    SET
      status = COALESCE($1, status),
      payment_id = COALESCE($2, payment_id),
      upi_transaction_id = COALESCE($3, upi_transaction_id),
      method = COALESCE($4, method),
      actual_amount = COALESCE($5, actual_amount),
      payable_amount = COALESCE($6, payable_amount)
    WHERE tnx_order_id = $7
    RETURNING *
    `,
    [
      data.status || null,
      data.payment_id || null,
      data.upi_transaction_id || null,
      data.method || null,
      data.actual_amount ?? null,
      data.payable_amount ?? null,
      tnx_order_id,
    ]
  );

  return result.rows[0];
};


/* --------------------------------
   LINK PAYMENT TO MGO ORDER
-------------------------------- */
const linkPaymentToOrder = async ({
  paymentId,
  orderId,
  transOrderId,
  status,
}) => {
  const result = await pool.query(
    `
    UPDATE payments
    SET
      order_id = COALESCE($1, order_id),
      tnx_order_id = COALESCE($2, tnx_order_id),
      status = COALESCE($3, status)
    WHERE id = $4
    RETURNING *
    `,
    [
      orderId || null,
      transOrderId || null,
      status || null,
      paymentId,
    ]
  );

  return result.rows[0];
};


/* --------------------------------
   CREATE PAYMENT LOG
-------------------------------- */
const createPaymentLog = async (data) => {
  const result = await pool.query(
    `
    INSERT INTO payments_log
    (
      user_id,
      order_id,
      order_type,
      payment_request,
      payment_response
    )
    VALUES
    ($1, $2, $3, $4, $5)
    RETURNING *
    `,
    [
      data.user_id,
      data.order_id,
      data.order_type,
      data.payment_request || null,
      data.payment_response || null,
    ]
  );

  return result.rows[0];
};


module.exports = {
  createPayment,
  getPayments,
  getPaymentById,
  updateByTnxOrderId,
  linkPaymentToOrder,
  createPaymentLog,
};