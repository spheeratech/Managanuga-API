
const pool = require("../../db");

const registerInstallation = async (data) => {
  const result = await pool.query(
    `
    INSERT INTO installation (
      mobile_number,
      device_id,
      device_name,
      os_type,
      os_version,
      app_version,
      build_number,
      status,
      is_active,
      last_seen_at,
      installed_at,
      fcm_token
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, 'INSTALLED', 1,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $8)
    ON CONFLICT (device_id)
    DO UPDATE SET
      mobile_number = EXCLUDED.mobile_number,
      device_name = EXCLUDED.device_name,
      os_type = EXCLUDED.os_type,
      os_version = EXCLUDED.os_version,
      app_version = EXCLUDED.app_version,
      build_number = EXCLUDED.build_number,
      status = 'INSTALLED',
      is_active = 1,
      last_seen_at = CURRENT_TIMESTAMP,
      uninstalled_at = NULL,
      fcm_token = EXCLUDED.fcm_token,
      updated_at = CURRENT_TIMESTAMP
    RETURNING *
    `,
    [
      data.mobile_number,
      data.device_id,
      data.device_name,
      data.os_type,
      data.os_version,
      data.app_version,
      data.build_number,
      data.fcm_token,
    ],
  );

  return result.rows[0];
};

const updateInstallation = async (deviceId, mobileNumber, data) => {
  const result = await pool.query(
    `
    UPDATE installation
    SET
      device_name = COALESCE($3, device_name),
      os_type = COALESCE($4, os_type),
      os_version = COALESCE($5, os_version),
      app_version = COALESCE($6, app_version),
      build_number = COALESCE($7, build_number),
      fcm_token = COALESCE($8, fcm_token),
      last_seen_at = CURRENT_TIMESTAMP,
      updated_at = CURRENT_TIMESTAMP
    WHERE device_id = $1
      AND mobile_number = $2
      AND is_active = 1
    RETURNING *
    `,
    [
      deviceId,
      mobileNumber,
      data.device_name ?? null,
      data.os_type ?? null,
      data.os_version ?? null,
      data.app_version ?? null,
      data.build_number ?? null,
      data.fcm_token ?? null,
    ],
  );

  return result.rows[0] || null;
};

const getInstallationsByMobile = async (mobileNumber) => {
  const result = await pool.query(
    `
    SELECT *
    FROM installation
    WHERE mobile_number = $1
    ORDER BY last_seen_at DESC NULLS LAST
    `,
    [mobileNumber],
  );

  return result.rows;
};

const getAllInstallations = async (limit = 100, offset = 0) => {
  const result = await pool.query(
    `
    SELECT *
    FROM installation
    ORDER BY created_at DESC
    LIMIT $1 OFFSET $2
    `,
    [limit, offset],
  );

  return result.rows;
};

const getInstallationById = async (id) => {
  const result = await pool.query(
    `SELECT * FROM installation WHERE id = $1 LIMIT 1`,
    [id],
  );

  return result.rows[0] || null;
};

const updateInstallationStatus = async (id, status) => {
  const isActive = status === "INSTALLED" ? 1 : 0;

  const result = await pool.query(
    `
    UPDATE installation
    SET
      status = $2,
      is_active = $3,
      uninstalled_at = CASE
        WHEN $2 = 'UNINSTALLED' THEN CURRENT_TIMESTAMP
        ELSE NULL
      END,
      updated_at = CURRENT_TIMESTAMP
    WHERE id = $1
    RETURNING *
    `,
    [id, status, isActive],
  );

  return result.rows[0] || null;
};

module.exports = {
  registerInstallation,
  updateInstallation,
  getInstallationsByMobile,
  getAllInstallations,
  getInstallationById,
  updateInstallationStatus,
};
