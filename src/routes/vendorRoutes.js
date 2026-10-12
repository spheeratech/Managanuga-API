const express = require("express");
const requireAuthenticatedRole = require("../middleware/requireAuthenticatedRole");

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
router.get(
  "/benefits",
  requireAuthenticatedRole("VENDOR", "vendorId"),
  getBenefits
);

// Vendor profile
router.get("/profile", getProfile);

module.exports = router;