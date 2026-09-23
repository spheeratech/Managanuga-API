const express = require("express");

const {
  createReview,
  createOrderReview,
  getProductReviews,
} = require("../controllers/productReviewController");

const router = express.Router();

/* --------------------------------
   PRODUCT REVIEW
-------------------------------- */
router.post("/:productId/reviews", createReview);

/* --------------------------------
   ORDER REVIEW
   One review -> all products
   in that order
-------------------------------- */
router.post("/orders/:orderId/review", createOrderReview);

/* --------------------------------
   GET PRODUCT REVIEWS
-------------------------------- */
router.get("/:productId/reviews", getProductReviews);

module.exports = router;