const pool = require("../../db");

// Get all products
const getProducts = async () => {
  const result = await pool.query(`
    SELECT
      p.*,
      COALESCE(
        json_agg(
          json_build_object(
            'id', ai.id,
            'image_name', ai.image_name,
            'url', ai.url,
            'format', ai.format
          )
          ORDER BY ai.id
        ) FILTER (WHERE ai.id IS NOT NULL),
        '[]'
      ) AS images
    FROM products p
    LEFT JOIN app_images ai
      ON ai.product_id = p.id
      AND ai.image_type = 'PRODUCT_IMAGE'
    GROUP BY p.id
    ORDER BY p.id DESC
  `);

  return result.rows;
};

// Get product by id
const getProductById = async (id) => {
  const result = await pool.query(`
    SELECT
      p.*,
      COALESCE(
        json_agg(
          json_build_object(
            'id', ai.id,
            'image_name', ai.image_name,
            'url', ai.url,
            'format', ai.format
          )
          ORDER BY ai.id
        ) FILTER (WHERE ai.id IS NOT NULL),
        '[]'
      ) AS images
    FROM products p
    LEFT JOIN app_images ai
      ON ai.product_id = p.id
      AND ai.image_type = 'PRODUCT_IMAGE'
    WHERE p.id = $1
    GROUP BY p.id
  `, [id]);

  return result.rows[0];
};

const createProduct = async (productData) => {
  const query = `
    INSERT INTO products (
      name,
      price,
      stock,
      keywords
    )
    VALUES ($1, $2, $3, $4)
    RETURNING *;
  `;

  const values = [
    productData.name,
    productData.price,
    productData.stock,
    productData.keywords,
  ];

  const result = await pool.query(query, values);

  return result.rows[0];
};

const updateProduct = async (id, data) => {
  const allowedFields = ["name", "price", "stock", "currency", "keywords"];

  const fields = Object.keys(data).filter((field) =>
    allowedFields.includes(field),
  );

  if (fields.length === 0) {
    return null;
  }

  const setClause = fields
    .map((field, index) => `${field} = $${index + 1}`)
    .join(", ");

  const values = [...fields.map((field) => data[field]), id];

  const query = `
    UPDATE products
    SET ${setClause}
    WHERE id = $${fields.length + 1}
    RETURNING *;
  `;

  const result = await pool.query(query, values);

  return result.rows[0];
};
const deleteProduct = async (id) => {
  const result = await pool.query(
    "DELETE FROM products WHERE id = $1 RETURNING *",
    [id],
  );

  return result.rows[0];
};
module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
