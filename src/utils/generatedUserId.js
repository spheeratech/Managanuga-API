const pool = require("../../db");

const generateUserId = async (role) => {
  let prefix;

  switch (role.toUpperCase()) {
    case "SUPER_ADMIN":
      prefix = "MGSA";
      break;

    case "ADMIN":
      prefix = "MGA";
      break;

    case "VENDOR":
      prefix = "MGV";
      break;

    case "RESELLER":
      prefix = "MGRS";
      break;

    case "CUSTOMER":
      prefix = "MGC";
      break;

    default:
      throw new Error("Invalid role");
  }

  // Current year and month
  const now = new Date();

  const yy = String(now.getFullYear()).slice(-2);
  const mm = String(now.getMonth() + 1).padStart(2, "0");

  // Example: MGC2608
  const idPrefix = `${prefix}${yy}${mm}`;

  // Find the latest ID for this role in the current month
  const result = await pool.query(
    `
      SELECT user_id
      FROM user_login
      WHERE user_id LIKE $1
      ORDER BY user_id DESC
      LIMIT 1
    `,
    [`${idPrefix}%`],
  );

  let sequence = 1;

  if (result.rows.length > 0) {
    const lastId = result.rows[0].user_id;
    const sequencePart = lastId.substring(idPrefix.length);

    const lastSequence = parseInt(sequencePart, 10);

    if (!isNaN(lastSequence)) {
      sequence = lastSequence + 1;
    }
  }
  return `${idPrefix}${String(sequence).padStart(4, "0")}`;
};

module.exports = generateUserId;
