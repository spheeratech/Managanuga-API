const Cart = require("../models/Cart");
const pool = require("../../db");


// =====================================================
// HELPER: RESOLVE PUBLIC MGU ID → INTERNAL USER ID
// =====================================================
const resolveUserEntityId = async (entity_type, entity_id) => {
  let resolvedEntityId = entity_id;

  if (
    entity_type === "USER" &&
    typeof entity_id === "string" &&
    entity_id.startsWith("MGU")
  ) {
    const userResult = await pool.query(
      `
      SELECT id
      FROM user_login
      WHERE user_id = $1
        AND is_active = true
      LIMIT 1
      `,
      [entity_id]
    );

    if (!userResult.rows[0]) {
      return null;
    }

    resolvedEntityId = userResult.rows[0].id;
  }

  return resolvedEntityId;
};


// =====================================================
// ADD ITEM
// =====================================================
const addItem = async (req, res) => {
  try {
    const {
      entity_type,
      entity_id,
    } = req.body;

    if (!entity_type || !entity_id) {
      return res.status(400).json({
        success: false,
        message: "entity_type and entity_id are required",
      });
    }

    const resolvedEntityId = await resolveUserEntityId(
      entity_type,
      entity_id
    );

    if (resolvedEntityId === null) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const item = await Cart.addItem({
      ...req.body,
      entity_id: resolvedEntityId,
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
    const {
      entity_type,
      entity_id,
    } = req.query;

    // USER CART MUST ALWAYS BE SCOPED
    if (!entity_type || !entity_id) {
      return res.status(400).json({
        success: false,
        message: "entity_type and entity_id are required",
      });
    }

    const resolvedEntityId = await resolveUserEntityId(
      entity_type,
      entity_id
    );

    if (resolvedEntityId === null) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const items = await Cart.getItems(
      entity_type,
      resolvedEntityId
    );

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
    const {
      entity_type,
      entity_id,
    } = req.query;

    if (!entity_type || !entity_id) {
      return res.status(400).json({
        success: false,
        message: "entity_type and entity_id are required",
      });
    }

    const resolvedEntityId = await resolveUserEntityId(
      entity_type,
      entity_id
    );

    if (resolvedEntityId === null) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const item = await Cart.getItemById(
      req.params.id,
      entity_type,
      resolvedEntityId
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
      entity_type,
      entity_id,
      quantity,
    } = req.body;

    if (!entity_type || !entity_id) {
      return res.status(400).json({
        success: false,
        message: "entity_type and entity_id are required",
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

    const resolvedEntityId = await resolveUserEntityId(
      entity_type,
      entity_id
    );

    if (resolvedEntityId === null) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const item = await Cart.updateItem(
      req.params.id,
      entity_type,
      resolvedEntityId,
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
    const {
      entity_type,
      entity_id,
    } = req.body;

    if (!entity_type || !entity_id) {
      return res.status(400).json({
        success: false,
        message: "entity_type and entity_id are required",
      });
    }

    const resolvedEntityId = await resolveUserEntityId(
      entity_type,
      entity_id
    );

    if (resolvedEntityId === null) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const item = await Cart.deleteItem(
      req.params.id,
      entity_type,
      resolvedEntityId
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
// EXPORTS
// =====================================================
module.exports = {
  addItem,
  getItems,
  getItemById,
  updateItem,
  deleteItem,
};