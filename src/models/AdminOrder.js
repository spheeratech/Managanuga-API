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
      FROM lkp_public.lkp_products
      WHERE id = $1::integer
        AND is_active = 1
      FOR UPDATE
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
        actual_amount,
        membership_discount,
        wallet_claim,
        delivery_charge,
        item_id,
        quantity,
        unit_price,
        payable_amount,
        warehouse_id,
        item_id,
        quantity,
        unit_price,
        status,
        payment_status,
        is_active
      )
      VALUES
      (
        $1::varchar,
        $2::numeric,
        0,
        0,
        0,
        ARRAY[$4::integer],
        ARRAY[$5::integer],
        ARRAY[$6::numeric],
        $2::numeric,
        $3::integer,
        'PENDING',
        'PENDING',
        1
      )
      RETURNING *
      `,
      [
        String(user_id),
        totalAmount,
        warehouse_id === null ? null : Number(warehouse_id),
        Number(product.id),
        orderQuantity,
        Number(product.price),
        [Number(product.id)],
        [orderQuantity],
        [Number(product.price)],
      ],
    );

    const order = orderResult.rows[0];

    // --------------------------------
    // DEDUCT STOCK
    // --------------------------------

    const stockUpdate = await client.query(
      `
      UPDATE lkp_products
      SET stock = stock - $1::integer
      WHERE id = $2::integer
        AND is_active = 1
        AND stock >= $1::integer
      RETURNING id
      `,
      [orderQuantity, Number(product.id)],
    );
    if (!stockUpdate.rows[0]) {
      throw new Error("Product stock changed; admin order was not created");
    }

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
      o.order_id,
      o.user_id,
      o.address_id,

      -- Amount breakdown
      o.actual_amount,
      o.actual_amount AS total_amount,
      COALESCE(o.membership_discount, 0) AS membership_discount,
      COALESCE(o.wallet_claim, 0) AS wallet_claim,
      COALESCE(o.delivery_charge, 0) AS delivery_charge,
      COALESCE(
        o.payable_amount,
        o.actual_amount
          - COALESCE(o.membership_discount, 0)
          - COALESCE(o.wallet_claim, 0)
          + COALESCE(o.delivery_charge, 0)
      ) AS payable_amount,

      o.item_id,
      o.quantity,
      o.unit_price,

      -- Product names and item totals
      COALESCE(items.items, '[]'::json) AS items,

      o.warehouse_id,
      o.hubcode,
      o.status,
      o.payment_status,
      o.tracking_number,
      o.courier_name,
      o.created_at,

      ul.username,

      COALESCE(
        NULLIF(TRIM(ua.phone), ''),
        NULLIF(TRIM(ul.mobile_no), '')
      ) AS customer_phone,

      ui.first_name,
      ui.last_name,
      ui.email AS customer_email,

      COALESCE(
        NULLIF(TRIM(ua.full_name), ''),
        NULLIF(TRIM(CONCAT_WS(' ', ui.first_name, ui.last_name)), ''),
        NULLIF(TRIM(ul.username), ''),
        CONCAT('Customer #', o.user_id)
      ) AS customer_name,

      COALESCE(
        NULLIF(TRIM(CONCAT_WS(
          ' ',
          NULLIF(TRIM(ua.address_line1), ''),
          NULLIF(TRIM(ua.address_line2), '')
        )), ''),
        NULLIF(TRIM(ui.address), '')
      ) AS customer_address,

      COALESCE(NULLIF(TRIM(ua.city), ''), NULLIF(TRIM(ui.city), ''))
        AS customer_city,

      COALESCE(NULLIF(TRIM(ua.state), ''), NULLIF(TRIM(ui.state), ''))
        AS customer_state,

      COALESCE(NULLIF(TRIM(ua.postal_code), ''), NULLIF(TRIM(ui.pincode), ''))
        AS customer_pincode,

      ua.country AS customer_country

    FROM public.orders o

    LEFT JOIN public.user_login ul
      ON CAST(o.user_id AS VARCHAR) = CAST(ul.user_id AS VARCHAR)

    LEFT JOIN public.user_info ui
      ON CAST(o.user_id AS VARCHAR) = CAST(ui.user_id AS VARCHAR)

    LEFT JOIN public.user_address ua
      ON ua.id = o.address_id
     AND CAST(ua.user_id AS VARCHAR) = CAST(o.user_id AS VARCHAR)

    LEFT JOIN LATERAL (
      SELECT json_agg(
        json_build_object(
          'product_id', oi.item_id,
          'product_name', p.name,
          'quantity', oi.quantity,
          'unit_price', oi.unit_price,
          'price', oi.unit_price,
          'subtotal', oi.quantity * oi.unit_price
        )
        ORDER BY oi.item_position
      ) AS items
      FROM unnest(o.item_id, o.quantity, o.unit_price)
        WITH ORDINALITY
        AS oi(item_id, quantity, unit_price, item_position)
      LEFT JOIN public.lkp_products p
        ON p.id = oi.item_id
    ) items ON TRUE

    ORDER BY o.id DESC
  `);

  return result.rows;
};

// const getAdminOrders = async () => {
//   const result = await pool.query(`
//     SELECT
//       o.id,
//       o.order_id,
//       o.user_id,
//       o.address_id,
//       o.actual_amount AS total_amount,
//       o.warehouse_id,
//       o.status,
//       o.payment_status,
//       o.tracking_number,
//       o.courier_name,
//       o.created_at,

//       -- USER LOGIN DETAILS
//       ul.username,

//       -- CUSTOMER CONTACT
//       COALESCE(
//         NULLIF(TRIM(ua.phone), ''),
//         NULLIF(TRIM(ul.mobile_no), '')
//       ) AS customer_phone,

//       -- USER PROFILE DETAILS
//       ui.first_name,
//       ui.last_name,
//       ui.email AS customer_email,

//       -- DELIVERY ADDRESS SAVED WITH THE MOBILE ORDER
//       COALESCE(
//         NULLIF(TRIM(ua.full_name), ''),
//         NULLIF(
//           TRIM(CONCAT_WS(' ', ui.first_name, ui.last_name)),
//           ''
//         ),
//         NULLIF(TRIM(ul.username), ''),
//         CONCAT('Customer #', o.user_id)
//       ) AS customer_name,

//       COALESCE(
//         NULLIF(
//           TRIM(CONCAT_WS(
//             ' ',
//             NULLIF(TRIM(ua.address_line1), ''),
//             NULLIF(TRIM(ua.address_line2), '')
//           )),
//           ''
//         ),
//         NULLIF(TRIM(ui.address), '')
//       ) AS customer_address,

//       COALESCE(
//         NULLIF(TRIM(ua.city), ''),
//         NULLIF(TRIM(ui.city), '')
//       ) AS customer_city,

//       COALESCE(
//         NULLIF(TRIM(ua.state), ''),
//         NULLIF(TRIM(ui.state), '')
//       ) AS customer_state,

//       COALESCE(
//         NULLIF(TRIM(ua.postal_code), ''),
//         NULLIF(TRIM(ui.pincode), '')
//       ) AS customer_pincode,

//       ua.country AS customer_country

//     FROM public.orders o

//     LEFT JOIN public.user_login ul
//       ON CAST(o.user_id AS VARCHAR) = CAST(ul.user_id AS VARCHAR)

//     LEFT JOIN public.user_info ui
//       ON CAST(o.user_id AS VARCHAR) = CAST(ui.user_id AS VARCHAR)

//     LEFT JOIN public.user_address ua
//       ON ua.id = o.address_id
//      AND CAST(ua.user_id AS VARCHAR) = CAST(o.user_id AS VARCHAR)

//     ORDER BY o.id DESC
//   `);

//   return result.rows;
// };

/* --------------------------------
   GET ADMIN ORDER BY ID
-------------------------------- */

const getAdminOrderById = async (id) => {
  const orderResult = await pool.query(
    `
    SELECT
      o.*,

      -- CUSTOMER NAME
      COALESCE(
        NULLIF(TRIM(ua.full_name), ''),
        NULLIF(
          TRIM(CONCAT_WS(' ', ui.first_name, ui.last_name)),
          ''
        ),
        NULLIF(TRIM(ul.username), ''),
        CONCAT('Customer #', o.user_id)
      ) AS customer_name,

      -- CUSTOMER CONTACT
      COALESCE(
        NULLIF(TRIM(ua.phone), ''),
        NULLIF(TRIM(ul.mobile_no), '')
      ) AS customer_phone,

      ui.email AS customer_email,

      -- DELIVERY ADDRESS LINKED TO THIS ORDER
      COALESCE(
        NULLIF(
          TRIM(CONCAT_WS(
            ' ',
            NULLIF(TRIM(ua.address_line1), ''),
            NULLIF(TRIM(ua.address_line2), '')
          )),
          ''
        ),
        NULLIF(TRIM(ui.address), '')
      ) AS address,

      ua.address_line1,
      ua.address_line2,
      ua.full_name AS delivery_name,
      ua.phone AS delivery_phone,
      ua.address_type,
      ua.country,

      COALESCE(
        NULLIF(TRIM(ua.city), ''),
        NULLIF(TRIM(ui.city), '')
      ) AS city,

      COALESCE(
        NULLIF(TRIM(ua.state), ''),
        NULLIF(TRIM(ui.state), '')
      ) AS state,

      COALESCE(
        NULLIF(TRIM(ua.postal_code), ''),
        NULLIF(TRIM(ui.pincode), '')
      ) AS pincode

    FROM public.orders o

    LEFT JOIN public.user_login ul
      ON CAST(o.user_id AS VARCHAR) = CAST(ul.user_id AS VARCHAR)

    LEFT JOIN public.user_info ui
      ON CAST(o.user_id AS VARCHAR) = CAST(ui.user_id AS VARCHAR)

    LEFT JOIN public.user_address ua
      ON ua.id = o.address_id
     AND CAST(ua.user_id AS VARCHAR) = CAST(o.user_id AS VARCHAR)

    WHERE o.id = $1::integer
    `,
    [Number(id)],
  );

  if (orderResult.rowCount === 0) {
    return null;
  }

  const order = orderResult.rows[0];

  // GET ORDER ITEMS
  const itemsResult = await pool.query(
    `
    SELECT
      oi.item_position::integer AS id,
      oi.item_id AS product_id,
      p.name AS product_name,
      oi.quantity,
      oi.unit_price,
      (oi.quantity * oi.unit_price) AS subtotal

    FROM public.orders o
    CROSS JOIN LATERAL
      unnest(o.item_id, o.quantity, o.unit_price)
      WITH ORDINALITY AS oi(item_id, quantity, unit_price, item_position)
    JOIN public.lkp_products p
      ON p.id = oi.item_id

    WHERE o.id = $1::integer


    ORDER BY oi.item_position
    `,
    [Number(id)],
  );

  return {
    ...order,
    items: itemsResult.rows,
  };
};

// const getAdminOrderById = async (id) => {
//   const orderResult = await pool.query(
//     `
//     SELECT
//       o.*,

//       COALESCE(
//         NULLIF(
//           TRIM(
//             CONCAT(
//               COALESCE(ui.first_name, ''),
//               ' ',
//               COALESCE(ui.last_name, '')
//             )
//           ),
//           ''
//         ),
//         ul.username
//       ) AS customer_name,

//       ul.mobile_no AS customer_phone,
//       ui.email AS customer_email,
//       ui.address,
//       ui.city,
//       ui.state,
//       ui.pincode

//     FROM orders o

//     LEFT JOIN user_login ul
//       ON o.user_id = ul.user_id

//     LEFT JOIN user_info ui
//       ON o.user_id = ui.user_id

//     WHERE o.id = $1::integer
//     `,
//     [Number(id)],
//   );

//   if (orderResult.rowCount === 0) {
//     return null;
//   }

//   const order = orderResult.rows[0];

//   // --------------------------------
//   // GET ORDER ITEMS
//   // --------------------------------

//   const itemsResult = await pool.query(
//     `
//     SELECT
//       item.item_index AS id,
//       item.item_id AS product_id,
//       p.name AS product_name,
//       item.quantity,
//       item.unit_price,
//       (item.quantity * item.unit_price) AS subtotal

//     FROM orders o
//     CROSS JOIN LATERAL unnest(o.item_id, o.quantity, o.unit_price)
//       WITH ORDINALITY AS item(item_id, quantity, unit_price, item_index)
//     JOIN public.lkp_products p
//       ON p.id = item.item_id

//     WHERE o.id = $1::integer

//     ORDER BY item.item_index
//     `,
//     [Number(id)],
//   );

//   return {
//     ...order,
//     items: itemsResult.rows,
//   };
// };

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
  void id;
  throw new Error(
    "Admin order deletion is unavailable because orders do not record whether inventory was deducted",
  );
};

/* --------------------------------
   DELETE ALL ADMIN ORDERS
-------------------------------- */

const deleteAllAdminOrders = async () => {
  throw new Error(
    "Bulk admin order deletion is unavailable because orders do not record whether inventory was deducted",
  );
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
    WHERE id = $3
    RETURNING *
    `,
    [tracking_number ?? null, courier_name ?? null, Number(id)],
  );

  return result.rows[0];
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
