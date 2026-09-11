const pool = require("../../db");

const getAppImages = async () => {
  const result = await pool.query(`
    SELECT
      id,
      image_name,
      url,
      format,
      image_type
    FROM app_images
    WHERE image_type IN ('LOGO', 'BANNER', 'LOGIN_BG')
    ORDER BY
      CASE image_type
        WHEN 'LOGO' THEN 1
        WHEN 'BANNER' THEN 2
        WHEN 'LOGIN_BG' THEN 3
      END,
      id
  `);

  return result.rows;
};

module.exports = {
  getAppImages,
};
