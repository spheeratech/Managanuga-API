const express = require("express");

const router = express.Router();

const {
  createAdminOrder,
  getAdminOrders,
  getAdminOrderById,
  updateAdminOrder,
  deleteAdminOrder,
  deleteAllAdminOrders,
  verifyAdminOrder,
} = require("../controllers/adminOrderController");

// router.post("/", createAdminOrder);

// Get all admin orders
router.get("/", getAdminOrders);

// router.delete("/delete-all", deleteAllAdminOrders);

router.get("/:id", getAdminOrderById);

router.put("/:id/verify", verifyAdminOrder);

router.put("/:id", updateAdminOrder);

// router.delete("/:id", deleteAdminOrder);

module.exports = router;
