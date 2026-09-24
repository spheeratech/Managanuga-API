const Wishlist = require("../models/Wishlist");

/*
 * ============================================================
 * GET WISHLIST
 * ============================================================
 */
const getWishlist = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const items = await Wishlist.getWishlist(userId);

    return res.status(200).json({
      success: true,
      data: items,
    });
  } catch (error) {
    console.error("GET WISHLIST ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to get wishlist",
    });
  }
};

/*
 * ============================================================
 * ADD TO WISHLIST
 * ============================================================
 */
const addToWishlist = async (req, res) => {
  try {
    const { userId, productId } = req.body;

    if (!userId || !productId) {
      return res.status(400).json({
        success: false,
        message: "userId and productId are required",
      });
    }

    const item = await Wishlist.addToWishlist(
      userId,
      Number(productId)
    );

    return res.status(201).json({
      success: true,
      message: "Product added to wishlist",
      data: item,
    });
  } catch (error) {
    console.error("ADD WISHLIST ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to add product to wishlist",
    });
  }
};

/*
 * ============================================================
 * REMOVE FROM WISHLIST
 * ============================================================
 */
const removeFromWishlist = async (req, res) => {
  try {
    const { userId, productId } = req.params;

    if (!userId || !productId) {
      return res.status(400).json({
        success: false,
        message: "userId and productId are required",
      });
    }

    const item = await Wishlist.removeFromWishlist(
      userId,
      Number(productId)
    );

    if (!item) {
      return res.status(404).json({
        success: false,
        message: "Product not found in wishlist",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Product removed from wishlist",
      data: item,
    });
  } catch (error) {
    console.error("REMOVE WISHLIST ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to remove product from wishlist",
    });
  }
};

/*
 * ============================================================
 * SAVE FOR LATER
 *
 * Cart → Wishlist
 * Then remove from Cart
 * ============================================================
 */
const saveForLater = async (req, res) => {
  try {
    const { userId, cartId } = req.body;

    if (!userId || !cartId) {
      return res.status(400).json({
        success: false,
        message: "userId and cartId are required",
      });
    }

    const result = await Wishlist.saveForLater(
      userId,
      Number(cartId)
    );

    return res.status(200).json({
      success: true,
      message: "Product saved for later",
      data: result,
    });
  } catch (error) {
    console.error("SAVE FOR LATER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to save product for later",
    });
  }
};

module.exports = {
  getWishlist,
  addToWishlist,
  removeFromWishlist,
  saveForLater,
};