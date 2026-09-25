const express = require("express");

const router = express.Router();

const {
  getCustomers,
  getOrders,
  getBenefits,
  getProfile,
} = require("../controllers/vendorController");

// Vendor customers
router.get("/customers", getCustomers);

// Vendor orders
router.get("/orders", getOrders);

// Vendor membership benefits
router.get("/benefits", getBenefits);

// Vendor profile
router.get("/profile", getProfile);

module.exports = router;