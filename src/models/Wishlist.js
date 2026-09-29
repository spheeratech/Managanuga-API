const pool = require("../../db");

/*
 * ============================================================
 * GET USER WISHLIST
 * ============================================================
 */
const getWishlist = async (userId) => {
  const publicUserId = String(userId).trim();

  if (!publicUserId) {
    throw new Error("User ID is required");
  }

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
            AND ai.is_active = 1
        ),
        '[]'
      ) AS images

    FROM wishlist_items w

    INNER JOIN products p
      ON p.id = w.product_id

    WHERE w.user_id = $1

    ORDER BY w.created_at DESC
    `,
    [publicUserId]
  );

  return result.rows;
};


/*
 * ============================================================
 * ADD PRODUCT TO WISHLIST
 * ============================================================
 */
const addToWishlist = async (userId, productId) => {
  const publicUserId = String(userId).trim();

  if (!publicUserId) {
    throw new Error("User ID is required");
  }

  /*
   * Verify product exists and is active.
   */
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

  /*
   * Check whether product is already in wishlist.
   *
   * We do this manually because the database currently
   * does not have a UNIQUE constraint on
   * (user_id, product_id).
   */
  const existingResult = await pool.query(
    `
    SELECT *
    FROM wishlist_items
    WHERE user_id = $1
      AND product_id = $2
    LIMIT 1
    `,
    [publicUserId, productId]
  );

  /*
   * Product already exists.
   * Refresh created_at and return the existing item.
   */
  if (existingResult.rowCount > 0) {
    const updateResult = await pool.query(
      `
      UPDATE wishlist_items
      SET created_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
      `,
      [existingResult.rows[0].id]
    );

    return updateResult.rows[0];
  }

  /*
   * Product does not exist.
   * Add it to wishlist.
   */
  const result = await pool.query(
    `
    INSERT INTO wishlist_items (
      user_id,
      product_id
    )
    VALUES ($1, $2)
    RETURNING *
    `,
    [publicUserId, productId]
  );

  return result.rows[0];
};


/*
 * ============================================================
 * REMOVE PRODUCT FROM WISHLIST
 * ============================================================
 */
const removeFromWishlist = async (userId, productId) => {
  const publicUserId = String(userId).trim();

  if (!publicUserId) {
    throw new Error("User ID is required");
  }

  const result = await pool.query(
    `
    DELETE FROM wishlist_items
    WHERE user_id = $1
      AND product_id = $2
    RETURNING *
    `,
    [publicUserId, productId]
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
 * If anything fails, everything is rolled back.
 * ============================================================
 */
const saveForLater = async (userId, cartId) => {
  const publicUserId = String(userId).trim();

  if (!publicUserId) {
    throw new Error("User ID is required");
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    /*
     * ========================================================
     * 1. FIND CART ITEM
     * ========================================================
     *
     * cart_items.user_id = public MGU user ID
     */
    const cartResult = await client.query(
      `
      SELECT
        c.id AS cart_id,
        c.item_id AS product_id
      FROM cart_items c
      WHERE c.id = $1
        AND c.user_id = $2
      LIMIT 1
      `,
      [cartId, publicUserId]
    );

    if (cartResult.rowCount === 0) {
      throw new Error("Cart item not found");
    }

    const productId = cartResult.rows[0].product_id;

    /*
     * ========================================================
     * 2. ADD PRODUCT TO WISHLIST
     * ========================================================
     *
     * wishlist_items.user_id = public MGU user ID
     */
    const existingWishlistResult = await client.query(
      `
      SELECT id
      FROM wishlist_items
      WHERE user_id = $1
        AND product_id = $2
      LIMIT 1
      `,
      [publicUserId, productId]
    );

    if (existingWishlistResult.rowCount > 0) {
      /*
       * Product already exists in wishlist.
       * Refresh timestamp.
       */
      await client.query(
        `
        UPDATE wishlist_items
        SET created_at = CURRENT_TIMESTAMP
        WHERE id = $1
        `,
        [existingWishlistResult.rows[0].id]
      );
    } else {
      /*
       * Add new wishlist item.
       */
      await client.query(
        `
        INSERT INTO wishlist_items (
          user_id,
          product_id
        )
        VALUES ($1, $2)
        `,
        [publicUserId, productId]
      );
    }

    /*
     * ========================================================
     * 3. REMOVE ITEM FROM CART
     * ========================================================
     *
     * cart_items.user_id = public MGU user ID
     */
    const deleteResult = await client.query(
      `
      DELETE FROM cart_items
      WHERE id = $1
        AND user_id = $2
      RETURNING id
      `,
      [cartId, publicUserId]
    );

    if (deleteResult.rowCount === 0) {
      throw new Error(
        "Failed to remove item from cart"
      );
    }

    /*
     * ========================================================
     * 4. COMMIT TRANSACTION
     * ========================================================
     */
    await client.query("COMMIT");

    return {
      product_id: productId,
      cart_id: Number(cartId),
    };
  } catch (error) {
    /*
     * Roll back both wishlist and cart changes
     * if anything fails.
     */
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};


/*
 * ============================================================
 * EXPORTS
 * ============================================================
 */
module.exports = {
  getWishlist,
  addToWishlist,
  removeFromWishlist,
  saveForLater,
};