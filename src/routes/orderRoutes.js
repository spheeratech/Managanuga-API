const express = require("express");
const router = express.Router();

const {
  createOrder,
  getOrders,
  getOrderById,
  getOrderItems,
  updateOrder,
  deleteOrder,
  trackOrder
} = require("../controllers/orderController");

router.post("/", createOrder);

router.get("/", getOrders);

router.get("/:id/track", trackOrder);

router.get("/:id", getOrderById);

router.get("/:id/items", getOrderItems);

router.put("/:id", updateOrder);

router.delete("/:id", deleteOrder);



module.exports = router;
