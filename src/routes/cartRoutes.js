const express = require("express");
const router = express.Router();

const {
  addItem,
  getItems,
  updateItem,
  deleteItem,
  getItemById,
  getAllCartItems,
} = require("../controllers/cartController");

router.post("/", addItem);

router.get("/", getItems);

router.put("/:id", updateItem);

router.delete("/:id", deleteItem);
router.get("/:id", getItemById);

module.exports = router;
