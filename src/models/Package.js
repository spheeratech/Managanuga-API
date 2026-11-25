const pool = require("../../db");

const Package = {
  async getAll({ activeOnly = false } = {}) {
    const result = await pool.query(
      `
      SELECT *
      FROM package_details
      ${activeOnly ? "WHERE is_active = 1" : ""}
      ORDER BY capacity_value ASC, pckg_id ASC
      `,
    );

    return result.rows;
  },

  async create(data) {
    const result = await pool.query(
      `
    INSERT INTO package_details (
      pckg_name,
      pckg_type,
      capacity_value,
      capacity_unit,
      pck_weight,
      pck_length,
      pck_breadth,
      pck_height,
      max_weight,
      gross_pckg_wt,
      is_active,
      created_by
    )
    VALUES (
      $1, $2, $3, $4, $5, $6,
      $7, $8, $9, $10, 1, $11
    )
    RETURNING *
    `,
      [
        data.pckg_name,
        data.pckg_type,
        data.capacity_value,
        data.capacity_unit,
        data.pck_weight,
        data.pck_length,
        data.pck_breadth,
        data.pck_height,
        data.max_weight,
        data.gross_pckg_wt,
        data.created_by,
      ],
    );

    return result.rows[0];
  },

  async update(pckgId, data, updatedBy) {
    const result = await pool.query(
      `
    UPDATE package_details
    SET
      pckg_name = $1,
      pckg_type = $2,
      capacity_value = $3,
      capacity_unit = $4,
      pck_weight = $5,
      pck_length = $6,
      pck_breadth = $7,
      pck_height = $8,
      max_weight = $9,
      gross_pckg_wt = $10,
      updated_by = $11,
      updated_at = CURRENT_TIMESTAMP
    WHERE pckg_id = $12
    RETURNING *
    `,
      [
        data.pckg_name,
        data.pckg_type,
        data.capacity_value,
        data.capacity_unit,
        data.pck_weight,
        data.pck_length,
        data.pck_breadth,
        data.pck_height,
        data.max_weight,
        data.gross_pckg_wt,
        updatedBy,
        pckgId,
      ],
    );

    return result.rows[0] || null;
  },

  async updateStatus(pckgId, isActive, updatedBy) {
    const result = await pool.query(
      `
      UPDATE package_details
      SET
        is_active = $1,
        updated_by = $2,
        updated_at = CURRENT_TIMESTAMP
      WHERE pckg_id = $3
      RETURNING *
      `,
      [isActive, updatedBy, pckgId],
    );

    return result.rows[0] || null;
  },
};

module.exports = Package;
