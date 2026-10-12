const pool = require("../../db");
const xpressbeesService = require("../services/xpressbeesService");
const Membership = require("./Membership");
const {
  calculateCheckoutTotals,
} = require("../services/membershipCheckoutService");

const verifyOrderSnapshot = (
  order,
  cartItems,
  checkoutTotals,
  membershipId = null
) => {
  const arraysMatch = (left, right) =>
    Array.isArray(left) &&
    left.length === right.length &&
    left.every((value, index) => Number(value) === Number(right[index]));

  const itemIds = cartItems.map((item) =>
    Number(item.item_id ?? item.product_id)
  );
  const quantities = cartItems.map((item) => Number(item.quantity));
  const unitPrices = cartItems.map((item) => Number(item.price));

  if (
    Number(order.actual_amount) !== Number(checkoutTotals.actualAmount) ||
    Number(order.payable_amount) !== Number(checkoutTotals.payableAmount) ||
    Number(order.membership_id || 0) !== Number(membershipId || 0) ||
    !arraysMatch(order.item_id, itemIds) ||
    !arraysMatch(order.quantity, quantities) ||
    !arraysMatch(order.unit_price, unitPrices)
  ) {
    throw new Error(
      "Existing order does not match the captured payment snapshot"
    );
  }
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
  user_id,
  address_id,
  buyNow = false,
  productId = null,
  quantity = 1,
  checkoutSnapshot = null
) => {
  let client;

  try {
    const userId = String(user_id).trim();

if (!userId) {
  throw new Error("User ID is required");
}

    const addressResult = await pool.query(
      `
      SELECT id
      FROM user_address
      WHERE id = $1
        AND user_id = $2
        AND is_active = 1
      LIMIT 1
      `,
      [address_id, userId]
    );
    if (!addressResult.rows[0]) {
      throw new Error("Active delivery address does not belong to this user");
    }


    /* -----------------------------------------------------
       GET CART ITEMS
    ----------------------------------------------------- */

    const cartResult = checkoutSnapshot?.cartItems
      ? {
          rows: checkoutSnapshot.cartItems,
          rowCount: checkoutSnapshot.cartItems.length,
        }
      : await pool.query(
      `
      SELECT
        c.id AS cart_id,
        c.item_id,
        c.quantity,
        p.price,
        p.weight,
        p.stock
      FROM cart_items c
      JOIN lkp_products p
        ON p.id = c.item_id
      WHERE c.user_id = $1
        AND c.is_active = 1
        AND p.is_active = 1
      ORDER BY c.id DESC
      `,
      [userId]
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
            price,
            weight,
            stock
          FROM lkp_products
          WHERE id = $1
            AND is_active = 1
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

          weight:
            productResult.rows[0].weight,

          stock:
            productResult.rows[0].stock,
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

    await Membership.checkAndResetMonthlyBenefits(userId);

    const checkoutTotals =
      checkoutSnapshot?.checkoutTotals ||
      await calculateCheckoutTotals(
        userId,
        cartItems,
        checkoutSnapshot?.membershipId
      );
    const membershipId =
      checkoutTotals.membershipBenefits?.membership?.id ?? null;
    if (
      checkoutSnapshot?.membershipId !== undefined &&
      Number(checkoutSnapshot.membershipId || 0) !== Number(membershipId || 0)
    ) {
      throw new Error(
        "Selected membership changed after payment creation"
      );
    }
    const actualAmount = checkoutTotals.actualAmount;
    const membershipDiscount = checkoutTotals.membershipDiscount;
    const walletClaim = checkoutTotals.walletClaim;
    const deliveryCharge = checkoutTotals.deliveryCharge;
    const payableAmount = checkoutTotals.payableAmount;

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

    if (!buyNow) {
      const lockedCartResult = await client.query(
        `
        SELECT id AS cart_id, item_id, quantity
        FROM cart_items
        WHERE user_id = $1
          AND is_active = 1
        ORDER BY id DESC
        FOR UPDATE
        `,
        [userId]
      );

      if (
        lockedCartResult.rows.length !== cartItems.length ||
        lockedCartResult.rows.some(
          (item, index) =>
            Number(item.cart_id) !== Number(cartItems[index].cart_id) ||
            Number(item.item_id) !== Number(cartItems[index].item_id) ||
            Number(item.quantity) !== Number(cartItems[index].quantity)
        )
      ) {
        throw new Error(
          "Cart changed during checkout; order was not created"
        );
      }
    }

    const gatewayOrderId = checkoutSnapshot?.gatewayOrderId || null;
    if (gatewayOrderId) {
      const existingOrderResult = await client.query(
        `
        SELECT *
        FROM orders
        WHERE tnx_order_id = $1
          AND user_id = $2
          AND is_active = 1
        LIMIT 1
        FOR UPDATE
        `,
        [gatewayOrderId, userId]
      );
      const existingOrder = existingOrderResult.rows[0];

      if (existingOrder) {
        verifyOrderSnapshot(
          existingOrder,
          cartItems,
          checkoutTotals,
          membershipId
        );
        await client.query("COMMIT");
        return existingOrder;
      }
    }

    const productResult = await client.query(
      `
      SELECT id, price, weight, stock
      FROM lkp_products
      WHERE id = ANY($1::int[])
        AND is_active = 1
      FOR SHARE
      `,
      [cartItems.map((item) => Number(item.item_id ?? item.product_id))]
    );
    const productsById = new Map(
      productResult.rows.map((product) => [
        Number(product.id),
        product,
      ])
    );

    for (const item of cartItems) {
      const product = productsById.get(
        Number(item.item_id ?? item.product_id)
      );
      if (
        !product ||
        Number(product.price) !== Number(item.price) ||
        Number(product.weight || 0) !== Number(item.weight || 0) ||
        Number(item.quantity) > Number(product.stock)
      ) {
        throw new Error(
          "Product changed or is unavailable; order was not created"
        );
      }
    }

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
          order_id,
          tnx_order_id,
          actual_amount,
          membership_discount,
          wallet_claim,
          delivery_charge,
          membership_id,
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
          $5,
          $6,
          $7,
          $8,
          $9,
          $10,
          $11,
          $12,
          'PLACED',
          'PENDING',
          $13
        )
        RETURNING *
        `,
        [
          userId,
          mgoOrderId,
          gatewayOrderId,
          actualAmount,
          membershipDiscount,
          walletClaim,
          deliveryCharge,
          membershipId,
          itemIds,
          quantities,
          unitPrices,
          payableAmount,
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
      WHERE user_id = $1
      `,
      [userId]
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
  user_id,
  address_id,
  productId,
  quantity = 1,
  checkoutSnapshot = null
) => {
  let client;

  try {
    const userId = String(user_id).trim();

if (!userId) {
  throw new Error("User ID is required");
}

    const addressResult = await pool.query(
      `
      SELECT id
      FROM user_address
      WHERE id = $1
        AND user_id = $2
        AND is_active = 1
      LIMIT 1
      `,
      [address_id, userId]
    );
    if (!addressResult.rows[0]) {
      throw new Error("Active delivery address does not belong to this user");
    }

    /* -----------------------------------------------------
       GET PRODUCT
    ----------------------------------------------------- */

    const productResult =
      await pool.query(
        `
        SELECT
          id,
          price,
          weight,
          stock
        FROM lkp_products
        WHERE id = $1
          AND is_active = 1
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

    const snapshotItem = checkoutSnapshot?.cartItems?.[0];
    if (
      snapshotItem &&
      (
        Number(snapshotItem.product_id ?? snapshotItem.item_id) !==
          Number(product.id) ||
        Number(snapshotItem.quantity) !== orderQuantity ||
        Number(snapshotItem.price) !== Number(product.price) ||
        Number(snapshotItem.weight || 0) !== Number(product.weight || 0)
      )
    ) {
      throw new Error(
        "Product pricing changed after checkout; captured payment requires reconciliation"
      );
    }

    if (
    !Number.isInteger(orderQuantity) ||
    orderQuantity <= 0 ||
      orderQuantity > Number(product.stock)
    ) {
      throw new Error("Invalid product quantity or insufficient stock");
    }

    await Membership.checkAndResetMonthlyBenefits(userId);
    const checkoutTotals =
      checkoutSnapshot?.checkoutTotals ||
      await calculateCheckoutTotals(userId, [
        {
          item_id: product.id,
          quantity: orderQuantity,
          price: product.price,
          weight: product.weight,
          stock: product.stock,
        },
      ], checkoutSnapshot?.membershipId);
    const membershipId =
      checkoutTotals.membershipBenefits?.membership?.id ?? null;
    if (
      checkoutSnapshot?.membershipId !== undefined &&
      Number(checkoutSnapshot.membershipId || 0) !== Number(membershipId || 0)
    ) {
      throw new Error(
        "Selected membership changed after payment creation"
      );
    }
    const actualAmount = checkoutTotals.actualAmount;

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

    const gatewayOrderId = checkoutSnapshot?.gatewayOrderId || null;
    if (gatewayOrderId) {
      const existingOrderResult = await client.query(
        `
        SELECT *
        FROM orders
        WHERE tnx_order_id = $1
          AND user_id = $2
          AND is_active = 1
        LIMIT 1
        FOR UPDATE
        `,
        [gatewayOrderId, userId]
      );
      const existingOrder = existingOrderResult.rows[0];

      if (existingOrder) {
        verifyOrderSnapshot(
          existingOrder,
          checkoutSnapshot.cartItems,
          checkoutTotals,
          membershipId
        );
        await client.query("COMMIT");
        return existingOrder;
      }
    }

    const lockedProductResult = await client.query(
      `
      SELECT price, weight, stock
      FROM lkp_products
      WHERE id = $1
        AND is_active = 1
      FOR SHARE
      `,
      [product.id]
    );
    const lockedProduct = lockedProductResult.rows[0];
    if (
      !lockedProduct ||
      Number(lockedProduct.price) !== Number(product.price) ||
      Number(lockedProduct.weight || 0) !== Number(product.weight || 0) ||
      orderQuantity > Number(lockedProduct.stock)
    ) {
      throw new Error(
        "Product changed or is unavailable; order was not created"
      );
    }

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
          order_id,
          tnx_order_id,
          actual_amount,
          membership_discount,
          wallet_claim,
          delivery_charge,
          membership_id,
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
          $5,
          $6,
          $7,
          $8,
          $9,
          $10,
          $11,
          $12,
          'PLACED',
          'PENDING',
          $13
        )
        RETURNING *
        `,
        [
          userId,
          mgoOrderId,
          gatewayOrderId,
          actualAmount,
          checkoutTotals.membershipDiscount,
          checkoutTotals.walletClaim,
          checkoutTotals.deliveryCharge,
          membershipId,
          itemIds,
          quantities,
          unitPrices,
          checkoutTotals.payableAmount,
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

      LEFT JOIN user_address a
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

      LEFT JOIN lkp_products p
        ON p.id = o.item_id[1]

      WHERE o.user_id = $1

      ORDER BY o.id DESC
      `,
      [String(userId).trim()]
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

      JOIN lkp_products p
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
  getOrdersByUserId,
  getOrderItems,
  updateOrder,
  deleteOrder,
  shipOrder,
  trackOrder,
};