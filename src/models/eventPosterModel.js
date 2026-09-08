const pool = require("../../db");

const getActiveEventPoster = async () => {
  // Permanently deactivate expired posters
  await pool.query(`
    UPDATE event_posters
    SET is_active = false
    WHERE ended_at <= NOW()
      AND is_active = true
  `);

  // Get the latest active poster
  const result = await pool.query(`
    SELECT
      id,
      image_url,
      created_at,
      ended_at,
      is_active
    FROM event_posters
    WHERE is_active = true
      AND created_at <= NOW()
      AND ended_at > NOW()
    ORDER BY created_at DESC
    LIMIT 1
  `);

  return result.rows[0] || null;
};

const createEventPoster = async (imageUrl, endedAt) => {
  const result = await pool.query(
    `
    INSERT INTO event_posters (
      image_url,
      ended_at,
      is_active
    )
    VALUES ($1, $2, true)
    RETURNING
      id,
      image_url,
      created_at,
      ended_at,
      is_active
    `,
    [imageUrl, endedAt],
  );

  return result.rows[0];
};

module.exports = {
  getActiveEventPoster,
  createEventPoster,
};