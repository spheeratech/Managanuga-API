const pool = require("../../db");

async function findActiveHubForPincode(pincode, db = pool) {
  const normalizedPincode = String(pincode ?? "").trim();

  if (!/^\d{6}$/.test(normalizedPincode)) {
    throw new Error("Customer pincode must contain 6 digits.");
  }

  const numericPincode = Number(normalizedPincode);

  // First priority: primary hub pincode.
  let result = await db.query(
    `
    SELECT
      h.hubid AS id,
      h.hubpincode AS pincode
    FROM hubs h
    WHERE h.hubpincode = $1
      AND h.is_active = 1
    LIMIT 1
    `,
    [numericPincode],
  );

  if (result.rows.length > 0) {
    return result.rows[0];
  }

  // Second priority: additional hub-route pincode.
  result = await db.query(
    `
    SELECT
      h.hubid AS id,
      h.hubpincode AS pincode
    FROM hubroute hr
    INNER JOIN hubs h
      ON h.hubid = hr.hubid
    WHERE hr.hubroutepincode = $1
      AND hr.is_active = 1
      AND h.is_active = 1
    LIMIT 1
    `,
    [numericPincode],
  );

  if (result.rows.length > 0) {
    return result.rows[0];
  }

  // Default ManaGanuga hub.
  return {
    id: "HUB001",
    pincode: "500018",
  };
}

module.exports = {
  findActiveHubForPincode,
};