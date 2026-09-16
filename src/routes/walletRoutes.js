const express = require("express");

const router = express.Router();

const {
  getWallet,
  createRedeemRequest,
  getRedeemStatus,
  getRedeemTransactions,
} = require("../controllers/walletController");

router.post("/redeem", createRedeemRequest);
router.get("/redeem/transactions/:userId", getRedeemTransactions);
router.get("/redeem/:userId", getRedeemStatus);
router.get("/:userId", getWallet);
module.exports = router;