const express = require("express");

const router = express.Router();

const {
  getWallet,
  createRedeemRequest,
} = require("../controllers/walletController");

router.get("/:userId", getWallet);

router.post("/redeem", createRedeemRequest);

module.exports = router;