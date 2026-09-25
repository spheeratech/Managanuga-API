const pool = require("../../db");

/**
 * Resolve a public user_id (MGU...) to the internal user_login.id.
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
 * Resolve legacy entity_id.
 *
 * Old system:
 *   entity_id = user_login.id
 *
 * New system:
 *   user_id = user_login.user_id
 */
const resolveLegacyEntityId = async (entityId) => {
  if (entityId === undefined || entityId === null || entityId === "") {
    return null;
  }

  const value = String(entityId);

  // If it is numeric, treat it as the old internal user_login.id.
  if (/^\d+$/.test(value)) {
    const query = `
      SELECT id, user_id
      FROM user_login
      WHERE id = $1
      LIMIT 1;
    `;

    const result = await pool.query(query, [Number(value)]);

    return result.rows[0] || null;
  }

  // Otherwise it may already be a public user_id such as MGU260...
  return resolvePublicUserId(value);
};


const createAddress = async (addressData) => {
  /*
   * New API:
   *   user_id = public MGU ID
   *
   * Legacy API:
   *   entity_id = internal numeric user_login.id
   *
   * We support both during migration.
   */

  let publicUserId = addressData.user_id || null;
  let internalUserId = null;

  if (publicUserId) {
    const user = await resolvePublicUserId(publicUserId);

    if (!user) {
      throw new Error(`User not found for user_id: ${publicUserId}`);
    }

    publicUserId = user.user_id;
    internalUserId = user.id;
  } else if (addressData.entity_id) {
    const user = await resolveLegacyEntityId(addressData.entity_id);

    if (!user) {
      throw new Error(
        `User not found for entity_id: ${addressData.entity_id}`
      );
    }

    publicUserId = user.user_id;
    internalUserId = user.id;
  }

  if (!publicUserId) {
    throw new Error("user_id is required");
  }

  const query = `
    INSERT INTO addresses (
      user_id,
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
      $1,
      'USER',
      $2,
      $3,
      $4,
      $5,
      $6,
      $7,
      $8,
      $9,
      $10,
      $11,
      $12
    )
    RETURNING *;
  `;

  const values = [
    publicUserId,
    internalUserId,
    addressData.address_type || "HOME",
    addressData.full_name,
    addressData.phone,
    addressData.address_line1,
    addressData.address_line2 || null,
    addressData.city,
    addressData.state,
    addressData.country || "India",
    addressData.postal_code,
    addressData.is_default || false,
  ];

  const result = await pool.query(query, values);

  return result.rows[0];
};


const getAddresses = async (filters = {}) => {
  let query = `
    SELECT *
    FROM addresses
    WHERE 1=1
  `;

  const values = [];
  let count = 1;

  /*
   * NEW:
   * GET /addresses?user_id=MGU260...
   */
  if (filters.user_id) {
    query += ` AND user_id = $${count++}`;
    values.push(String(filters.user_id));
  }

  /*
   * Legacy support.
   */
  if (!filters.user_id && filters.entity_type) {
    query += ` AND entity_type = $${count++}`;
    values.push(filters.entity_type);
  }

  if (!filters.user_id && filters.entity_id) {
    const legacyUser = await resolveLegacyEntityId(filters.entity_id);

    if (legacyUser) {
      query += ` AND user_id = $${count++}`;
      values.push(legacyUser.user_id);
    } else {
      query += ` AND entity_id = $${count++}`;
      values.push(Number(filters.entity_id));
    }
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
 * Ownership/user_id cannot be changed through this function.
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
 * New usage:
 *   getDefaultAddress(userId)
 *
 * Legacy usage still supported:
 *   getDefaultAddress(entity_type, entity_id)
 */
const getDefaultAddress = async (userIdOrEntityType, entityId = null) => {
  let query;
  let values;

  // New usage: getDefaultAddress("MGU260...")
  if (entityId === null) {
    query = `
      SELECT *
      FROM addresses
      WHERE user_id = $1
        AND is_default = true
      ORDER BY id DESC
      LIMIT 1;
    `;

    values = [String(userIdOrEntityType)];
  } else {
    // Legacy usage
    const legacyUser = await resolveLegacyEntityId(entityId);

    if (legacyUser) {
      query = `
        SELECT *
        FROM addresses
        WHERE user_id = $1
          AND is_default = true
        ORDER BY id DESC
        LIMIT 1;
      `;

      values = [legacyUser.user_id];
    } else {
      query = `
        SELECT *
        FROM addresses
        WHERE entity_type = $1
          AND entity_id = $2
          AND is_default = true
        ORDER BY id DESC
        LIMIT 1;
      `;

      values = [userIdOrEntityType, entityId];
    }
  }

  const result = await pool.query(query, values);

  return result.rows[0];
};


module.exports = {
  createAddress,
  getAddresses,
  updateAddress,
  deleteAddress,
  getDefaultAddress,
};