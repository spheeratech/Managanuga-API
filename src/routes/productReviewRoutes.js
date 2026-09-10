const express = require("express");
const router = express.Router();

const {
  createReview,
  getProductReviews,
} = require("../controllers/productReviewController");

router.post("/:productId/reviews", createReview);

router.get("/:productId/reviews", getProductReviews);

module.exports = router;