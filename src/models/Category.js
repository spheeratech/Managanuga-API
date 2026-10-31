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
    FROM lkp_categories
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
    FROM lkp_categories
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
    FROM lkp_categories
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
    INSERT INTO lkp_categories (
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

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const setClause = fields
      .map((field, index) => `${field} = $${index + 1}`)
      .join(", ");

    const values = [...fields.map((field) => data[field]), id];

    const result = await client.query(
      `
      UPDATE lkp_categories
      SET ${setClause}
      WHERE id = $${fields.length + 1}
      RETURNING *
      `,
      values,
    );

    const updatedCategory = result.rows[0];

    if (!updatedCategory) {
      await client.query("COMMIT");
      return null;
    }

    // If category status was changed, sync its products
    if (fields.includes("is_active")) {
      await client.query(
        `
        UPDATE lkp_products
        SET is_active = $1
        WHERE category_id = $2
        `,
        [updatedCategory.is_active, id],
      );
    }

    await client.query("COMMIT");

    return updatedCategory;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

// ==========================================
// DELETE CATEGORY
// ==========================================
const deleteCategory = async (id) => {
  const result = await pool.query(
    `
    DELETE FROM lkp_categories
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
