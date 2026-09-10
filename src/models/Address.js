const pool = require("../../db");

const createAddress = async (addressData) => {
  const query = `
    INSERT INTO addresses (
      entity_type,
      entity_id,
      address_type,
      full_name,
      phone,
      address_line1,
      address_line2,
      city,
      state,
      country,
      postal_code,
      is_default
    )
    VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12
    )
    RETURNING *;
  `;

  const values = [
    addressData.entity_type,
    addressData.entity_id,
    addressData.address_type,
    addressData.full_name,
    addressData.phone,
    addressData.address_line1,
    addressData.address_line2,
    addressData.city,
    addressData.state,
    addressData.country,
    addressData.postal_code,
    addressData.is_default || false,
  ];

  const result = await pool.query(query, values);

  return result.rows[0];
};

const getAddresses = async (filters) => {
  let query = `SELECT * FROM addresses WHERE 1=1`;
  const values = [];
  let count = 1;

  if (filters.entity_type) {
    query += ` AND entity_type = $${count++}`;
    values.push(filters.entity_type);
  }

  if (filters.entity_id) {
    query += ` AND entity_id = $${count++}`;
    values.push(filters.entity_id);
  }

  if (filters.city) {
    query += ` AND city = $${count++}`;
    values.push(filters.city);
  }

  query += ` ORDER BY id DESC`;

  const result = await pool.query(query, values);

  return result.rows;
};
const updateAddress = async (id, data) => {
  const fields = Object.keys(data);

  if (fields.length === 0) {
    return null;
  }

  const setClause = fields
    .map((field, index) => `${field} = $${index + 1}`)
    .join(", ");

  const values = [...Object.values(data), id];

  const query = `
    UPDATE addresses
    SET ${setClause}
    WHERE id = $${fields.length + 1}
    RETURNING *;
  `;

  const result = await pool.query(query, values);

  return result.rows[0];
};
const deleteAddress = async (id) => {
  const query = `
    DELETE FROM addresses
    WHERE id = $1
    RETURNING *;
  `;

  const result = await pool.query(query, [id]);

  return result.rows[0];
};
const getDefaultAddress = async (entity_type, entity_id) => {
  const query = `
    SELECT *
    FROM addresses
    WHERE entity_type = $1
      AND entity_id = $2
      AND is_default = true
    LIMIT 1;
  `;

  const result = await pool.query(query, [entity_type, entity_id]);

  return result.rows[0];
};
module.exports = {
  createAddress,
  getAddresses,
  updateAddress,
  deleteAddress,
  getDefaultAddress,
};
