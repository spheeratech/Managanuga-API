const pool = require("../../db");

const getActiveEventPoster = async () => {
  // Permanently deactivate expired posters
  await pool.query(`
    UPDATE event_posters
    SET is_active = 0
    WHERE ended_at <= NOW()
      AND is_active = 1
  `);

  // Get the latest active poster
  const result = await pool.query(`
   SELECT
  id,
  event_name,
  event_description,
  image_url,
  created_at,
  ended_at,
  is_active
FROM event_posters
    WHERE is_active = 1
      AND created_at <= NOW()
      AND ended_at > NOW()
    ORDER BY created_at DESC
    LIMIT 1
  `);

  return result.rows[0] || null;
};
const createEventPoster = async (
  imageUrl,
  endedAt,
  eventName = null,
  eventDescription = null,
  isActive = 1,
  createdBy = null,
) => {
  const result = await pool.query(
    `
    INSERT INTO event_posters (
      image_url,
      ended_at,
      is_active,
      event_name,
      event_description,
      created_by
    )
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING
      id,
      image_url,
      event_name,
      event_description,
      created_at,
      ended_at,
      is_active,
      created_by
    `,
    [imageUrl, endedAt, isActive, eventName, eventDescription, createdBy],
  );

  return result.rows[0];
};
const getAllEventPosters = async () => {
  await pool.query(`
    UPDATE event_posters
    SET is_active = 0
    WHERE ended_at <= NOW()
      AND is_active = 1
  `);

  const result = await pool.query(`
    SELECT
      id,
      event_name,
      event_description,
      image_url,
      created_at,
      ended_at,
      is_active,
      created_by,
      updated_at,
      updated_by
    FROM event_posters
    ORDER BY created_at DESC
  `);

  return result.rows;
};

const updateEventPoster = async (
  id,
  eventName,
  eventDescription,
  imageUrl,
  endedAt,
  isActive,
  updatedBy,
) => {
  const result = await pool.query(
    `
    UPDATE event_posters
    SET
      event_name = $1,
      event_description = $2,
      image_url = COALESCE($3, image_url),
      ended_at = $4,
      is_active = $5,
      updated_by = $6,
      updated_at = NOW()
    WHERE id = $7
    RETURNING *
    `,
    [eventName, eventDescription, imageUrl, endedAt, isActive, updatedBy, id],
  );

  return result.rows[0] || null;
};

const deleteEventPoster = async (id) => {
  const result = await pool.query(
    `
    DELETE FROM event_posters
    WHERE id = $1
    RETURNING id, image_url
    `,
    [id],
  );

  return result.rows[0] || null;
};


module.exports = {
  getActiveEventPoster,
  createEventPoster,
  getAllEventPosters,
  updateEventPoster,
  deleteEventPoster,
};
