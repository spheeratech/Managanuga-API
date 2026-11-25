
const express = require("express");

const {
  createReview,
  createOrderReview,
  getOrderReview,
  getProductReviews,
} = require("../controllers/productReviewController");

const router = express.Router();

/* --------------------------------
   PRODUCT REVIEW
-------------------------------- */
router.post("/:productId/reviews", createReview);

/* --------------------------------
   ORDER REVIEW
-------------------------------- */
router.post("/orders/:orderId/review", createOrderReview);

/* --------------------------------
   GET ORDER REVIEW
-------------------------------- */
router.get("/orders/:orderId/review", getOrderReview);

/* --------------------------------
   GET PRODUCT REVIEWS
-------------------------------- */
router.get("/:productId/reviews", getProductReviews);

module.exports = router;
