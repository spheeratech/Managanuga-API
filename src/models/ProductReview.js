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
   CREATE / UPDATE ORDER REVIEW

   One review submitted for an order
   is applied to every product in
   that order.
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

    /* --------------------------------
       RESOLVE PUBLIC USER ID
       MGU2609xxxx -> user_login.id
    -------------------------------- */
    const userResult = await client.query(
      `
      SELECT id
      FROM user_login
      WHERE user_id = $1
      LIMIT 1
      `,
      [String(userId).trim()]
    );

    if (userResult.rows.length === 0) {
      throw new Error("User not found");
    }

    const internalUserId = userResult.rows[0].id;

    /* --------------------------------
       VERIFY ORDER BELONGS TO USER
    -------------------------------- */
    const orderResult = await client.query(
      `
      SELECT id
      FROM orders
      WHERE id = $1
        AND entity_type = 'USER'
        AND entity_id = $2
      LIMIT 1
      `,
      [Number(orderId), internalUserId]
    );

    if (orderResult.rows.length === 0) {
      throw new Error(
        "Order not found or does not belong to this user"
      );
    }

    /* --------------------------------
       GET ALL PRODUCTS IN ORDER
    -------------------------------- */
    const productsResult = await client.query(
      `
      SELECT DISTINCT item_id AS product_id
      FROM order_items
      WHERE order_id = $1
      `,
      [Number(orderId)]
    );

    if (productsResult.rows.length === 0) {
      throw new Error("No products found in this order");
    }

    const reviewedProducts = [];

    /* --------------------------------
       APPLY SAME REVIEW TO EACH PRODUCT
    -------------------------------- */
    for (const item of productsResult.rows) {
      const productId = item.product_id;

      /* Check whether this product was
         already reviewed for this order */
      const existingReview = await client.query(
        `
        SELECT id
        FROM product_reviews
        WHERE order_id = $1
          AND product_id = $2
          AND user_id = $3
        LIMIT 1
        `,
        [
          Number(orderId),
          Number(productId),
          String(userId).trim(),
        ]
      );

      let result;

      if (existingReview.rows.length > 0) {
        /* --------------------------------
           UPDATE EXISTING ORDER REVIEW
        -------------------------------- */
        result = await client.query(
          `
          UPDATE product_reviews
          SET
            rating = $1,
            review = $2,
            updated_at = CURRENT_TIMESTAMP
          WHERE id = $3
          RETURNING *
          `,
          [
            Number(rating),
            review || null,
            existingReview.rows[0].id,
          ]
        );
      } else {
        /* --------------------------------
           CREATE REVIEW FOR PRODUCT
        -------------------------------- */
        result = await client.query(
          `
          INSERT INTO product_reviews
            (
              product_id,
              user_id,
              rating,
              review,
              order_id
            )
          VALUES
            ($1, $2, $3, $4, $5)
          RETURNING *
          `,
          [
            Number(productId),
            String(userId).trim(),
            Number(rating),
            review || null,
            Number(orderId),
          ]
        );
      }

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
    throw error;
  } finally {
    client.release();
  }
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
  getReviewsByProductId,
  getProductRating,
};