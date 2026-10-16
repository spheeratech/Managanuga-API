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
router.get("/redeem/:userId", requireWalletOwner, getRedeemStatus);
router.get("/:userId", requireWalletOwner, getWallet);
module.exports = router;