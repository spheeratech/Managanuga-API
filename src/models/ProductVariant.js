const pool = require("../../db");

const getVariantsByProductId = async (productId) => {
  const result = await pool.query(
    `SELECT id, product_id, size, price, stock, is_active
     FROM product_variants
     WHERE product_id = $1
       AND is_active = 1
     ORDER BY id ASC`,
    [productId],
  );

  return result.rows;
};

module.exports = {
  getVariantsByProductId,
};