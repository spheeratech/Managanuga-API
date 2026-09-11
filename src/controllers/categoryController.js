const Category = require("../models/Category");

// ==========================================
// GET ALL CATEGORIES
// ==========================================
const getCategories = async (req, res) => {
  try {
    const categories = await Category.getCategories();

    res.status(200).json({
      success: true,
      data: categories,
    });
  } catch (error) {
    console.error("GET CATEGORIES ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message || "Server Error",
    });
  }
};

// ==========================================
// GET ACTIVE CATEGORIES
// Used by Product Management
// ==========================================
const getActiveCategories = async (req, res) => {
  try {
    const categories = await Category.getActiveCategories();

    res.status(200).json({
      success: true,
      data: categories,
    });
  } catch (error) {
    console.error("GET ACTIVE CATEGORIES ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message || "Server Error",
    });
  }
};

// ==========================================
// GET CATEGORY BY ID
// ==========================================
const getCategoryById = async (req, res) => {
  try {
    const category = await Category.getCategoryById(req.params.id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: "Category not found",
      });
    }

    res.status(200).json({
      success: true,
      data: category,
    });
  } catch (error) {
    console.error("GET CATEGORY ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message || "Server Error",
    });
  }
};

// ==========================================
// CREATE CATEGORY
// ==========================================
const createCategory = async (req, res) => {
  try {
    const category = await Category.createCategory(req.body);

    res.status(201).json({
      success: true,
      message: "Category created successfully",
      data: category,
    });
  } catch (error) {
    console.error("CREATE CATEGORY ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message || "Server Error",
    });
  }
};

// ==========================================
// UPDATE CATEGORY
// ==========================================
const updateCategory = async (req, res) => {
  try {
    const category = await Category.updateCategory(req.params.id, req.body);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: "Category not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Category updated successfully",
      data: category,
    });
  } catch (error) {
    console.error("UPDATE CATEGORY ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message || "Server Error",
    });
  }
};

// ==========================================
// DELETE CATEGORY
// ==========================================
const deleteCategory = async (req, res) => {
  try {
    const category = await Category.deleteCategory(req.params.id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: "Category not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Category deleted successfully",
      data: category,
    });
  } catch (error) {
    console.error("DELETE CATEGORY ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message || "Server Error",
    });
  }
};

module.exports = {
  getCategories,
  getActiveCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
};
