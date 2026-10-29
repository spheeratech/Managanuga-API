const Product = require("../models/Product");
const Notification = require("../models/Notification");

const notifyProductChange = async (
  userId,
  title,
  message,
  referenceId = null,
) => {
  try {
    if (typeof userId !== "string" && typeof userId !== "number") {
      console.warn(
        "Product notification skipped: invalid user ID",
        typeof userId,
      );
      return;
    }

    await Notification.createNotification({
      userId: String(userId),
      title,
      message,
      type: "PRODUCT",
      referenceId:
        Number.isInteger(Number(referenceId)) && referenceId !== null
          ? Number(referenceId)
          : null,
    });

    console.log("Product notification created.");
  } catch (error) {
    console.error("Product notification failed:", error.message);
  }
};
// GET all products
const getProducts = async (req, res) => {
  try {
    const products = await Product.getProducts();

    res.status(200).json({
      success: true,
      data: products,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// GET product by id
const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await Product.getProductById(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.status(200).json({
      success: true,
      data: product,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};
const createProduct = async (req, res) => {
  try {
    const product = await Product.createProduct(req.body);

    res.status(201).json({
      success: true,
      message: "Product created successfully",
      data: product,
    });
    await notifyProductChange(
      req.body.userId,
      "Product Created Successfully",
      `Product ${product.name} has been created successfully.`,
      product.id,
    );
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};
const updateProduct = async (req, res) => {
  try {
    const product = await Product.updateProduct(req.params.id, req.body);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Product updated successfully",
      data: product,
    });
    await notifyProductChange(
      req.body.userId,
      "Product Updated Successfully",
      `Product ${product.name} has been updated successfully.`,
      product.id,
    );
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};
const deleteProduct = async (req, res) => {
  try {
    const product = await Product.deleteProduct(req.params.id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Product deleted successfully",
      data: product,
    });
    await notifyProductChange(
      req.body.userId,
      "Product Deleted Successfully",
      `Product ${product.name} has been deleted successfully.`,
      null,
    );
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
