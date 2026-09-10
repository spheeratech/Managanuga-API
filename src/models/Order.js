const pool = require("../../db");
const Order = require("../models/Order");
const xpressbeesService = require("../services/xpressbeesService");
/* --------------------------------
   CREATE ORDER FROM CART
-------------------------------- */
const createOrder = async (
  entity_type,
  entity_id,
  address_id,
  buyNow = false,
  productId = null,
  quantity = 1,
) => {

  // Get cart items
  const cartResult = await pool.query(
    `
    SELECT
      c.item_id,
      c.quantity,
      p.price
    FROM cart_items c
    JOIN products p
      ON p.id = c.item_id
    WHERE c.entity_type = $1
      AND c.entity_id = $2
    `,
    [entity_type, entity_id],
  );

  let cartItems = cartResult.rows;
  console.log("Cart row count:", cartResult.rowCount);
  console.log("Cart items:", cartResult.rows);

if (buyNow) {
  const productResult = await pool.query(
    `
    SELECT
      id AS item_id,
      price
    FROM products
    WHERE id = $1
    `,
    [productId],
  );

  if (productResult.rowCount === 0) {
    return null;
  }

  cartItems = [
    {
      item_id: productResult.rows[0].item_id,
      quantity,
      price: productResult.rows[0].price,
    },
  ];
} else {
  if (cartResult.rowCount === 0) {
    return null;
  }

}

  // Calculate total
  const totalAmount = cartItems.reduce(
    (sum, item) => sum + item.quantity * item.price,
    0,
  );

  // Create order
  const orderResult = await pool.query(
    `
    INSERT INTO orders(
      entity_type,
      entity_id,
      address_id,
      total_amount
    )
    VALUES($1,$2,$3,$4)
    RETURNING *
    `,
    [entity_type, entity_id, address_id, totalAmount],
  );

  const order = orderResult.rows[0];

  // Copy items into order_items
  for (const item of cartItems) {
    await pool.query(
      `
      INSERT INTO order_items(
        order_id,
        item_type,
        item_id,
        quantity,
        unit_price
      )
      VALUES($1,$2,$3,$4,$5)
      `,
      [order.id, "PRODUCT", item.item_id, item.quantity, item.price],
    );
  }

  // Clear cart after successful order creation
await pool.query(
  `
  DELETE FROM cart_items
  WHERE entity_type = $1
    AND entity_id = $2
  `,
  [entity_type, entity_id],
);

return order;
};
const createBuyNowOrder = async (
  entity_type,
  entity_id,
  address_id,
  productId,
  quantity = 1,
) => {
  const productResult = await pool.query(
    `
    SELECT id, price
    FROM products
    WHERE id = $1
    `,
    [productId],
  );

  if (productResult.rowCount === 0) {
    return null;
  }

  const product = productResult.rows[0];

  const totalAmount = product.price * quantity;

  const orderResult = await pool.query(
    `
    INSERT INTO orders(
      entity_type,
      entity_id,
      address_id,
      total_amount
    )
    VALUES($1,$2,$3,$4)
    RETURNING *
    `,
    [entity_type, entity_id, address_id, totalAmount],
  );

  const order = orderResult.rows[0];

  await pool.query(
    `
    INSERT INTO order_items(
      order_id,
      item_type,
      item_id,
      quantity,
      unit_price
    )
    VALUES($1,$2,$3,$4,$5)
    `,
    [
      order.id,
      "PRODUCT",
      product.id,
      quantity,
      product.price,
    ],
  );

  return order;
};

/* --------------------------------
   GET ALL ORDERS
-------------------------------- */
const getOrders = async () => {
  const result = await pool.query(`
    SELECT *
    FROM orders
    ORDER BY id DESC
  `);

  return result.rows;
};

/* --------------------------------
   GET ORDER BY ID
-------------------------------- */
const getOrderById = async (id) => {
  const result = await pool.query(
    `
    SELECT
      o.*,
      a.full_name,
      a.phone,
      a.address_line1,
      a.address_line2,
      a.city,
      a.state,
      a.country,
      a.postal_code
    FROM orders o
    LEFT JOIN addresses a
      ON a.id = o.address_id
    WHERE o.id = $1
    `,
    [id]
  );

  return result.rows[0];
};

/* --------------------------------
   GET ORDERS BY ENTITY
-------------------------------- */
const getOrdersByEntity = async (entity_type, entity_id) => {
  const result = await pool.query(
    `
    SELECT
      id,
      total_amount,
      status,
      created_at
    FROM orders
    WHERE entity_type = $1
      AND entity_id = $2
    ORDER BY id DESC
    `,
    [entity_type, entity_id]
  );

  return result.rows;
};

/* --------------------------------
   GET ORDER ITEMS
-------------------------------- */
const getOrderItems = async (orderId) => {
  const result = await pool.query(
    `
    SELECT
      oi.id,
      oi.item_id AS product_id,
      p.name AS product_name,
      p.image,
      oi.quantity,
      oi.unit_price,
      (oi.quantity * oi.unit_price) AS total_price
    FROM order_items oi
    JOIN products p
      ON p.id = oi.item_id
    WHERE oi.order_id = $1
    `,
    [orderId],
  );

  return result.rows;
};

/* --------------------------------
   UPDATE ORDER
-------------------------------- */
const updateOrder = async (id, status) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET status = $1
    WHERE id = $2
    RETURNING *
    `,
    [status, id],
  );

  return result.rows[0];
};

/* --------------------------------
   DELETE ORDER
-------------------------------- */
const deleteOrder = async (id) => {
  await pool.query(
    `
    DELETE FROM order_items
    WHERE order_id = $1
    `,
    [id],
  );

  const result = await pool.query(
    `
    DELETE FROM orders
    WHERE id = $1
    RETURNING *
    `,
    [id],
  );

  return result.rows[0];
};
const shipOrder = async (orderId, trackingNumber, courierName) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET
      tracking_number = $2,
      courier_name = $3,
      status = 'PROCESSING'
    WHERE id = $1
    RETURNING *;
    `,
    [orderId, trackingNumber, courierName]
  );

  return result.rows[0];
};
const trackOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const order = await Order.getOrderById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    if (!order.tracking_number) {
      return res.status(400).json({
        success: false,
        message: "Tracking number not found",
      });
    }

    const tracking = await xpressbeesService.trackShipment(
      order.tracking_number
    );

    return res.json(tracking);

  } catch (err) {
    console.error(err);

    return res.status(500).json({
      success: false,
      message: "Tracking failed",
    });
  }
};

module.exports = {
  createOrder,
  createBuyNowOrder,
  getOrders,
  getOrderById,
  getOrdersByEntity,
  getOrderItems,
  updateOrder,
  deleteOrder,
  shipOrder,
  trackOrder,
};