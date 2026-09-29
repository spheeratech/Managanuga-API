const pool = require("../../db");

/**
 * Resolve a public user_id (MGU...) and verify that the user exists.
 */
const resolvePublicUserId = async (publicUserId) => {
  if (!publicUserId) return null;

  const query = `
    SELECT id, user_id
    FROM user_login
    WHERE user_id = $1
    LIMIT 1;
  `;

  const result = await pool.query(query, [String(publicUserId)]);

  return result.rows[0] || null;
};


/**
 * Create address
 *
 * New structure:
 *   user_id = public MGU user ID
 */
const createAddress = async (addressData) => {
  const publicUserId = addressData.user_id;

  if (!publicUserId) {
    throw new Error("user_id is required");
  }

  const user = await resolvePublicUserId(publicUserId);

  if (!user) {
    throw new Error(`User not found for user_id: ${publicUserId}`);
  }

  const query = `
    INSERT INTO addresses (
      user_id,
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
      $1,
      $2,
      $3,
      $4,
      $5,
      $6,
      $7,
      $8,
      $9,
      $10,
      $11
    )
    RETURNING *;
  `;

  const values = [
    user.user_id,
    addressData.address_type || "HOME",
    addressData.full_name,
    addressData.phone,
    addressData.address_line1,
    addressData.address_line2 || null,
    addressData.city,
    addressData.state,
    addressData.country || "India",
    addressData.postal_code,
    addressData.is_default || 0,
  ];

  const result = await pool.query(query, values);

  return result.rows[0];
};


/**
 * Get addresses
 *
 * New usage:
 *   GET /addresses?user_id=MGU260...
 */
const getAddresses = async (filters = {}) => {
  let query = `
    SELECT *
    FROM addresses
    WHERE 1=1
  `;

  const values = [];
  let count = 1;

  if (filters.user_id) {
    query += ` AND user_id = $${count++}`;
    values.push(String(filters.user_id));
  }

  if (filters.city) {
    query += ` AND city = $${count++}`;
    values.push(filters.city);
  }

  query += ` ORDER BY id DESC`;

  const result = await pool.query(query, values);

  return result.rows;
};


/**
 * Update only actual address fields.
 *
 * user_id cannot be changed through this function.
 */
const updateAddress = async (id, data) => {
  const allowedFields = [
    "address_type",
    "full_name",
    "phone",
    "address_line1",
    "address_line2",
    "city",
    "state",
    "country",
    "postal_code",
    "is_default",
  ];

  const fields = [];
  const values = [];

  for (const field of allowedFields) {
    if (Object.prototype.hasOwnProperty.call(data, field)) {
      fields.push(field);
      values.push(data[field]);
    }
  }

  if (fields.length === 0) {
    return null;
  }

  const setClause = fields
    .map((field, index) => `${field} = $${index + 1}`)
    .join(", ");

  values.push(id);

  const query = `
    UPDATE addresses
    SET ${setClause}
    WHERE id = $${values.length}
    RETURNING *;
  `;

  const result = await pool.query(query, values);

  return result.rows[0];
};


/**
 * Delete address
 */
const deleteAddress = async (id) => {
  const query = `
    DELETE FROM addresses
    WHERE id = $1
    RETURNING *;
  `;

  const result = await pool.query(query, [id]);

  return result.rows[0];
};


/**
 * Get default address by public user_id.
 */
const getDefaultAddress = async (userId) => {
  if (!userId) {
    throw new Error("user_id is required");
  }

  const query = `
    SELECT *
    FROM addresses
    WHERE user_id = $1
      AND is_default = 1
    ORDER BY id DESC
    LIMIT 1;
  `;

  const result = await pool.query(query, [String(userId)]);

  return result.rows[0];
};


module.exports = {
  createAddress,
  getAddresses,
  updateAddress,
  deleteAddress,
  getDefaultAddress,
};