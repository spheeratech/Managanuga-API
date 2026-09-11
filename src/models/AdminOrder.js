const pool = require("../../db");

/* --------------------------------
   CREATE ADMIN ORDER
-------------------------------- */

const createAdminOrder = async ({
  user_id,
  productId,
  quantity = 1,
  warehouse_id = null,
}) => {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // --------------------------------
    // GET CUSTOMER
    // --------------------------------

    const userResult = await client.query(
      `
      SELECT
        ul.user_id,
        ul.username,
        ul.mobile_no,
        ui.first_name,
        ui.last_name,
        ui.email,
        ui.address,
        ui.city,
        ui.state,
        ui.pincode
      FROM user_login ul
      LEFT JOIN user_info ui
        ON ul.user_id = ui.user_id
      WHERE ul.user_id = $1::varchar
      `,
      [String(user_id)],
    );

    if (userResult.rowCount === 0) {
      throw new Error("Customer not found");
    }

    const customer = userResult.rows[0];

    // --------------------------------
    // GET PRODUCT
    // --------------------------------

    const productResult = await client.query(
      `
      SELECT
        id,
        name,
        price,
        stock
      FROM products
      WHERE id = $1::integer
      `,
      [Number(productId)],
    );

    if (productResult.rowCount === 0) {
      throw new Error("Product not found");
    }

    const product = productResult.rows[0];

    // --------------------------------
    // VALIDATE QUANTITY
    // --------------------------------

    const orderQuantity = Number(quantity);

    if (!Number.isInteger(orderQuantity) || orderQuantity <= 0) {
      throw new Error("Quantity must be a positive number");
    }

    // --------------------------------
    // STOCK CHECK
    // --------------------------------

    if (Number(product.stock) < orderQuantity) {
      throw new Error(`Insufficient stock. Available stock: ${product.stock}`);
    }

    // --------------------------------
    // CALCULATE TOTAL
    // --------------------------------

    const totalAmount = Number(product.price) * orderQuantity;

    // --------------------------------
    // CREATE ORDER
    // --------------------------------

    const orderResult = await client.query(
      `
      INSERT INTO orders
      (
        user_id,
        entity_type,
        entity_id,
        total_amount,
        warehouse_id,
        status,
        payment_status
      )
      VALUES
      (
        $1::varchar,
        'USER',
        0,
        $2::numeric,
        $3::integer,
        'PENDING',
        'PENDING'
      )
      RETURNING *
      `,
      [
        String(user_id),
        totalAmount,
        warehouse_id === null ? null : Number(warehouse_id),
      ],
    );

    const order = orderResult.rows[0];

    // --------------------------------
    // CREATE ORDER ITEM
    // --------------------------------

    await client.query(
      `
      INSERT INTO order_items
      (
        order_id,
        item_type,
        item_id,
        quantity,
        unit_price
      )
      VALUES
      (
        $1::integer,
        'PRODUCT',
        $2::integer,
        $3::integer,
        $4::numeric
      )
      `,
      [order.id, Number(product.id), orderQuantity, Number(product.price)],
    );

    // --------------------------------
    // DEDUCT STOCK
    // --------------------------------

    await client.query(
      `
      UPDATE products
      SET stock = stock - $1::integer
      WHERE id = $2::integer
      `,
      [orderQuantity, Number(product.id)],
    );

    // --------------------------------
    // COMMIT
    // --------------------------------

    await client.query("COMMIT");

    // --------------------------------
    // RETURN CREATED ORDER
    // --------------------------------

    return {
      ...order,

      customer: {
        user_id: customer.user_id,

        name:
          `${customer.first_name || ""} ${customer.last_name || ""}`.trim() ||
          customer.username,

        mobile_no: customer.mobile_no,
        email: customer.email,
        address: customer.address,
        city: customer.city,
        state: customer.state,
        pincode: customer.pincode,
      },

      items: [
        {
          product_id: product.id,
          product_name: product.name,
          quantity: orderQuantity,
          price: product.price,
          subtotal: totalAmount,
        },
      ],
    };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

/* --------------------------------
   GET ALL ADMIN ORDERS
-------------------------------- */

const getAdminOrders = async () => {
  const result = await pool.query(`
    SELECT
      o.id,
      o.user_id,
      o.entity_type,
      o.entity_id,
      o.total_amount,
      o.warehouse_id,
      o.status,
      o.payment_status,
      o.tracking_number,
      o.courier_name,
      o.created_at,

      -- USER LOGIN DETAILS
      ul.username,
      ul.mobile_no AS customer_phone,

      -- USER PROFILE DETAILS
      ui.first_name,
      ui.last_name,
      ui.email AS customer_email,

      -- ADDRESS DETAILS
      ui.address AS customer_address,
      ui.city AS customer_city,
      ui.state AS customer_state,
      ui.pincode AS customer_pincode,

      -- FINAL CUSTOMER NAME
      COALESCE(
        NULLIF(
          TRIM(
            CONCAT(
              COALESCE(ui.first_name, ''),
              ' ',
              COALESCE(ui.last_name, '')
            )
          ),
          ''
        ),
        NULLIF(ul.username, ''),
        CONCAT('Customer #', o.user_id)
      ) AS customer_name

    FROM orders o

    LEFT JOIN user_login ul
      ON CAST(o.user_id AS VARCHAR) = CAST(ul.user_id AS VARCHAR)

    LEFT JOIN user_info ui
      ON CAST(o.user_id AS VARCHAR) = CAST(ui.user_id AS VARCHAR)

    ORDER BY o.id DESC
  `);

  return result.rows;
};

/* --------------------------------
   GET ADMIN ORDER BY ID
-------------------------------- */

const getAdminOrderById = async (id) => {
  const orderResult = await pool.query(
    `
    SELECT
      o.*,

      COALESCE(
        NULLIF(
          TRIM(
            CONCAT(
              COALESCE(ui.first_name, ''),
              ' ',
              COALESCE(ui.last_name, '')
            )
          ),
          ''
        ),
        ul.username
      ) AS customer_name,

      ul.mobile_no AS customer_phone,
      ui.email AS customer_email,
      ui.address,
      ui.city,
      ui.state,
      ui.pincode

    FROM orders o

    LEFT JOIN user_login ul
      ON o.user_id = ul.user_id

    LEFT JOIN user_info ui
      ON o.user_id = ui.user_id

    WHERE o.id = $1::integer
    `,
    [Number(id)],
  );

  if (orderResult.rowCount === 0) {
    return null;
  }

  const order = orderResult.rows[0];

  // --------------------------------
  // GET ORDER ITEMS
  // --------------------------------

  const itemsResult = await pool.query(
    `
    SELECT
      oi.id,
      oi.item_id AS product_id,
      p.name AS product_name,
      oi.quantity,
      oi.unit_price,
      (oi.quantity * oi.unit_price) AS subtotal

    FROM order_items oi

    JOIN products p
      ON p.id = oi.item_id

    WHERE oi.order_id = $1::integer

    ORDER BY oi.id
    `,
    [Number(id)],
  );

  return {
    ...order,
    items: itemsResult.rows,
  };
};

/* --------------------------------
   UPDATE ADMIN ORDER
-------------------------------- */

const updateAdminOrder = async (
  id,
  { status, payment_status, warehouse_id, tracking_number, courier_name },
) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET
      status = COALESCE($1, status),
      payment_status = COALESCE($2, payment_status),
      warehouse_id = COALESCE($3, warehouse_id),
      tracking_number = COALESCE($4, tracking_number),
      courier_name = COALESCE($5, courier_name)

    WHERE id = $6::integer

    RETURNING *
    `,
    [
      status ?? null,
      payment_status ?? null,

      warehouse_id === undefined || warehouse_id === null
        ? null
        : Number(warehouse_id),

      tracking_number ?? null,
      courier_name ?? null,

      Number(id),
    ],
  );

  return result.rows[0] || null;
};

/* --------------------------------
   DELETE ADMIN ORDER
-------------------------------- */

const deleteAdminOrder = async (id) => {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // --------------------------------
    // GET ORDER ITEMS
    // --------------------------------

    const itemsResult = await client.query(
      `
      SELECT
        item_id,
        quantity
      FROM order_items
      WHERE order_id = $1::integer
      `,
      [Number(id)],
    );

    // --------------------------------
    // RESTORE PRODUCT STOCK
    // --------------------------------

    for (const item of itemsResult.rows) {
      await client.query(
        `
        UPDATE products
        SET stock = stock + $1::integer
        WHERE id = $2::integer
        `,
        [Number(item.quantity), Number(item.item_id)],
      );
    }

    // --------------------------------
    // DELETE ORDER ITEMS
    // --------------------------------

    await client.query(
      `
      DELETE FROM order_items
      WHERE order_id = $1::integer
      `,
      [Number(id)],
    );

    // --------------------------------
    // DELETE ORDER
    // --------------------------------

    const result = await client.query(
      `
      DELETE FROM orders
      WHERE id = $1::integer
      RETURNING *
      `,
      [Number(id)],
    );

    await client.query("COMMIT");

    return result.rows[0] || null;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};
/* --------------------------------
   DELETE ALL ADMIN ORDERS
-------------------------------- */

const deleteAllAdminOrders = async () => {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // --------------------------------
    // GET ALL ORDER ITEMS
    // --------------------------------

    const itemsResult = await client.query(`
      SELECT
        item_id,
        quantity
      FROM order_items
    `);

    // --------------------------------
    // RESTORE PRODUCT STOCK
    // --------------------------------

    for (const item of itemsResult.rows) {
      await client.query(
        `
        UPDATE products
        SET stock = stock + $1::integer
        WHERE id = $2::integer
        `,
        [Number(item.quantity), Number(item.item_id)],
      );
    }

    // --------------------------------
    // DELETE ALL ORDER ITEMS
    // --------------------------------

    await client.query(`
      DELETE FROM order_items
    `);

    // --------------------------------
    // DELETE ALL ORDERS
    // --------------------------------

    const result = await client.query(`
      DELETE FROM orders
      RETURNING *
    `);

    // --------------------------------
    // COMMIT
    // --------------------------------

    await client.query("COMMIT");

    return result.rows;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

/* --------------------------------
   VERIFY / ACCEPT ADMIN ORDER
-------------------------------- */

const verifyAdminOrder = async (
  id,
  { status = "PROCESSING", delivery_method },
) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET
      status = $1,
      admin_verified = TRUE,
      admin_accepted = TRUE,
      delivery_method = $2
    WHERE id = $3::integer
    RETURNING *
    `,
    [status, delivery_method, Number(id)],
  );

  return result.rows[0] || null;
};
/* --------------------------------
   UPDATE SHIPMENT DETAILS
-------------------------------- */

const updateShipmentDetails = async (id, { tracking_number, courier_name }) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET
      tracking_number = $1,
      courier_name = $2
    WHERE id = $3::integer
    RETURNING *
    `,
    [tracking_number ?? null, courier_name ?? null, Number(id)],
  );

  return result.rows[0] || null;
};
/* --------------------------------
   EXPORTS
-------------------------------- */

module.exports = {
  createAdminOrder,
  getAdminOrders,
  getAdminOrderById,
  updateAdminOrder,
  deleteAdminOrder,
  deleteAllAdminOrders,
  verifyAdminOrder,
  updateShipmentDetails,
};
