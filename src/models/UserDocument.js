const pool = require("../../db");

const getUserDocument = async (userId) => {
  const query = `
    SELECT
      id,
      user_id,
      profile_image,
      created_at,
      created_by,
      updated_at,
      updated_by,
      is_active
    FROM user_documents
    WHERE user_id = $1
      AND is_active = true
    LIMIT 1;
  `;

  const result = await pool.query(query, [userId]);

  return result.rows[0];
};

const createOrUpdateProfileImage = async (
  userId,
  imageBuffer,
  createdBy,
  updatedBy
) => {
  const existing = await getUserDocument(userId);

  if (existing) {
    const query = `
      UPDATE user_documents
      SET
        profile_image = $1,
        updated_at = CURRENT_TIMESTAMP,
        updated_by = $2
      WHERE user_id = $3
      RETURNING
        id,
        user_id,
        created_at,
        created_by,
        updated_at,
        updated_by,
        is_active;
    `;

    const result = await pool.query(query, [
      imageBuffer,
      updatedBy,
      userId,
    ]);

    return result.rows[0];
  }

  const query = `
    INSERT INTO user_documents (
      user_id,
      profile_image,
      created_at,
      created_by,
      updated_at,
      updated_by,
      is_active
    )
    VALUES (
      $1,
      $2,
      CURRENT_TIMESTAMP,
      $3,
      CURRENT_TIMESTAMP,
      $4,
      true
    )
    RETURNING
      id,
      user_id,
      created_at,
      created_by,
      updated_at,
      updated_by,
      is_active;
  `;

  const result = await pool.query(query, [
    userId,
    imageBuffer,
    createdBy,
    updatedBy,
  ]);

  return result.rows[0];
};

const getProfileImage = async (userId) => {
  const query = `
    SELECT profile_image
    FROM user_documents
    WHERE user_id = $1
      AND is_active = true
      AND profile_image IS NOT NULL
    LIMIT 1;
  `;

  const result = await pool.query(query, [userId]);

  return result.rows[0];
};
const deleteProfileImage = async (userId) => {
  const query = `
    UPDATE user_documents
    SET
      profile_image = NULL,
      updated_at = CURRENT_TIMESTAMP,
      updated_by = $2
    WHERE user_id = $1
      AND is_active = true
      AND profile_image IS NOT NULL
    RETURNING
      id,
      user_id,
      updated_at,
      updated_by,
      is_active;
  `;

  const result = await pool.query(query, [
    userId,
    userId,
  ]);

  return result.rows[0];
};

module.exports = {
  getUserDocument,
  createOrUpdateProfileImage,
  getProfileImage,
   deleteProfileImage,
};