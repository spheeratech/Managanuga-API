const pool = require("../../db");

// Get all products


const getProducts = async () => {
  const result = await pool.query(`
    SELECT
      p.*,

      -- Default variant price and ID
      COALESCE(dv.price, p.price) AS price,
      dv.id AS variant_id,
      dv.size AS variant_size,
      dv.stock AS default_variant_stock,

      -- Aggregate stock across all active variants
      CASE
        WHEN dv.id IS NOT NULL
          THEN COALESCE(vd.total_stock, 0)
        ELSE p.stock
      END AS stock,

      -- Variant availability
      (dv.id IS NOT NULL) AS has_variants,

      CASE
        WHEN dv.id IS NOT NULL
          THEN NOT COALESCE(vd.has_available_variant, FALSE)
        ELSE COALESCE(p.stock, 0) <= 0
      END AS is_out_of_stock,

      -- All active variants, including out-of-stock variants
      COALESCE(vd.variants, '[]'::json) AS variants,

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

    -- Select default variant: prefer 1L
    LEFT JOIN LATERAL (
      SELECT
        pv.id,
        pv.size,
        pv.price,
        pv.stock
      FROM product_variants pv
      WHERE pv.product_id = p.id
        AND pv.is_active = 1

ORDER BY
  CASE
    WHEN LOWER(REPLACE(TRIM(pv.size), ' ', '')) = '1l'
    THEN 0
    ELSE 1
  END,
  CASE
    WHEN COALESCE(pv.stock, 0) > 0 THEN 0
    ELSE 1
  END,
  CASE
    WHEN LOWER(pv.size) ~ '^[0-9]+([.][0-9]+)?[[:space:]]*(kg|l)$'
      THEN
        CASE
          WHEN LOWER(pv.size) LIKE '%kg'
            THEN CAST(REGEXP_REPLACE(LOWER(pv.size), '[^0-9.]', '', 'g') AS NUMERIC) * 1000
          ELSE CAST(REGEXP_REPLACE(LOWER(pv.size), '[^0-9.]', '', 'g') AS NUMERIC) * 1000
        END
    WHEN LOWER(pv.size) ~ '^[0-9]+([.][0-9]+)?[[:space:]]*(g|ml)$'
      THEN CAST(REGEXP_REPLACE(LOWER(pv.size), '[^0-9.]', '', 'g') AS NUMERIC)
    ELSE 0
  END DESC,
  pv.id

      LIMIT 1
    ) dv ON TRUE

    -- Return all active variants and aggregate stock
    LEFT JOIN LATERAL (
      SELECT
        json_agg(
          json_build_object(
            'id', pv.id,
            'size', pv.size,
            'price', pv.price,
            'stock', pv.stock,
            'is_available', COALESCE(pv.stock, 0) > 0
          )
          ORDER BY
            CASE
              WHEN LOWER(REPLACE(TRIM(pv.size), ' ', '')) = '1l'
              THEN 0
              ELSE 1
            END,
            pv.id
        ) AS variants,

        SUM(GREATEST(COALESCE(pv.stock, 0), 0))::integer
          AS total_stock,

        BOOL_OR(COALESCE(pv.stock, 0) > 0)
          AS has_available_variant

      FROM product_variants pv
      WHERE pv.product_id = p.id
        AND pv.is_active = 1
    ) vd ON TRUE

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
