const Cart = require("../models/Cart");


// =====================================================
// ADD ITEM
// =====================================================
const addItem = async (req, res) => {
  try {
    const {
      user_id,
      item_id,
      quantity,
    } = req.body;

    if (!user_id || !item_id) {
      return res.status(400).json({
        success: false,
        message: "user_id and item_id are required",
      });
    }

    if (
      quantity === undefined ||
      quantity === null ||
      Number(quantity) <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "A valid quantity greater than 0 is required",
      });
    }

    const item = await Cart.addItem({
      user_id,
      item_id,
      quantity,
    });

    res.status(201).json({
      success: true,
      message: "Item added successfully",
      data: item,
    });

  } catch (error) {
    console.error("ADD CART ITEM ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// GET ITEMS FOR CURRENT USER
// =====================================================
const getItems = async (req, res) => {
  try {
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const items = await Cart.getItems(user_id);

    res.json({
      success: true,
      count: items.length,
      data: items,
    });

  } catch (error) {
    console.error("GET CART ITEMS ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// GET ONE ITEM
// =====================================================
const getItemById = async (req, res) => {
  try {
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const item = await Cart.getItemById(
      req.params.id,
      user_id
    );

    if (!item) {
      return res.status(404).json({
        success: false,
        message: "Item not found for this user",
      });
    }

    res.json({
      success: true,
      data: item,
    });

  } catch (error) {
    console.error("GET CART ITEM ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// UPDATE ITEM
// =====================================================
const updateItem = async (req, res) => {
  try {
    const {
      user_id,
      quantity,
    } = req.body;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    if (
      quantity === undefined ||
      quantity === null ||
      Number(quantity) <= 0
    ) {
      return res.status(400).json({
        success: false,
        message: "A valid quantity greater than 0 is required",
      });
    }

    const item = await Cart.updateItem(
      req.params.id,
      user_id,
      quantity
    );

    if (!item) {
      return res.status(404).json({
        success: false,
        message: "Item not found for this user",
      });
    }

    res.json({
      success: true,
      message: "Item updated successfully",
      data: item,
    });

  } catch (error) {
    console.error("UPDATE CART ITEM ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// DELETE ITEM
// =====================================================
const deleteItem = async (req, res) => {
  try {
    const { user_id } = req.body;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const item = await Cart.deleteItem(
      req.params.id,
      user_id
    );

    if (!item) {
      return res.status(404).json({
        success: false,
        message: "Item not found for this user",
      });
    }

    res.json({
      success: true,
      message: "Item deleted successfully",
      data: item,
    });

  } catch (error) {
    console.error("DELETE CART ITEM ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// GET CART COUNT
// =====================================================
const getCartCount = async (req, res) => {
  try {
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const count = await Cart.getCartCount(user_id);

    res.json({
      success: true,
      count,
    });

  } catch (error) {
    console.error("GET CART COUNT ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =====================================================
// EXPORTS
// =====================================================
module.exports = {
  addItem,
  getItems,
  getItemById,
  updateItem,
  deleteItem,
  getCartCount,
};