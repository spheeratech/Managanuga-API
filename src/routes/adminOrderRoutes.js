const express = require("express");

const router = express.Router();

const {
  createAdminOrder,
  getAdminOrders,
  getAdminOrderById,
  getShiprocketTracking,
  updateAdminOrder,
  deleteAdminOrder,
  deleteAllAdminOrders,
  verifyAdminOrder,
} = require("../controllers/adminOrderController");

// router.post("/", createAdminOrder);

// Get all admin orders
router.get("/", getAdminOrders);
// Get live Shiprocket tracking for a specific order
router.get("/:id/tracking", getShiprocketTracking);
// router.delete("/delete-all", deleteAllAdminOrders);

router.get("/:id", getAdminOrderById);

router.put("/:id/verify", verifyAdminOrder);

router.put("/:id", updateAdminOrder);

// router.delete("/:id", deleteAdminOrder);

module.exports = router;
