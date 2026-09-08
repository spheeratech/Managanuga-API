// Vendor membership benefits API
const express = require("express");

const router = express.Router();

const {
  getCustomers,
  getOrders,
  getBenefits,
} = require("../controllers/vendorController");

router.get(
  "/customers",
  getCustomers
);

router.get(
  "/orders",
  getOrders
);
router.get(
  "/benefits",
  getBenefits
);

module.exports = router;
