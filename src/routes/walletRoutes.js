
const express = require("express");
const requireWalletOwner = require("../middleware/requireWalletOwner");

const router = express.Router();

const {
  getWallet,
  getWalletTransactions,
  payOrderWithWallet,
  createRedeemRequest,
  getRedeemStatus,
  getRedeemTransactions,
  getCustomerReferralWallet,
  getCustomerReferralTransactions,
  getCustomerReferralOrderPaymentBreakdown,
  getCustomerReferralSummary,
} = require("../controllers/walletController");

router.post("/redeem", requireWalletOwner, createRedeemRequest);
router.post("/pay-order/:orderId", requireWalletOwner, payOrderWithWallet);

router.get(
  "/:userId/transactions",
  requireWalletOwner,
  getWalletTransactions
);

router.get(
  "/redeem/transactions/:userId",
  requireWalletOwner,
  getRedeemTransactions
);

router.get(
  "/customer-referral/:userId",
  requireWalletOwner,
  getCustomerReferralWallet
);

router.get(
  "/customer-referral/transactions/:userId",
  requireWalletOwner,
  getCustomerReferralTransactions
);

router.get(
  "/customer-referral/summary/:userId",
  requireWalletOwner,
  getCustomerReferralSummary
);

router.get(
  "/customer-referral/:userId/orders/:orderId/payment-breakdown",
  requireWalletOwner,
  getCustomerReferralOrderPaymentBreakdown
);

router.get("/redeem/:userId", requireWalletOwner, getRedeemStatus);
router.get("/:userId", requireWalletOwner, getWallet);

module.exports = router;
