
const pool = require("../../db");

const getActiveAppUpdate = async (platform) => {
  const result = await pool.query(
    `
    SELECT
      platform,
      latest_version,
      minimum_version,
      update_message,
      store_url
    FROM app_update_config
    WHERE platform = $1
      AND is_active = 1
    LIMIT 1
    `,
    [platform],
  );

  return result.rows[0] || null;
};

module.exports = {
  getActiveAppUpdate,
};
