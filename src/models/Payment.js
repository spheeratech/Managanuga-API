const pool = require("../../db");

const createPayment = async (data) => {
  const result = await pool.query(
    `INSERT INTO payments (order_id, payment_gateway, amount, status, gateway_order_id, gateway_payment_id, payment_type, membership_plan_id)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
    [
      data.order_id,
      data.payment_gateway,
      data.amount,
      data.status || "PENDING",
      data.gateway_order_id || null,
      data.gateway_payment_id || null,
      data.payment_type || "ORDER",
      data.membership_plan_id || null,
    ],
  );

  return result.rows[0];
};

const getPayments = async () => {
  const result = await pool.query(`SELECT * FROM payments ORDER BY id DESC`);
  return result.rows;
};

const getPaymentById = async (id) => {
  const result = await pool.query(`SELECT * FROM payments WHERE id = $1`, [id]);
  return result.rows[0];
};

const updateByGatewayOrderId = async (gateway_order_id, data) => {
  const result = await pool.query(
    `UPDATE payments SET status=$1, gateway_payment_id=$2
     WHERE gateway_order_id=$3 RETURNING *`,
    [data.status, data.gateway_payment_id, gateway_order_id],
  );

  return result.rows[0];
};

module.exports = {
  createPayment,
  getPayments,
  getPaymentById,
  updateByGatewayOrderId,
};
