
const { logException } = require("../utils/exceptionLogger.js");
const pool = require("../../db");
const Membership = require("./Membership");
const {
  calculateCheckoutTotals,
} = require("../services/membershipCheckoutService");
const shiprocketService = require("../services/shiprocketService");

const {
  findActiveHubForPincode,
} = require("../services/hubService");

/* =========================================================
   HELPERS
========================================================= */

const getProductId = (item) =>
  Number(item.product_id ?? item.item_id);

const getVariantId = (item) =>
  Number(item.variant_id ?? item.variantId ?? 0);

const validateVariantItems = (items) => {
  for (const item of items) {
    if (
      !Number.isInteger(getProductId(item)) ||
      getProductId(item) <= 0 ||
      !Number.isInteger(getVariantId(item)) ||
      getVariantId(item) <= 0 ||
      !Number.isInteger(Number(item.quantity)) ||
      Number(item.quantity) <= 0
    ) {
      throw new Error(
        "Invalid product or variant details. Please select a valid product variant."
      );
    }
  }
};

/* =========================================================
   VERIFY EXISTING ORDER AGAINST CHECKOUT SNAPSHOT
========================================================= */

const verifyOrderSnapshot = (
  order,
  cartItems,
  checkoutTotals,
  membershipId = null,
  checkoutSnapshot = null
) => {
  const arraysMatch = (left, right) =>
    Array.isArray(left) &&
    left.length === right.length &&
    left.every((value, index) => Number(value) === Number(right[index]));

  // New orders always store product_variants.id.
  const itemIds = cartItems.map(getVariantId);

  const quantities = cartItems.map((item) =>
    Number(item.quantity)
  );

  const unitPrices = cartItems.map((item) =>
    Number(item.price)
  );

  const expectedActualAmount = Number(
    checkoutSnapshot?.actualAmount ?? checkoutTotals.actualAmount
  );

  const expectedPayableAmount = Number(
    checkoutSnapshot?.payableAmount ?? checkoutTotals.payableAmount
  );

  const expectedMembershipId =
    checkoutSnapshot?.membershipId ?? membershipId;

  const expectedCouponDiscount = Number(
    checkoutSnapshot?.couponDiscount ??
      checkoutTotals.couponDiscount ??
      0
  );

  if (
    Number(order.actual_amount) !== expectedActualAmount ||
    Number(order.payable_amount) !== expectedPayableAmount ||
    Number(order.membership_id || 0) !==
      Number(expectedMembershipId || 0) ||
    Number(order.coupon_discount || 0) !== expectedCouponDiscount ||
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

  await client.query(
    `
    SELECT pg_advisory_xact_lock(hashtext($1))
    `,
    [`MGO${datePart}`]
  );

  const result = await client.query(
    `
    SELECT
      COALESCE(
        MAX(RIGHT(order_id, 2)::INTEGER),
        0
      ) + 1 AS next_number
    FROM orders
    WHERE order_id LIKE $1
    `,
    [`MGO${datePart}%`]
  );

  const nextNumber = Number(result.rows[0].next_number);

  if (nextNumber > 99) {
    throw new Error(`Daily MGO order limit reached for ${datePart}`);
  }

  return `MGO${datePart}${String(nextNumber).padStart(2, "0")}`;
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
  checkoutSnapshot = null,
  suppliedClient = null,
  paymentStatus = "PENDING"
) => {
  let client = suppliedClient;
  const ownsClient = !suppliedClient;
  const db = suppliedClient || pool;

  try {
    const userId = String(user_id).trim();

    if (!userId) {
      throw new Error("User ID is required");
    }

    /* -----------------------------------------------------
       VALIDATE ADDRESS
    ----------------------------------------------------- */

    const addressResult = await db.query(
      `
      SELECT id, postal_code
      FROM user_address
      WHERE id = $1
        AND user_id = $2
        AND is_active = 1
      LIMIT 1
      `,
      [address_id, userId]
    );

    if (!addressResult.rows[0]) {
      throw new Error(
        "Active delivery address does not belong to this user"
      );
    }

    /* -----------------------------------------------------
       GET CART ITEMS

       item_id/product_id = parent product ID
       variant_id = product_variants.id
    ----------------------------------------------------- */

    const cartResult = checkoutSnapshot
      ? {
          rows: checkoutSnapshot.cartItems || [],
          rowCount: (checkoutSnapshot.cartItems || []).length,
        }
      : await db.query(
          `
          SELECT
            c.id AS cart_id,
            c.user_id,
            c.item_id,
            c.item_id AS product_id,
            c.variant_id,
            pv.size AS variant_size,
            c.quantity,
            pv.price AS price,
            p.weight,
            pv.stock,
            (pv.price * c.quantity) AS total_price
          FROM cart_items c
          JOIN lkp_products p
            ON p.id = c.item_id
          JOIN product_variants pv
            ON pv.id = c.variant_id
           AND pv.product_id = p.id
          WHERE c.user_id = $1
            AND c.is_active = 1
            AND p.is_active = 1
            AND pv.is_active = 1
          ORDER BY c.id DESC
          `,
          [userId]
        );

    const cartItems = cartResult.rows;

    if (!cartItems.length) {
      return null;
    }

    validateVariantItems(cartItems);

    /* -----------------------------------------------------
       MEMBERSHIP AND CHECKOUT TOTALS

       Captured payment uses the saved checkout totals.
    ----------------------------------------------------- */

    if (!checkoutSnapshot) {
      await Membership.checkAndResetMonthlyBenefits(userId);
    }

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
      Number(checkoutSnapshot.membershipId || 0) !==
        Number(membershipId || 0)
    ) {
      throw new Error(
        "Selected membership does not match the checkout snapshot"
      );
    }

    const actualAmount = Number(
      checkoutSnapshot?.actualAmount ?? checkoutTotals.actualAmount
    );

    const membershipDiscount = Number(
      checkoutTotals.membershipDiscount || 0
    );

    const walletClaim = Number(checkoutTotals.walletClaim || 0);

    const deliveryCharge = Number(checkoutTotals.deliveryCharge || 0);

    const payableAmount = Number(
      checkoutSnapshot?.payableAmount ?? checkoutTotals.payableAmount
    );

    const couponDiscount = Number(
      checkoutSnapshot?.couponDiscount ??
        checkoutTotals.couponDiscount ??
        0
    );

    const referralBonus = Number(
      checkoutSnapshot?.referralBonus ??
        checkoutTotals.referralBonus ??
        0
    );

    /* -----------------------------------------------------
       PREPARE ORDER ARRAYS

       orders.item_id stores VARIANT IDs.
    ----------------------------------------------------- */

    const itemIds = cartItems.map(getVariantId);

    const quantities = cartItems.map((item) =>
      Number(item.quantity)
    );

    const unitPrices = cartItems.map((item) =>
      Number(item.price)
    );

    /* -----------------------------------------------------
       START TRANSACTION IF THIS FUNCTION OWNS IT
    ----------------------------------------------------- */

    if (ownsClient) {
      client = await pool.connect();
      await client.query("BEGIN");
    }

    /* -----------------------------------------------------
       LOCK CART FOR NORMAL CHECKOUT ONLY
    ----------------------------------------------------- */

    if (!buyNow && !checkoutSnapshot) {
      const lockedCartResult = await client.query(
        `
        SELECT
          id AS cart_id,
          item_id,
          variant_id,
          quantity
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
            Number(item.item_id) !== getProductId(cartItems[index]) ||
            Number(item.variant_id) !== getVariantId(cartItems[index]) ||
            Number(item.quantity) !== Number(cartItems[index].quantity)
        )
      ) {
        throw new Error(
          "Cart changed during checkout; order was not created"
        );
      }
    }

    /* -----------------------------------------------------
       IDEMPOTENCY CHECK
    ----------------------------------------------------- */

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
          membershipId,
          checkoutSnapshot
        );

        if (ownsClient) {
          await client.query("COMMIT");
        }

        return existingOrder;
      }
    }

    /* -----------------------------------------------------
       VALIDATE VARIANT AVAILABILITY AND STOCK
    ----------------------------------------------------- */

    const variantIds = cartItems.map(getVariantId);

    const variantResult = await client.query(
      `
      SELECT
        pv.id AS variant_id,
        pv.product_id,
        pv.price,
        pv.stock,
        pv.size,
        p.weight
      FROM product_variants pv
      JOIN lkp_products p
        ON p.id = pv.product_id
      WHERE pv.id = ANY($1::int[])
        AND p.is_active = 1
        AND pv.is_active = 1
      FOR SHARE OF pv, p
      `,
      [variantIds]
    );

    const variantsById = new Map(
      variantResult.rows.map((variant) => [
        Number(variant.variant_id),
        variant,
      ])
    );

    for (const item of cartItems) {
      const currentProductId = getProductId(item);
      const variantId = getVariantId(item);
      const variant = variantsById.get(variantId);

      if (
        !variant ||
        Number(variant.product_id) !== currentProductId ||
        !Number.isInteger(Number(item.quantity)) ||
        Number(item.quantity) <= 0 ||
        Number(item.quantity) > Number(variant.stock)
      ) {
        throw new Error(
          "Product variant is unavailable or stock is insufficient"
        );
      }

      if (
        !checkoutSnapshot &&
        (
          Number(variant.price) !== Number(item.price) ||
          Number(variant.weight || 0) !== Number(item.weight || 0)
        )
      ) {
        throw new Error(
          "Product variant changed; order was not created"
        );
      }
    }

    /* -----------------------------------------------------
       GENERATE ORDER ID
    ----------------------------------------------------- */

    const mgoOrderId = await generateMgoOrderId(client);

    const hub = await findActiveHubForPincode(
      addressResult.rows[0].postal_code,
      client
    );

    /* -----------------------------------------------------
       INSERT ORDER
    ----------------------------------------------------- */

    const orderResult = await client.query(
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
        coupon_discount,
        referral_bonus,
        status,
        payment_status,
        address_id,
        hubcode
      )
      VALUES
      (
        $1, $2, $3, $4, $5, $6, $7, $8,
        $9, $10, $11, $12, $13, $14,
        'PLACED', $17, $15, $16
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
        couponDiscount,
        referralBonus,
        address_id,
        hub.id,
        paymentStatus,
      ]
    );

    const order = orderResult.rows[0];

    /* -----------------------------------------------------
       CLEAR CART
    ----------------------------------------------------- */

    if (!buyNow) {
      if (checkoutSnapshot) {
        const snapshotCartIds = (checkoutSnapshot.cartItems || [])
          .map((item) => item.cart_id)
          .filter((id) => id !== null && id !== undefined);

        if (snapshotCartIds.length > 0) {
          await client.query(
            `
            DELETE FROM cart_items
            WHERE user_id = $1
              AND id = ANY($2::int[])
            `,
            [userId, snapshotCartIds]
          );
        }
      } else {
        await client.query(
          `
          DELETE FROM cart_items
          WHERE user_id = $1
          `,
          [userId]
        );
      }
    }

    if (ownsClient) {
      await client.query("COMMIT");
    }

    console.log("MGO ORDER CREATED:", order.order_id);

    return order;
  } catch (error) {
    void logException(error);

    if (ownsClient && client) {
      await client.query("ROLLBACK");
    }

    console.error("CREATE ORDER ERROR:", error);
    throw error;
  } finally {
    if (ownsClient && client) {
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
  checkoutSnapshot = null,
  suppliedClient = null,
  paymentStatus = "PENDING"
) => {
  let client = suppliedClient;
  const ownsClient = !suppliedClient;
  const db = suppliedClient || pool;

  try {
    const userId = String(user_id).trim();

    if (!userId) {
      throw new Error("User ID is required");
    }

    /* -----------------------------------------------------
       VALIDATE ADDRESS
    ----------------------------------------------------- */

    const addressResult = await db.query(
      `
      SELECT id, postal_code
      FROM user_address
      WHERE id = $1
        AND user_id = $2
        AND is_active = 1
      LIMIT 1
      `,
      [address_id, userId]
    );

    if (!addressResult.rows[0]) {
      throw new Error(
        "Active delivery address does not belong to this user"
      );
    }

    /* -----------------------------------------------------
       GET VARIANT ID FROM CHECKOUT SNAPSHOT
    ----------------------------------------------------- */

    const snapshotItem = checkoutSnapshot?.cartItems?.[0];

    if (checkoutSnapshot && !snapshotItem) {
      throw new Error("Buy Now checkout snapshot item is missing");
    }

    const variantId = Number(
      checkoutSnapshot?.variantId ??
        snapshotItem?.variant_id ??
        snapshotItem?.variantId ??
        0
    );

    if (!Number.isInteger(variantId) || variantId <= 0) {
      throw new Error(
        "Buy Now variant ID is missing from the checkout snapshot"
      );
    }

    /* -----------------------------------------------------
       GET PARENT PRODUCT AND SELECTED VARIANT
    ----------------------------------------------------- */

    const productResult = await db.query(
      `
      SELECT
        p.id AS product_id,
        p.weight,
        pv.id AS variant_id,
        pv.size AS variant_size,
        pv.price,
        pv.stock
      FROM lkp_products p
      JOIN product_variants pv
        ON pv.product_id = p.id
      WHERE p.id = $1
        AND pv.id = $2
        AND p.is_active = 1
        AND pv.is_active = 1
      LIMIT 1
      `,
      [productId, variantId]
    );

    if (productResult.rowCount === 0) {
      throw new Error("Selected product variant is unavailable");
    }

    const product = productResult.rows[0];
    const orderQuantity = Number(quantity);

    if (
      snapshotItem &&
      (
        getProductId(snapshotItem) !== Number(product.product_id) ||
        getVariantId(snapshotItem) !== Number(product.variant_id) ||
        Number(snapshotItem.quantity) !== orderQuantity
      )
    ) {
      throw new Error(
        "Buy Now product, variant or quantity does not match the captured checkout snapshot"
      );
    }

    if (
      !Number.isInteger(orderQuantity) ||
      orderQuantity <= 0 ||
      orderQuantity > Number(product.stock)
    ) {
      throw new Error(
        "Invalid product quantity or insufficient variant stock"
      );
    }

    const buyNowItem = {
      item_id: Number(product.product_id),
      product_id: Number(product.product_id),
      variant_id: Number(product.variant_id),
      variant_size: product.variant_size,
      quantity: orderQuantity,
      price: Number(snapshotItem?.price ?? product.price),
      weight: Number(product.weight || 0),
      stock: Number(product.stock),
    };

    /* -----------------------------------------------------
       MEMBERSHIP AND TOTALS
    ----------------------------------------------------- */

    if (!checkoutSnapshot) {
      await Membership.checkAndResetMonthlyBenefits(userId);
    }

    const checkoutTotals =
      checkoutSnapshot?.checkoutTotals ||
      await calculateCheckoutTotals(
        userId,
        [buyNowItem],
        checkoutSnapshot?.membershipId
      );

    const membershipId =
      checkoutTotals.membershipBenefits?.membership?.id ?? null;

    if (
      checkoutSnapshot?.membershipId !== undefined &&
      Number(checkoutSnapshot.membershipId || 0) !==
        Number(membershipId || 0)
    ) {
      throw new Error(
        "Selected membership does not match the checkout snapshot"
      );
    }

    const actualAmount = Number(
      checkoutSnapshot?.actualAmount ?? checkoutTotals.actualAmount
    );

    const membershipDiscount = Number(
      checkoutTotals.membershipDiscount || 0
    );

    const walletClaim = Number(checkoutTotals.walletClaim || 0);

    const deliveryCharge = Number(checkoutTotals.deliveryCharge || 0);

    const payableAmount = Number(
      checkoutSnapshot?.payableAmount ?? checkoutTotals.payableAmount
    );

    const couponDiscount = Number(
      checkoutSnapshot?.couponDiscount ??
        checkoutTotals.couponDiscount ??
        0
    );

    const referralBonus = Number(
      checkoutSnapshot?.referralBonus ??
        checkoutTotals.referralBonus ??
        0
    );

    /* -----------------------------------------------------
       PREPARE ORDER ARRAYS

       orders.item_id stores VARIANT ID.
    ----------------------------------------------------- */

    const itemIds = [Number(product.variant_id)];
    const quantities = [orderQuantity];
    const unitPrices = [Number(buyNowItem.price)];

    /* -----------------------------------------------------
       START TRANSACTION
    ----------------------------------------------------- */

    if (ownsClient) {
      client = await pool.connect();
      await client.query("BEGIN");
    }

    /* -----------------------------------------------------
       IDEMPOTENCY CHECK
    ----------------------------------------------------- */

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
          [buyNowItem],
          checkoutTotals,
          membershipId,
          checkoutSnapshot
        );

        if (ownsClient) {
          await client.query("COMMIT");
        }

        return existingOrder;
      }
    }

    /* -----------------------------------------------------
       LOCK AND VALIDATE VARIANT STOCK
    ----------------------------------------------------- */

    const lockedVariantResult = await client.query(
      `
      SELECT
        pv.id AS variant_id,
        pv.product_id,
        pv.price,
        pv.stock
      FROM product_variants pv
      JOIN lkp_products p
        ON p.id = pv.product_id
      WHERE pv.id = $1
        AND pv.product_id = $2
        AND pv.is_active = 1
        AND p.is_active = 1
      FOR UPDATE OF pv
      `,
      [variantId, productId]
    );

    const lockedVariant = lockedVariantResult.rows[0];

    if (
      !lockedVariant ||
      orderQuantity > Number(lockedVariant.stock)
    ) {
      throw new Error(
        "Product variant is unavailable or stock is insufficient"
      );
    }

    if (
      !checkoutSnapshot &&
      Number(lockedVariant.price) !== Number(product.price)
    ) {
      throw new Error(
        "Product variant price changed; order was not created"
      );
    }

    /* -----------------------------------------------------
       GENERATE ORDER ID
    ----------------------------------------------------- */

    const mgoOrderId = await generateMgoOrderId(client);

    const hub = await findActiveHubForPincode(
      addressResult.rows[0].postal_code,
      client
    );

    /* -----------------------------------------------------
       INSERT BUY NOW ORDER
    ----------------------------------------------------- */

    const orderResult = await client.query(
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
        coupon_discount,
        referral_bonus,
        status,
        payment_status,
        address_id,
        hubcode
      )
      VALUES
      (
        $1, $2, $3, $4, $5, $6, $7, $8,
        $9, $10, $11, $12, $13, $14,
        'PLACED', $17, $15, $16
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
        couponDiscount,
        referralBonus,
        address_id,
        hub.id,
        paymentStatus,
      ]
    );

    const order = orderResult.rows[0];

    if (ownsClient) {
      await client.query("COMMIT");
    }

    console.log("MGO BUY NOW ORDER CREATED:", order.order_id);

    return order;
  } catch (error) {
    void logException(error);

    if (ownsClient && client) {
      await client.query("ROLLBACK");
    }

    console.error("CREATE BUY NOW ORDER ERROR:", error);
    throw error;
  } finally {
    if (ownsClient && client) {
      client.release();
    }
  }
};

/* =========================================================
   GET ALL ORDERS
========================================================= */

const getOrders = async () => {
  const result = await pool.query(
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
========================================================= */

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

   orders.item_id contains product_variants.id.
========================================================= */

const getOrdersByUserId = async (userId) => {
  const result = await pool.query(
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

      pv.product_id,
      pv.id AS variant_id,
      pv.size AS variant_size,

      COALESCE(
        (
          SELECT ai.url
          FROM app_images ai
          WHERE ai.product_id = pv.product_id
            AND ai.image_type = 'PRODUCT_IMAGE'
          ORDER BY ai.id ASC
          LIMIT 1
        ),
        p.image
      ) AS image

    FROM orders o

    LEFT JOIN product_variants pv
      ON pv.id = o.item_id[1]

    LEFT JOIN lkp_products p
      ON p.id = pv.product_id

    WHERE o.user_id = $1
    ORDER BY o.id DESC
    `,
    [String(userId).trim()]
  );

  return result.rows;
};

/* =========================================================
   GET ORDER ITEMS

   orders.item_id contains product_variants.id.
========================================================= */

const getOrderItems = async (orderId) => {
  const result = await pool.query(
    `
    SELECT
      x.item_index AS id,

      pv.product_id,
      pv.id AS variant_id,
      pv.size AS variant_size,

      p.name AS product_name,

      COALESCE(
        (
          SELECT ai.url
          FROM app_images ai
          WHERE ai.product_id = pv.product_id
            AND ai.image_type = 'PRODUCT_IMAGE'
          ORDER BY ai.id ASC
          LIMIT 1
        ),
        p.image
      ) AS image,

      x.quantity,
      x.unit_price,
      (x.quantity * x.unit_price) AS total_price

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

    JOIN product_variants pv
      ON pv.id = x.item_id

    JOIN lkp_products p
      ON p.id = pv.product_id

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

const updateOrder = async (id, status) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET status = $1
    WHERE id = $2
    RETURNING *
    `,
    [status, id]
  );

  return result.rows[0];
};

/* =========================================================
   DELETE ORDER
========================================================= */

const deleteOrder = async (id) => {
  const result = await pool.query(
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

const shipOrder = async (orderId, trackingNumber, courierName) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET
      tracking_number = $2,
      courier_name = $3,
      status = 'PROCESSING'
    WHERE id = $1
    RETURNING *
    `,
    [orderId, trackingNumber, courierName]
  );

  return result.rows[0];
};

/* =========================================================
   TRACK ORDER
========================================================= */

const trackOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const order = await getOrderById(id);

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

    const tracking = await shiprocketService.trackShipment(
      order.tracking_number
    );

    return res.json(tracking);
  } catch (err) {
    void logException(err);
    console.error("TRACK ORDER ERROR:", err);

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
