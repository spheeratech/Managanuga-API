const ProductVariant = require("../models/ProductVariant");

const getVariantsByProductId = async (req, res) => {
  try {
    const { productId } = req.params;

    const variants = await ProductVariant.getVariantsByProductId(productId);

    return res.status(200).json({
      success: true,
      data: variants,
    });
  } catch (error) {
    console.error("Error fetching product variants:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch product sizes",
    });
  }
};

module.exports = {
  getVariantsByProductId,
};