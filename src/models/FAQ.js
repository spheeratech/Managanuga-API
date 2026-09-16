const pool = require("../../db");

const FAQ = {
  async getByRole(role) {
    const normalizedRole =
      String(role).trim().toUpperCase() === "CUSTOMER"
        ? "USER"
        : String(role).trim().toUpperCase();

    const result = await pool.query(
      `
      SELECT
        id,
        role,
        document_type,
        document_link,
        is_active,
        created_at,
        updated_at,
        created_by
      FROM faqs
      WHERE role = $1
        AND document_type = 'FAQS'
        AND is_active = true
      ORDER BY id ASC
      LIMIT 1
      `,
      [normalizedRole]
    );

    return result.rows[0] || null;
  },
};

module.exports = FAQ;