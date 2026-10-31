const pool = require("../../db");

// Get all products

const getProducts = async () => {
  const result = await pool.query(`
    SELECT
      p.*,

      -- Category information
      c.name AS category_name,
      c.description AS category_description,
      p.category_id AS category_id,

      -- Average product rating
      COALESCE(
        (
          SELECT ROUND(AVG(pr.rating)::numeric, 1)
          FROM product_reviews pr
          WHERE pr.product_id = p.id
        ),
        0
      ) AS average_rating,

      -- Product images
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
        '[]'::json
      ) AS images,

      -- Additional product views
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
        '[]'::json
      ) AS product_views

    FROM public.lkp_products p
    LEFT JOIN public.lkp_categories c
      ON c.id = p.category_id

    ORDER BY
      p.display_order ASC NULLS LAST,
      p.id ASC
  `);

  return result.rows;
};


// Get product by ID
const getProductById = async (id) => {
  const result = await pool.query(
    `
    SELECT
      p.*,

      -- Category information
      c.name AS category_name,
      c.description AS category_description,
      p.category_id AS category_id,

      -- Product images
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
        '[]'::json
      ) AS images,

      -- Additional product views
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
        '[]'::json
      ) AS product_views

    FROM public.lkp_products p
    LEFT JOIN public.lkp_categories c
      ON c.id = p.category_id

    WHERE p.id = $1
    `,
    [id]
  );

  return result.rows[0];
};


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
