const express = require("express");
const requireAuthenticatedRole = require("../middleware/requireAuthenticatedRole");

const router = express.Router();

const paymentController = require("../controllers/paymentController");

router.post(
  "/create-order",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", true),
  paymentController.createOrder
);

router.post(
  "/verify",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "userId", true),
  paymentController.verifyPayment
);

router.post(
  "/memberships/:membershipId/customer-referral/recover",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", false),
  paymentController.recoverMembershipCustomerReferralReward
);

router.post(
  "/checkout-summary",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", true),
  paymentController.checkoutSummary
);

router.get(
  "/",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", true),
  paymentController.getPayments
);

module.exports = router;