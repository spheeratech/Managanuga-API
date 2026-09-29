const express = require("express");

const router = express.Router();

const {
  addItem,
  getItems,
  updateItem,
  deleteItem,
  getItemById,
  getAllCartItems,
  getCartCount,
} = require("../controllers/cartController");

router.post("/", addItem);

router.get("/", getItems);

router.get("/count", getCartCount);

router.put("/:id", updateItem);

router.delete("/:id", deleteItem);

router.get("/:id", getItemById);

module.exports = router;