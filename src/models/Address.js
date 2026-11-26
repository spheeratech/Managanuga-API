
const pool = require("../../db");

const normalizeDefaultFlag = (value) =>
  value === true ||
  value === 1 ||
  ["true", "1"].includes(String(value ?? "").trim().toLowerCase());

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
 * Create address for an authenticated user.
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
    INSERT INTO user_address (
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
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
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
    normalizeDefaultFlag(addressData.is_default),
  ];

  const result = await pool.query(query, values);

  return result.rows[0];
};


/**
 * Get addresses belonging only to the authenticated user.
 */
const getAddresses = async (filters = {}) => {
  if (!filters.user_id) {
    throw new Error("user_id is required");
  }

  let query = `
    SELECT *
    FROM user_address
    WHERE user_id = $1
  `;

  const values = [String(filters.user_id)];
  let count = 2;

  if (filters.city) {
    query += ` AND city = $${count++}`;
    values.push(filters.city);
  }

  query += ` ORDER BY id DESC`;

  const result = await pool.query(query, values);

  return result.rows;
};


/**
 * Update an address only when it belongs to the authenticated user.
 *
 * user_id cannot be changed through this function.
 */
const updateAddress = async (id, data, userId) => {
  if (!userId) {
    throw new Error("Authenticated user is required");
  }

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

      values.push(
        field === "is_default"
          ? normalizeDefaultFlag(data[field])
          : data[field]
      );
    }
  }

  if (fields.length === 0) {
    return null;
  }

  const setClause = fields
    .map((field, index) => `${field} = $${index + 1}`)
    .join(", ");

  values.push(id);
  values.push(String(userId));

  const query = `
    UPDATE user_address
    SET ${setClause}
    WHERE id = $${values.length - 1}
      AND user_id = $${values.length}
    RETURNING *;
  `;

  const result = await pool.query(query, values);

  return result.rows[0];
};


/**
 * Delete an address only when it belongs to the authenticated user.
 */
const deleteAddress = async (id, userId) => {
  if (!userId) {
    throw new Error("Authenticated user is required");
  }

  const query = `
    DELETE FROM user_address
    WHERE id = $1
      AND user_id = $2
    RETURNING *;
  `;

  const result = await pool.query(query, [
    id,
    String(userId),
  ]);

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
    FROM user_address
    WHERE user_id = $1
      AND is_default = TRUE
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
