const pool = require("../../db");

/*
 * Resolve public MGU user ID to user_login.id
 */
const resolveUserId = async (userId) => {
  if (
    typeof userId === "number" ||
    (typeof userId === "string" && /^\d+$/.test(userId))
  ) {
    return Number(userId);
  }

  const result = await pool.query(
    `
    SELECT id
    FROM user_login
    WHERE user_id = $1
      AND is_active = true
    LIMIT 1
    `,
    [userId]
  );

  if (result.rowCount === 0) {
    throw new Error("User not found");
  }

  return result.rows[0].id;
};

/*
 * ============================================================
 * GET USER WISHLIST
 * ============================================================
 */
const getWishlist = async (userId) => {
  const numericUserId = await resolveUserId(userId);

  const result = await pool.query(
    `
    SELECT
      w.id AS wishlist_id,
      w.product_id,
      w.created_at,

      p.name,
      p.price,
      p.stock,
      p.image,
      p.weight,
      p.discount,
      p.gst,
      p.volume,
      p.description,
      p.currency,

      COALESCE(
        (
          SELECT ROUND(AVG(pr.rating)::numeric, 1)
          FROM product_reviews pr
          WHERE pr.product_id = p.id
        ),
        0
      ) AS average_rating,

      COALESCE(
        (
          SELECT COUNT(*)
          FROM product_reviews pr
          WHERE pr.product_id = p.id
        ),
        0
      ) AS review_count,

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
            AND ai.is_active = true
        ),
        '[]'
      ) AS images

    FROM wishlist_items w

    INNER JOIN products p
      ON p.id = w.product_id

    WHERE w.user_id = $1

    ORDER BY w.created_at DESC
    `,
    [numericUserId]
  );

  return result.rows;
};

/*
 * ============================================================
 * ADD PRODUCT TO WISHLIST
 * ============================================================
 */
const addToWishlist = async (userId, productId) => {
  const numericUserId = await resolveUserId(userId);

  const productResult = await pool.query(
    `
    SELECT id
    FROM products
    WHERE id = $1
      AND is_active = 1
    LIMIT 1
    `,
    [productId]
  );

  if (productResult.rowCount === 0) {
    throw new Error("Product not found");
  }

  const result = await pool.query(
    `
    INSERT INTO wishlist_items (
      user_id,
      product_id
    )
    VALUES ($1, $2)

    ON CONFLICT (user_id, product_id)
    DO UPDATE SET created_at = CURRENT_TIMESTAMP

    RETURNING *
    `,
    [numericUserId, productId]
  );

  return result.rows[0];
};

/*
 * ============================================================
 * REMOVE PRODUCT FROM WISHLIST
 * ============================================================
 */
const removeFromWishlist = async (userId, productId) => {
  const numericUserId = await resolveUserId(userId);

  const result = await pool.query(
    `
    DELETE FROM wishlist_items
    WHERE user_id = $1
      AND product_id = $2

    RETURNING *
    `,
    [numericUserId, productId]
  );

  return result.rows[0] || null;
};

/*
 * ============================================================
 * SAVE FOR LATER
 *
 * 1. Verify cart item belongs to this user
 * 2. Add product to wishlist
 * 3. Delete that cart item
 *
 * Everything happens inside one transaction.
 * If anything fails, nothing is changed.
 * ============================================================
 */
const saveForLater = async (userId, cartId) => {
  const numericUserId = await resolveUserId(userId);

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    /*
     * Find the cart item and make sure it belongs
     * to the logged-in user.
     */
    const cartResult = await client.query(
      `
      SELECT
        c.id AS cart_id,
        c.item_id AS product_id
      FROM cart_items c
      WHERE c.id = $1
        AND c.entity_type = 'USER'
        AND c.entity_id = $2
      LIMIT 1
      `,
      [cartId, numericUserId]
    );

    if (cartResult.rowCount === 0) {
      throw new Error("Cart item not found");
    }

    const productId = cartResult.rows[0].product_id;

    /*
     * Add product to wishlist.
     */
    await client.query(
      `
      INSERT INTO wishlist_items (
        user_id,
        product_id
      )
      VALUES ($1, $2)

      ON CONFLICT (user_id, product_id)
      DO UPDATE SET created_at = CURRENT_TIMESTAMP
      `,
      [numericUserId, productId]
    );

    /*
     * Remove the item from cart.
     */
    const deleteResult = await client.query(
      `
      DELETE FROM cart_items
      WHERE id = $1
        AND entity_type = 'USER'
        AND entity_id = $2

      RETURNING id
      `,
      [cartId, numericUserId]
    );

    if (deleteResult.rowCount === 0) {
      throw new Error("Failed to remove item from cart");
    }

    await client.query("COMMIT");

    return {
      product_id: productId,
      cart_id: Number(cartId),
    };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

module.exports = {
  getWishlist,
  addToWishlist,
  removeFromWishlist,
  saveForLater,
};