const pool = require("../../db");
const xpressbeesService = require("../services/xpressbeesService");

/* =========================================================
   RESOLVE PUBLIC USER ID
========================================================= */

const getPublicUserId = async (internalUserId) => {
  const result = await pool.query(
    `
    SELECT user_id
    FROM user_login
    WHERE id = $1
      AND is_active = true
    LIMIT 1
    `,
    [internalUserId]
  );

  return result.rows[0]?.user_id || null;
};

/* =========================================================
   GENERATE MGO ORDER ID

   Format:

   MGO26092701
   MGO26092702
   MGO26092703

   Uses ONLY the existing orders table.

   No daily sequence table.
========================================================= */

const generateMgoOrderId = async (client = pool) => {
  const dateResult = await client.query(
    `
    SELECT TO_CHAR(
      CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Kolkata',
      'YYMMDD'
    ) AS date_part
    `
  );

  const datePart = dateResult.rows[0].date_part;

  /*
   * Prevent simultaneous orders from
   * receiving the same MGO number.
   */
  await client.query(
    `
    SELECT pg_advisory_xact_lock(
      hashtext($1)
    )
    `,
    [`MGO${datePart}`]
  );

  const result = await client.query(
    `
    SELECT
      COALESCE(
        MAX(
          RIGHT(order_id, 2)::INTEGER
        ),
        0
      ) + 1 AS next_number
    FROM orders
    WHERE order_id LIKE $1
    `,
    [`MGO${datePart}%`]
  );

  const nextNumber = Number(
    result.rows[0].next_number
  );

  if (nextNumber > 99) {
    throw new Error(
      `Daily MGO order limit reached for ${datePart}`
    );
  }

  return `MGO${datePart}${String(nextNumber).padStart(
    2,
    "0"
  )}`;
};

/* =========================================================
   CREATE ORDER FROM CART
========================================================= */

const createOrder = async (
  entity_type,
  entity_id,
  address_id,
  buyNow = false,
  productId = null,
  quantity = 1,
  publicUserId = null
) => {
  let client;

  try {
    /* -----------------------------------------------------
       RESOLVE PUBLIC USER ID
    ----------------------------------------------------- */

    if (entity_type === "USER" && !publicUserId) {
      publicUserId =
        await getPublicUserId(entity_id);

      if (!publicUserId) {
        throw new Error(
          "User account not found"
        );
      }
    }

    /* -----------------------------------------------------
       GET CART ITEMS
    ----------------------------------------------------- */

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
      [
        entity_type,
        entity_id,
      ]
    );

    let cartItems = cartResult.rows;

    console.log(
      "Cart row count:",
      cartResult.rowCount
    );

    console.log(
      "Cart items:",
      cartResult.rows
    );

    /* -----------------------------------------------------
       BUY NOW
    ----------------------------------------------------- */

    if (buyNow) {
      const productResult =
        await pool.query(
          `
          SELECT
            id AS item_id,
            price
          FROM products
          WHERE id = $1
          `,
          [productId]
        );

      if (productResult.rowCount === 0) {
        return null;
      }

      cartItems = [
        {
          item_id:
            productResult.rows[0].item_id,

          quantity: Number(quantity),

          price:
            productResult.rows[0].price,
        },
      ];
    } else {
      if (cartResult.rowCount === 0) {
        return null;
      }
    }

    /* -----------------------------------------------------
       CALCULATE ACTUAL AMOUNT

       actual_amount =
       product total BEFORE discount/wallet/delivery
    ----------------------------------------------------- */

    const actualAmount =
      cartItems.reduce(
        (sum, item) =>
          sum +
          Number(item.quantity) *
            Number(item.price),
        0
      );

    /* -----------------------------------------------------
       PREPARE ARRAY VALUES

       item_id    = {11,12,13}
       quantity   = {1,2,3}
       unit_price = {210,310,500}
    ----------------------------------------------------- */

    const itemIds =
      cartItems.map((item) =>
        Number(item.item_id)
      );

    const quantities =
      cartItems.map((item) =>
        Number(item.quantity)
      );

    const unitPrices =
      cartItems.map((item) =>
        Number(item.price)
      );

    /* -----------------------------------------------------
       START TRANSACTION
    ----------------------------------------------------- */

    client = await pool.connect();

    await client.query("BEGIN");

    /* -----------------------------------------------------
       GENERATE MGO ORDER ID
    ----------------------------------------------------- */

    const mgoOrderId =
      await generateMgoOrderId(client);

    console.log(
      "Generated MGO Order ID:",
      mgoOrderId
    );

    /* -----------------------------------------------------
       CREATE ORDER
    ----------------------------------------------------- */

    const orderResult =
      await client.query(
        `
        INSERT INTO orders
        (
          user_id,
          entity_id,
          entity_type,
          order_id,
          tnx_order_id,
          actual_amount,
          membership_discount,
          wallet_claim,
          delivery_charge,
          item_id,
          quantity,
          unit_price,
          payable_amount,
          status,
          payment_status,
          address_id
        )
        VALUES
        (
          $1,
          $2,
          $3,
          $4,
          NULL,
          $5,
          0,
          0,
          0,
          $6,
          $7,
          $8,
          $9,
          'PLACED',
          'PENDING',
          $10
        )
        RETURNING *
        `,
        [
          publicUserId,
          entity_id,
          entity_type,
          mgoOrderId,
          actualAmount,
          itemIds,
          quantities,
          unitPrices,
          actualAmount,
          address_id,
        ]
      );

    const order =
      orderResult.rows[0];

    /* -----------------------------------------------------
       CLEAR CART

       Existing behavior preserved.
    ----------------------------------------------------- */

    await client.query(
      `
      DELETE FROM cart_items
      WHERE entity_type = $1
        AND entity_id = $2
      `,
      [
        entity_type,
        entity_id,
      ]
    );

    await client.query("COMMIT");

    console.log(
      "MGO ORDER CREATED:",
      order.order_id
    );

    return order;

  } catch (error) {
    if (client) {
      await client.query("ROLLBACK");
    }

    console.error(
      "CREATE ORDER ERROR:",
      error
    );

    throw error;

  } finally {
    if (client) {
      client.release();
    }
  }
};

/* =========================================================
   CREATE BUY NOW ORDER
========================================================= */

const createBuyNowOrder = async (
  entity_type,
  entity_id,
  address_id,
  productId,
  quantity = 1,
  publicUserId = null
) => {
  let client;

  try {
    /* -----------------------------------------------------
       RESOLVE PUBLIC USER ID
    ----------------------------------------------------- */

    if (
      entity_type === "USER" &&
      !publicUserId
    ) {
      publicUserId =
        await getPublicUserId(entity_id);

      if (!publicUserId) {
        throw new Error(
          "User account not found"
        );
      }
    }

    /* -----------------------------------------------------
       GET PRODUCT
    ----------------------------------------------------- */

    const productResult =
      await pool.query(
        `
        SELECT
          id,
          price
        FROM products
        WHERE id = $1
        `,
        [productId]
      );

    if (productResult.rowCount === 0) {
      return null;
    }

    const product =
      productResult.rows[0];

    const orderQuantity =
      Number(quantity);

    const actualAmount =
      Number(product.price) *
      orderQuantity;

    /* -----------------------------------------------------
       ARRAYS
    ----------------------------------------------------- */

    const itemIds = [
      Number(product.id),
    ];

    const quantities = [
      orderQuantity,
    ];

    const unitPrices = [
      Number(product.price),
    ];

    /* -----------------------------------------------------
       START TRANSACTION
    ----------------------------------------------------- */

    client =
      await pool.connect();

    await client.query("BEGIN");

    /* -----------------------------------------------------
       GENERATE MGO ORDER ID
    ----------------------------------------------------- */

    const mgoOrderId =
      await generateMgoOrderId(client);

    console.log(
      "Generated MGO Buy Now Order ID:",
      mgoOrderId
    );

    /* -----------------------------------------------------
       CREATE ORDER
    ----------------------------------------------------- */

    const orderResult =
      await client.query(
        `
        INSERT INTO orders
        (
          user_id,
          entity_id,
          entity_type,
          order_id,
          tnx_order_id,
          actual_amount,
          membership_discount,
          wallet_claim,
          delivery_charge,
          item_id,
          quantity,
          unit_price,
          payable_amount,
          status,
          payment_status,
          address_id
        )
        VALUES
        (
          $1,
          $2,
          $3,
          $4,
          NULL,
          $5,
          0,
          0,
          0,
          $6,
          $7,
          $8,
          $9,
          'PLACED',
          'PENDING',
          $10
        )
        RETURNING *
        `,
        [
          publicUserId,
          entity_id,
          entity_type,
          mgoOrderId,
          actualAmount,
          itemIds,
          quantities,
          unitPrices,
          actualAmount,
          address_id,
        ]
      );

    const order =
      orderResult.rows[0];

    await client.query("COMMIT");

    console.log(
      "MGO BUY NOW ORDER CREATED:",
      order.order_id
    );

    return order;

  } catch (error) {
    if (client) {
      await client.query("ROLLBACK");
    }

    console.error(
      "CREATE BUY NOW ORDER ERROR:",
      error
    );

    throw error;

  } finally {
    if (client) {
      client.release();
    }
  }
};

/* =========================================================
   GET ALL ORDERS
========================================================= */

const getOrders = async () => {
  const result =
    await pool.query(
      `
      SELECT *
      FROM orders
      ORDER BY id DESC
      `
    );

  return result.rows;
};

/* =========================================================
   GET ORDER BY ID

   Supports:

   126
   MGO26092708
========================================================= */

const getOrderById = async (id) => {
  const result =
    await pool.query(
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

      WHERE
        (
          $1::text ~ '^[0-9]+$'
          AND o.id = $1::integer
        )
        OR o.order_id = $1::text

      LIMIT 1
      `,
      [String(id)]
    );

  return result.rows[0];
};

/* =========================================================
   GET ORDERS BY PUBLIC USER ID
========================================================= */

const getOrdersByUserId = async (
  userId
) => {
  const result =
    await pool.query(
      `
      SELECT
        o.id,
        o.user_id,
        o.entity_id,
        o.entity_type,

        o.order_id,
        o.tnx_order_id,

        o.actual_amount,
        o.membership_discount,
        o.wallet_claim,
        o.delivery_charge,
        o.payable_amount,

        o.status,
        o.payment_status,

        o.warehouse_id,
        o.tracking_number,
        o.courier_name,
        o.address_id,

        o.admin_verified,
        o.admin_accepted,
        o.delivery_method,

        o.created_at,

        o.item_id[1] AS product_id,

        COALESCE(
          (
            SELECT ai.url
            FROM app_images ai
            WHERE ai.product_id = o.item_id[1]
              AND ai.image_type = 'PRODUCT_IMAGE'
            ORDER BY ai.id ASC
            LIMIT 1
          ),
          p.image
        ) AS image

      FROM orders o

      LEFT JOIN products p
        ON p.id = o.item_id[1]

      WHERE o.user_id = $1

      ORDER BY o.id DESC
      `,
      [String(userId).trim()]
    );

  return result.rows;
};

/* =========================================================
   GET ORDERS BY ENTITY
========================================================= */

const getOrdersByEntity = async (
  entity_type,
  entity_id
) => {
  const result =
    await pool.query(
      `
      SELECT
        o.id,
        o.user_id,
        o.entity_id,
        o.entity_type,

        o.order_id,
        o.tnx_order_id,

        o.actual_amount,
        o.membership_discount,
        o.wallet_claim,
        o.delivery_charge,
        o.payable_amount,

        o.status,
        o.payment_status,

        o.warehouse_id,
        o.tracking_number,
        o.courier_name,
        o.address_id,

        o.admin_verified,
        o.admin_accepted,
        o.delivery_method,

        o.created_at,

        o.item_id[1] AS product_id,

        COALESCE(
          (
            SELECT ai.url
            FROM app_images ai
            WHERE ai.product_id = o.item_id[1]
              AND ai.image_type = 'PRODUCT_IMAGE'
            ORDER BY ai.id ASC
            LIMIT 1
          ),
          p.image
        ) AS image

      FROM orders o

      LEFT JOIN products p
        ON p.id = o.item_id[1]

      WHERE o.entity_type = $1
        AND o.entity_id = $2

      ORDER BY o.id DESC
      `,
      [
        entity_type,
        entity_id,
      ]
    );

  return result.rows;
};

/* =========================================================
   GET ORDER ITEMS

   order_items TABLE IS NO LONGER USED.

   Data comes from:

   item_id[]
   quantity[]
   unit_price[]
========================================================= */

const getOrderItems = async (
  orderId
) => {
  const result =
    await pool.query(
      `
      SELECT
        x.item_index AS id,

        x.item_id AS product_id,

        p.name AS product_name,

        COALESCE(
          (
            SELECT ai.url
            FROM app_images ai
            WHERE ai.product_id = x.item_id
              AND ai.image_type = 'PRODUCT_IMAGE'
            ORDER BY ai.id ASC
            LIMIT 1
          ),
          p.image
        ) AS image,

        x.quantity,

        x.unit_price,

        (
          x.quantity * x.unit_price
        ) AS total_price

      FROM orders o

      CROSS JOIN LATERAL
        unnest(
          o.item_id,
          o.quantity,
          o.unit_price
        )
        WITH ORDINALITY
        AS x(
          item_id,
          quantity,
          unit_price,
          item_index
        )

      JOIN products p
        ON p.id = x.item_id

      WHERE
        (
          $1::text ~ '^[0-9]+$'
          AND o.id = $1::integer
        )
        OR o.order_id = $1::text

      ORDER BY x.item_index
      `,
      [String(orderId)]
    );

  return result.rows;
};

/* =========================================================
   UPDATE ORDER STATUS
========================================================= */

const updateOrder = async (
  id,
  status
) => {
  const result =
    await pool.query(
      `
      UPDATE orders
      SET status = $1
      WHERE id = $2
      RETURNING *
      `,
      [
        status,
        id,
      ]
    );

  return result.rows[0];
};

/* =========================================================
   DELETE ORDER
========================================================= */

const deleteOrder = async (
  id
) => {
  const result =
    await pool.query(
      `
      DELETE FROM orders
      WHERE id = $1
      RETURNING *
      `,
      [id]
    );

  return result.rows[0];
};

/* =========================================================
   SHIP ORDER
========================================================= */

const shipOrder = async (
  orderId,
  trackingNumber,
  courierName
) => {
  const result =
    await pool.query(
      `
      UPDATE orders
      SET
        tracking_number = $2,
        courier_name = $3,
        status = 'PROCESSING'
      WHERE id = $1
      RETURNING *
      `,
      [
        orderId,
        trackingNumber,
        courierName,
      ]
    );

  return result.rows[0];
};

/* =========================================================
   TRACK ORDER

   Supports:

   /tracking/126
   /tracking/MGO26092707
========================================================= */

const trackOrder = async (
  req,
  res
) => {
  try {
    const { id } = req.params;

    const order =
      await getOrderById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    if (!order.tracking_number) {
      return res.status(400).json({
        success: false,
        message:
          "Tracking number not found",
      });
    }

    const tracking =
      await xpressbeesService.trackShipment(
        order.tracking_number
      );

    return res.json(tracking);

  } catch (err) {
    console.error(
      "TRACK ORDER ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: "Tracking failed",
    });
  }
};

/* =========================================================
   EXPORTS
========================================================= */

module.exports = {
  createOrder,
  createBuyNowOrder,
  getOrders,
  getOrderById,
  getOrdersByEntity,
  getOrdersByUserId,
  getOrderItems,
  updateOrder,
  deleteOrder,
  shipOrder,
  trackOrder,
};