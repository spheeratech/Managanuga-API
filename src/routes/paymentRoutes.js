const express = require("express");
const router = express.Router();

const {
  createOrder,
  verifyPayment,
  getPayments,
  checkoutSummary,
} = require("../controllers/paymentController");

router.post("/create-order", createOrder);
router.post("/verify", verifyPayment);
router.post(
  "/checkout-summary",
  checkoutSummary
);
router.get("/", getPayments);

module.exports = router;
