
const { logException } = require("../utils/exceptionLogger.js");
const pool = require("../../db");

/* --------------------------------
   CREATE SINGLE PRODUCT REVIEW
   Existing product-detail review
-------------------------------- */

const createReview = async (
  productId,
  userId,
  rating,
  review
) => {
  const result = await pool.query(
    `
    INSERT INTO product_reviews
      (product_id, user_id, rating, review)
    VALUES
      ($1, $2, $3, $4)
    RETURNING *
    `,
    [productId, userId, rating, review]
  );

  return result.rows[0];
};

/* --------------------------------
   CREATE ORDER REVIEW

   One review per order.
   The same review is applied to
   every product in that order.
-------------------------------- */
const createOrderReview = async (
  orderId,
  userId,
  rating,
  review
) => {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // Resolve public user ID
    const userResult = await client.query(
      `
      SELECT user_id
      FROM user_login
      WHERE user_id = $1
      LIMIT 1
      `,
      [String(userId).trim()]
    );

    if (userResult.rows.length === 0) {
      throw new Error("User not found");
    }

    const publicUserId = String(
      userResult.rows[0].user_id
    ).trim();

    // Verify order ownership and lock the order row.
    // This prevents simultaneous duplicate submissions.
    const orderResult = await client.query(
      `
      SELECT id
      FROM orders
      WHERE id = $1
        AND user_id = $2
      FOR UPDATE
      `,
      [Number(orderId), publicUserId]
    );

    if (orderResult.rows.length === 0) {
      throw new Error(
        "Order not found or does not belong to this user"
      );
    }

    // Reject if this order has already been reviewed.
    const existingReview = await client.query(
      `
      SELECT id
      FROM product_reviews
      WHERE order_id = $1
        AND user_id = $2
      LIMIT 1
      `,
      [Number(orderId), publicUserId]
    );

    if (existingReview.rows.length > 0) {
      const error = new Error(
        "You have already reviewed this order"
      );
      error.code = "ORDER_REVIEW_EXISTS";
      throw error;
    }

    // Get actual product IDs from order variant IDs.
    const productsResult = await client.query(
      `
      SELECT DISTINCT
        pv.product_id AS product_id
      FROM orders o
      CROSS JOIN LATERAL
        unnest(
          o.item_id,
          o.quantity,
          o.unit_price
        )
        AS x(
          item_id,
          quantity,
          unit_price
        )
      JOIN product_variants pv
        ON pv.id = x.item_id
      JOIN lkp_products p
        ON p.id = pv.product_id
      WHERE o.id = $1
      `,
      [Number(orderId)]
    );

    if (productsResult.rows.length === 0) {
      throw new Error("No products found in this order");
    }

    const reviewedProducts = [];

    // Insert the same order review for each product.
    for (const item of productsResult.rows) {
      const result = await client.query(
        `
        INSERT INTO product_reviews
          (
            product_id,
            user_id,
            rating,
            review,
            order_id
          )
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *
        `,
        [
          Number(item.product_id),
          publicUserId,
          Number(rating),
          review || null,
          Number(orderId),
        ]
      );

      reviewedProducts.push(result.rows[0]);
    }

    await client.query("COMMIT");

    return {
      orderId: Number(orderId),
      productsReviewed: reviewedProducts.length,
      reviews: reviewedProducts,
    };
  } catch (error) {
    await client.query("ROLLBACK");
    void logException(error);
    throw error;
  } finally {
    client.release();
  }
};


/* --------------------------------
   GET REVIEW BY ORDER
-------------------------------- */
const getOrderReview = async (orderId, userId) => {
  const publicUserId = String(userId).trim();

  const orderResult = await pool.query(
    `
    SELECT id
    FROM orders
    WHERE id = $1
      AND user_id = $2
    LIMIT 1
    `,
    [Number(orderId), publicUserId]
  );

  if (orderResult.rows.length === 0) {
    throw new Error(
      "Order not found or does not belong to this user"
    );
  }

  const result = await pool.query(
    `
    SELECT
      order_id,
      rating,
      review,
      created_at
    FROM product_reviews
    WHERE order_id = $1
      AND user_id = $2
    ORDER BY id ASC
    LIMIT 1
    `,
    [Number(orderId), publicUserId]
  );

  return result.rows[0] || null;
};



/* --------------------------------
   GET PRODUCT REVIEWS
-------------------------------- */
const getReviewsByProductId = async (productId) => {
  const result = await pool.query(
    `
    SELECT
      pr.id,
      pr.product_id,
      pr.user_id,
      pr.rating,
      pr.review,
      pr.order_id,
      pr.created_at,
      pr.updated_at,
      ul.username
    FROM product_reviews pr
    LEFT JOIN user_login ul
      ON ul.user_id = pr.user_id
    WHERE pr.product_id = $1
    ORDER BY pr.created_at DESC
    `,
    [productId]
  );

  return result.rows;
};

/* --------------------------------
   GET PRODUCT RATING
-------------------------------- */
const getProductRating = async (productId) => {
  const result = await pool.query(
    `
    SELECT
      COALESCE(ROUND(AVG(rating), 1), 0) AS average_rating,
      COUNT(*) AS review_count
    FROM product_reviews
    WHERE product_id = $1
    `,
    [productId]
  );

  return result.rows[0];
};

module.exports = {
  createReview,
  createOrderReview,
  getOrderReview,
  getReviewsByProductId,
  getProductRating,
};