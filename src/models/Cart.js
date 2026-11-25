const pool = require("../../db");

// =====================================================
// HELPER: GET CART ITEM DETAILS
// =====================================================
const getCartItemDetails = async (cartId, user_id = null) => {
  let query = `
    SELECT
      c.id AS cart_id,
      c.user_id,
      c.item_id AS product_id,
      c.variant_id,
      pv.size AS variant_size,
      p.name AS product_name,

      COALESCE(pv.price, p.price) AS price,
      p.weight,
      COALESCE(pv.stock, p.stock) AS stock,
      pv.stock AS variant_stock,

      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'id', ai.id,
              'image_name', ai.image_name,
              'url', ai.url,
              'format', ai.format
            )
            ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_IMAGE'
            AND ai.is_active = 1
        ),
        '[]'::json
      ) AS images,

      c.quantity,
      (COALESCE(pv.price, p.price) * c.quantity) AS total_price,
      c.created_at

    FROM cart_items c

    JOIN lkp_products p
      ON p.id = c.item_id

    LEFT JOIN product_variants pv
      ON pv.id = c.variant_id
      AND pv.product_id = c.item_id

    WHERE c.id = $1
      AND c.is_active = 1
      AND p.is_active = 1
  `;

  const values = [cartId];

  if (user_id !== null && user_id !== undefined) {
    query += ` AND c.user_id = $2`;
    values.push(String(user_id).trim());
  }

  const result = await pool.query(query, values);

  return result.rows[0] || null;
};


// =====================================================
// ADD ITEM — VARIANT-AWARE + STOCK VALIDATION
// =====================================================
const addItem = async (data) => {
  const {
    user_id,
    item_id,
    quantity = 1,
    variant_id = null,
  } = data;

  if (!user_id) {
    throw new Error("User ID is required");
  }

  if (!item_id) {
    throw new Error("Product ID is required");
  }

  const cleanUserId = String(user_id).trim();
  const addQuantity = Number(quantity);
  const cleanVariantId =
    variant_id === null || variant_id === undefined || variant_id === ""
      ? null
      : Number(variant_id);

  if (!Number.isFinite(addQuantity) || addQuantity <= 0) {
    throw new Error("Quantity must be greater than zero");
  }

  if (
    cleanVariantId !== null &&
    (!Number.isInteger(cleanVariantId) || cleanVariantId <= 0)
  ) {
    throw new Error("Invalid variant ID");
  }

  const result = await pool.query(
    `
    WITH cart_item AS (
      INSERT INTO cart_items (
        user_id,
        item_id,
        variant_id,
        quantity,
        is_active
      )

      SELECT
        $1,
        p.id,
        $4,
        $3,
        1

      FROM lkp_products p

      LEFT JOIN product_variants pv
        ON pv.id = $4
        AND pv.product_id = p.id
        AND pv.is_active = 1

      WHERE p.id = $2
        AND p.is_active = 1
        AND ($4::INTEGER IS NULL OR pv.id IS NOT NULL)
        AND COALESCE(pv.stock, p.stock) >= $3

      ON CONFLICT (
        user_id,
        item_id,
        (COALESCE(variant_id, 0))
      )
      WHERE is_active = 1

      DO UPDATE SET
        quantity = cart_items.quantity + EXCLUDED.quantity

      WHERE
        cart_items.quantity + EXCLUDED.quantity <= COALESCE(
          (
            SELECT pv.stock
            FROM product_variants pv
            WHERE pv.id = cart_items.variant_id
              AND pv.product_id = cart_items.item_id
              AND pv.is_active = 1
          ),
          (
            SELECT p.stock
            FROM lkp_products p
            WHERE p.id = cart_items.item_id
              AND p.is_active = 1
          )
        )

      RETURNING
        id,
        user_id,
        item_id,
        variant_id,
        quantity,
        created_at
    )

    SELECT
      c.id AS cart_id,
      c.user_id,
      c.item_id AS product_id,
      c.variant_id,
      pv.size AS variant_size,
      p.name AS product_name,

      COALESCE(pv.price, p.price) AS price,
      p.weight,
      COALESCE(pv.stock, p.stock) AS stock,
      pv.stock AS variant_stock,

      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'id', ai.id,
              'image_name', ai.image_name,
              'url', ai.url,
              'format', ai.format
            )
            ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_IMAGE'
            AND ai.is_active = 1
        ),
        '[]'::json
      ) AS images,

      c.quantity,
      (COALESCE(pv.price, p.price) * c.quantity) AS total_price,
      c.created_at

    FROM cart_item c

    JOIN lkp_products p
      ON p.id = c.item_id

    LEFT JOIN product_variants pv
      ON pv.id = c.variant_id
      AND pv.product_id = c.item_id

    WHERE p.is_active = 1
    `,
    [
      cleanUserId,
      item_id,
      addQuantity,
      cleanVariantId,
    ]
  );

  if (result.rowCount === 0) {
    throw new Error(
      "Product or variant is unavailable, or requested quantity exceeds available stock"
    );
  }

  return result.rows[0];
};


// =====================================================
// GET ALL ITEMS FOR SPECIFIC USER
// =====================================================
const getItems = async (user_id) => {
  if (!user_id) {
    throw new Error("User ID is required");
  }

  const cleanUserId = String(user_id).trim();

  const result = await pool.query(
    `
    SELECT
      c.id AS cart_id,
      c.user_id,
      c.item_id AS product_id,
      c.variant_id,
      pv.size AS variant_size,
      p.name AS product_name,

      COALESCE(pv.price, p.price) AS price,
      p.weight,
      COALESCE(pv.stock, p.stock) AS stock,
      pv.stock AS variant_stock,

      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'id', ai.id,
              'image_name', ai.image_name,
              'url', ai.url,
              'format', ai.format
            )
            ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_IMAGE'
            AND ai.is_active = 1
        ),
        '[]'::json
      ) AS images,

      c.quantity,
      (COALESCE(pv.price, p.price) * c.quantity) AS total_price,
      c.created_at

    FROM cart_items c

    JOIN lkp_products p
      ON p.id = c.item_id

    LEFT JOIN product_variants pv
      ON pv.id = c.variant_id
      AND pv.product_id = c.item_id

    WHERE c.user_id = $1
      AND c.is_active = 1
      AND p.is_active = 1

    ORDER BY c.id DESC
    `,
    [cleanUserId]
  );

  return result.rows;
};


// =====================================================
// GET ONE ITEM FOR SPECIFIC USER
// =====================================================
const getItemById = async (id, user_id) => {
  if (!user_id) {
    throw new Error("User ID is required");
  }

  return await getCartItemDetails(
    id,
    String(user_id).trim()
  );
};


// =====================================================
// UPDATE ITEM — STOCK VALIDATION
// =====================================================
const updateItem = async (id, user_id, quantity) => {
  if (!user_id) {
    throw new Error("User ID is required");
  }

  const cleanUserId = String(user_id).trim();
  const requestedQuantity = Number(quantity);

  if (
    !Number.isFinite(requestedQuantity) ||
    requestedQuantity <= 0
  ) {
    throw new Error("Quantity must be greater than zero");
  }

  const existing = await pool.query(
    `
    SELECT
      c.id,
      COALESCE(pv.stock, p.stock) AS available_stock

    FROM cart_items c

    JOIN lkp_products p
      ON p.id = c.item_id

    LEFT JOIN product_variants pv
      ON pv.id = c.variant_id
      AND pv.product_id = c.item_id

    WHERE c.id = $1
      AND c.user_id = $2
      AND c.is_active = 1
      AND p.is_active = 1
    `,
    [id, cleanUserId]
  );

  if (existing.rowCount === 0) {
    return null;
  }

  const availableStock = Number(existing.rows[0].available_stock);

  if (requestedQuantity > availableStock) {
    throw new Error(
      `Only ${availableStock} units are available in stock`
    );
  }

  const result = await pool.query(
    `
    UPDATE cart_items
    SET quantity = $1
    WHERE id = $2
      AND user_id = $3
      AND is_active = 1
    RETURNING id
    `,
    [
      requestedQuantity,
      id,
      cleanUserId,
    ]
  );

  if (result.rowCount === 0) {
    return null;
  }

  return await getCartItemDetails(id, cleanUserId);
};


// =====================================================
// DELETE ITEM FOR SPECIFIC USER
// =====================================================
const deleteItem = async (id, user_id) => {
  if (!user_id) {
    throw new Error("User ID is required");
  }

  const cleanUserId = String(user_id).trim();

  const result = await pool.query(
    `
    DELETE FROM cart_items
    WHERE id = $1
      AND user_id = $2
    RETURNING *
    `,
    [
      id,
      cleanUserId,
    ]
  );

  return result.rows[0] || null;
};


// =====================================================
// GET ALL CART ITEMS — ADMIN / INTERNAL USE
// =====================================================
const getAllItems = async () => {
  const result = await pool.query(
    `
    SELECT
      c.id AS cart_id,
      c.user_id,
      c.item_id AS product_id,
      c.variant_id,
      pv.size AS variant_size,
      p.name AS product_name,

      COALESCE(pv.price, p.price) AS price,
      p.weight,
      COALESCE(pv.stock, p.stock) AS stock,
      pv.stock AS variant_stock,

      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'id', ai.id,
              'image_name', ai.image_name,
              'url', ai.url,
              'format', ai.format
            )
            ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_IMAGE'
            AND ai.is_active = 1
        ),
        '[]'::json
      ) AS images,

      c.quantity,
      (COALESCE(pv.price, p.price) * c.quantity) AS total_price,
      c.created_at

    FROM cart_items c

    JOIN lkp_products p
      ON p.id = c.item_id

    LEFT JOIN product_variants pv
      ON pv.id = c.variant_id
      AND pv.product_id = c.item_id

    WHERE c.is_active = 1
      AND p.is_active = 1

    ORDER BY c.id DESC
    `
  );

  return result.rows;
};


// =====================================================
// GET CART COUNT
// =====================================================
const getCartCount = async (user_id) => {
  if (!user_id) {
    throw new Error("User ID is required");
  }

  const result = await pool.query(
    `
    SELECT COUNT(*)::INTEGER AS count
    FROM cart_items
    WHERE user_id = $1
      AND is_active = 1
    `,
    [String(user_id).trim()]
  );

  return result.rows[0].count;
};


// =====================================================
// EXPORTS
// =====================================================
module.exports = {
  addItem,
  getItems,
  getItemById,
  updateItem,
  deleteItem,
  getAllItems,
  getCartCount,
};