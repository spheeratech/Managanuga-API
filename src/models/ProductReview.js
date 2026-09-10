const pool = require("../../db");

const createReview = async (productId, userId, rating, review) => {
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

const getReviewsByProductId = async (productId) => {
  const result = await pool.query(
    `
    SELECT
      pr.id,
      pr.product_id,
      pr.user_id,
      pr.rating,
      pr.review,
      pr.created_at,
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
  getReviewsByProductId,
  getProductRating,
};