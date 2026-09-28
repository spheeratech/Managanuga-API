const express = require("express");

const router = express.Router();

const paymentController = require("../controllers/paymentController");

router.post(
  "/create-order",
  paymentController.createOrder
);

router.post(
  "/verify",
  paymentController.verifyPayment
);

router.post(
  "/checkout-summary",
  paymentController.checkoutSummary
);

router.get(
  "/",
  paymentController.getPayments
);

module.exports = router;