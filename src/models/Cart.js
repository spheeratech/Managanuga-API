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
      p.name AS product_name,
      p.price,
      p.weight,
      p.stock,

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
        '[]'
      ) AS images,

      c.quantity,
      (p.price * c.quantity) AS total_price,
      c.created_at

    FROM cart_items c

    JOIN products p
      ON p.id = c.item_id

    WHERE c.id = $1
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
// ADD ITEM
// =====================================================
const addItem = async (data) => {
  const {
    user_id,
    item_id,
    quantity,
  } = data;

  if (!user_id) {
    throw new Error("User ID is required");
  }

  if (!item_id) {
    throw new Error("Product ID is required");
  }

  const cleanUserId = String(user_id).trim();

  // Check if this user already has this product
  const existing = await pool.query(
    `
    SELECT *
    FROM cart_items
    WHERE user_id = $1
      AND item_id = $2
    `,
    [
      cleanUserId,
      item_id,
    ]
  );

  // ===================================================
  // ITEM ALREADY EXISTS
  // ===================================================
  if (existing.rowCount > 0) {
    const updated = await pool.query(
      `
      UPDATE cart_items
      SET quantity = quantity + $1
      WHERE user_id = $2
        AND item_id = $3
      RETURNING *
      `,
      [
        quantity,
        cleanUserId,
        item_id,
      ]
    );

    return await getCartItemDetails(
      updated.rows[0].id,
      cleanUserId
    );
  }

  // ===================================================
  // NEW ITEM
  // ===================================================
  const result = await pool.query(
    `
    INSERT INTO cart_items (
      user_id,
      item_id,
      quantity
    )
    VALUES ($1, $2, $3)
    RETURNING *
    `,
    [
      cleanUserId,
      item_id,
      quantity,
    ]
  );

  return await getCartItemDetails(
    result.rows[0].id,
    cleanUserId
  );
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
      p.name AS product_name,
      p.price,
      p.weight,
      p.stock,

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
        '[]'
      ) AS images,

      c.quantity,
      (p.price * c.quantity) AS total_price,
      c.created_at

    FROM cart_items c

    JOIN products p
      ON p.id = c.item_id

    WHERE c.user_id = $1

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
// UPDATE ITEM FOR SPECIFIC USER
// =====================================================
const updateItem = async (
  id,
  user_id,
  quantity
) => {
  if (!user_id) {
    throw new Error("User ID is required");
  }

  const cleanUserId = String(user_id).trim();

  const result = await pool.query(
    `
    UPDATE cart_items
    SET quantity = $1
    WHERE id = $2
      AND user_id = $3
    RETURNING *
    `,
    [
      quantity,
      id,
      cleanUserId,
    ]
  );

  if (result.rowCount === 0) {
    return null;
  }

  return await getCartItemDetails(
    id,
    cleanUserId
  );
};


// =====================================================
// DELETE ITEM FOR SPECIFIC USER
// =====================================================
const deleteItem = async (
  id,
  user_id
) => {
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
// GET ALL CART ITEMS
// ADMIN / INTERNAL USE ONLY
// =====================================================
const getAllItems = async () => {
  const result = await pool.query(
    `
    SELECT
      c.id AS cart_id,
      c.user_id,
      c.item_id AS product_id,
      p.name AS product_name,
      p.price,
      p.weight,
      p.stock,

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
        '[]'
      ) AS images,

      c.quantity,
      (p.price * c.quantity) AS total_price,
      c.created_at

    FROM cart_items c

    JOIN products p
      ON p.id = c.item_id

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