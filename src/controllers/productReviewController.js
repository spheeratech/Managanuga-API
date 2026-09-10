const ProductReview = require("../models/ProductReview");

const createReview = async (req, res) => {
  try {
    const { productId } = req.params;
    const { user_id, rating, review } = req.body;

    if (!user_id || !rating) {
      return res.status(400).json({
        success: false,
        message: "user_id and rating are required",
      });
    }

    if (Number(rating) < 1 || Number(rating) > 5) {
      return res.status(400).json({
        success: false,
        message: "Rating must be between 1 and 5",
      });
    }

    const result = await ProductReview.createReview(
      Number(productId),
      user_id,
      Number(rating),
      review || null
    );

    res.status(201).json({
      success: true,
      message: "Review submitted successfully",
      data: result,
    });
  } catch (error) {
    console.error("CREATE REVIEW ERROR:", error);

    if (error.code === "23505") {
      return res.status(409).json({
        success: false,
        message: "You have already reviewed this product",
      });
    }

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getProductReviews = async (req, res) => {
  try {
    const { productId } = req.params;

    const reviews = await ProductReview.getReviewsByProductId(
      Number(productId)
    );

    const rating = await ProductReview.getProductRating(
      Number(productId)
    );

    res.json({
      success: true,
      rating,
      count: reviews.length,
      data: reviews,
    });
  } catch (error) {
    console.error("GET REVIEWS ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  createReview,
  getProductReviews,
};