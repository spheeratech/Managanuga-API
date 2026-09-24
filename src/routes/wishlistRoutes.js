const express = require("express");

const {
  getWishlist,
  addToWishlist,
  removeFromWishlist,
  saveForLater,
} = require("../controllers/wishlistController");

const router = express.Router();

/*
 * Get user's wishlist
 * GET /api/wishlist/:userId
 */
router.get("/:userId", getWishlist);

/*
 * Add product directly to wishlist
 * POST /api/wishlist
 */
router.post("/", addToWishlist);

/*
 * Save cart item for later
 * POST /api/wishlist/save-for-later
 */
router.post("/save-for-later", saveForLater);

/*
 * Remove product from wishlist
 * DELETE /api/wishlist/:userId/:productId
 */
router.delete("/:userId/:productId", removeFromWishlist);

module.exports = router;