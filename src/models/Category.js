const pool = require("../../db");

// ==========================================
// GET ALL CATEGORIES
// Includes active + inactive categories
// ==========================================
const getCategories = async () => {
  const result = await pool.query(`
    SELECT
      id,
      name,
      description,
      is_active,
      created_at
    FROM categories
    ORDER BY id ASC
  `);

  return result.rows;
};

// ==========================================
// GET ACTIVE CATEGORIES
// Used by Product Management dropdown
// ==========================================
const getActiveCategories = async () => {
  const result = await pool.query(`
    SELECT
      id,
      name,
      description,
      is_active,
      created_at
    FROM categories
    WHERE is_active = 1
    ORDER BY name ASC
  `);

  return result.rows;
};

// ==========================================
// GET CATEGORY BY ID
// ==========================================
const getCategoryById = async (id) => {
  const result = await pool.query(
    `
    SELECT
      id,
      name,
      description,
      is_active,
      created_at
    FROM categories
    WHERE id = $1
    `,
    [id],
  );

  return result.rows[0];
};

// ==========================================
// CREATE CATEGORY
// ==========================================
const createCategory = async (categoryData) => {
  const result = await pool.query(
    `
    INSERT INTO categories (
      name,
      description,
      is_active
    )
    VALUES ($1, $2, $3)
    RETURNING *
    `,
    [
      categoryData.name,
      categoryData.description || "",
      categoryData.is_active ?? 1,
    ],
  );

  return result.rows[0];
};

// ==========================================
// UPDATE CATEGORY
// ==========================================
const updateCategory = async (id, data) => {
  const allowedFields = ["name", "description", "is_active"];

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

  const result = await pool.query(
    `
    UPDATE categories
    SET ${setClause}
    WHERE id = $${fields.length + 1}
    RETURNING *
    `,
    values,
  );

  return result.rows[0];
};

// ==========================================
// DELETE CATEGORY
// ==========================================
const deleteCategory = async (id) => {
  const result = await pool.query(
    `
    DELETE FROM categories
    WHERE id = $1
    RETURNING *
    `,
    [id],
  );

  return result.rows[0];
};

module.exports = {
  getCategories,
  getActiveCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
};
