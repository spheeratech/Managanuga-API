const pool = require("../../db");

// Get all products
// Get all products
const getProducts = async () => {
  const result = await pool.query(`
    SELECT
      p.*,

      COALESCE(
        (
          SELECT ROUND(AVG(pr.rating)::numeric, 1)
          FROM product_reviews pr
          WHERE pr.product_id = p.id
        ),
        0
      ) AS average_rating,

      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'id', ai.id,
              'image_name', ai.image_name,
              'url', ai.url,
              'format', ai.format
            )
            ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_IMAGE'
            AND ai.is_active = 1
        ),
        '[]'
      ) AS images,

      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'id', ai.id,
              'image_name', ai.image_name,
              'url', ai.url,
              'format', ai.format
            )
            ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_VIEW'
            AND ai.is_active = 1
        ),
        '[]'
      ) AS product_views

    FROM lkp_products p
    ORDER BY p.display_order ASC
  `);

  return result.rows;
};

// Get product by id
const getProductById = async (id) => {
  const result = await pool.query(
    `
    SELECT
      p.*,
      COALESCE(
        (
          SELECT json_agg(
          json_build_object(
            'id', ai.id,
            'image_name', ai.image_name,
            'url', ai.url,
            'format', ai.format
          )
          ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_IMAGE'
            AND ai.is_active = 1
        ),
        '[]'
      ) AS images,
      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'id', ai.id,
              'image_name', ai.image_name,
              'url', ai.url,
              'format', ai.format
            )
            ORDER BY ai.id
          )
          FROM app_images ai
          WHERE ai.product_id = p.id
            AND ai.image_type = 'PRODUCT_VIEW'
            AND ai.is_active = 1
        ),
        '[]'
      ) AS product_views
    FROM lkp_products p
    WHERE p.id = $1
  `,
    [id],
  );

  return result.rows[0];
};

// const createProduct = async (productData) => {
//   const query = `
//     INSERT INTO lkp_products (
//       name,
//       price,
//       stock,
//       keywords
//     )
//     VALUES ($1, $2, $3, $4)
//     RETURNING *;
//   `;

//   const values = [
//     productData.name,
//     productData.price,
//     productData.stock,
//     productData.keywords,
//   ];

//   const result = await pool.query(query, values);

//   return result.rows[0];
// };

// const updateProduct = async (id, data) => {
//   const allowedFields = ["name", "price", "stock", "currency", "keywords"];

//   const fields = Object.keys(data).filter((field) =>
//     allowedFields.includes(field),
//   );

//   if (fields.length === 0) {
//     return null;
//   }

//   const setClause = fields
//     .map((field, index) => `${field} = $${index + 1}`)
//     .join(", ");

//   const values = [...fields.map((field) => data[field]), id];

//   const query = `
//     UPDATE lkp_products
//     SET ${setClause}
//     WHERE id = $${fields.length + 1}
//     RETURNING *;
//   `;

//   //   const result = await pool.query(query, values);

//   //   return result.rows[0];
//   // };
//   const result = await pool.query(query, values);

//   if (result.rows.length === 0) {
//     return null;
//   }

//   return getProductById(id);
// };

const createProduct = async (productData) => {
  const allowedFields = [
    "name",
    "price",
    "stock",
    "image",
    "weight",
    "category_id",
    "is_active",
    "discount",
    "gst",
    "volume",
    "description",
    "warehouse",
    "currency",
    "keywords",
    "display_order",
    "created_by",
    "updated_by",
  ];

  const fields = allowedFields.filter(
    (field) => productData[field] !== undefined,
  );

  if (!productData.name) {
    throw new Error("Product name is required");
  }

  const columns = fields.join(", ");
  const placeholders = fields.map((_, index) => `$${index + 1}`).join(", ");
  const values = fields.map((field) => productData[field]);

  const query = `
    INSERT INTO lkp_products (${columns})
    VALUES (${placeholders})
    RETURNING id;
  `;

  const result = await pool.query(query, values);

  return getProductById(result.rows[0].id);
};

const updateProduct = async (id, data) => {
  const allowedFields = [
    "name",
    "price",
    "stock",
    "image",
    "weight",
    "category_id",
    "is_active",
    "discount",
    "gst",
    "volume",
    "description",
    "warehouse",
    "currency",
    "keywords",
    "display_order",
    "updated_by",
  ];

  const fields = Object.keys(data).filter((field) => {
    if (!allowedFields.includes(field) || data[field] === undefined) {
      return false;
    }

    // Preserve an existing image when the request sends null or empty text.
    if (
      field === "image" &&
      (data[field] === null || String(data[field]).trim() === "")
    ) {
      return false;
    }

    return true;
  });

  const setClause = fields
    .map((field, index) => `${field} = $${index + 1}`)
    .concat("updated_at = CURRENT_TIMESTAMP")
    .join(", ");

  const values = [...fields.map((field) => data[field]), id];

  const query = `
    UPDATE lkp_products
    SET ${setClause}
    WHERE id = $${fields.length + 1}
    RETURNING id;
  `;

  const result = await pool.query(query, values);

  if (result.rows.length === 0) {
    return null;
  }

  return getProductById(id);
};

const deleteProduct = async (id) => {
  const result = await pool.query(
    "DELETE FROM lkp_products WHERE id = $1 RETURNING *",
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
