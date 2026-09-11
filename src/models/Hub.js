const pool = require("../../db");

// 1. STATES - Dynamic from StateList
const getStates = async () => {
  try {
    const result = await pool.query(`
      SELECT 
        MIN("StateCode") AS id, 
        TRIM("StateName") AS name 
      FROM "StateList" 
      WHERE "StateName" IS NOT NULL
      GROUP BY TRIM("StateName")
      ORDER BY name ASC
    `);
    return result.rows;
  } catch (err) {
    console.error("Model getStates error:", err.message);
    return [];
  }
};

// 2. DISTRICTS - Dynamic from DistrictList
const getDistrictsByState = async (stateId) => {
  try {
    const term = String(stateId).trim();
    const result = await pool.query(
      `
      SELECT 
        "DistCode" AS id, 
        TRIM("DistName") AS name, 
        "StateCode" AS state_id 
      FROM "DistrictList" 
      WHERE "StateCode"::text = $1::text
      ORDER BY name ASC
    `,
      [term],
    );
    return result.rows;
  } catch (error) {
    console.error("Model getDistrictsByState error:", error.message);
    return [];
  }
};

// 3. CITIES - Queries distname or matches via distcode
// 3. CITIES - 100% Dynamic matching with ZERO hardcoded names
const getCitiesByDistrict = async (districtName) => {
  try {
    const term = String(districtName || "").trim();
    if (!term) return [];

    const result = await pool.query(
      `
      SELECT DISTINCT 
        c."CityCode" AS id, 
        c."CityCode" AS name 
      FROM "CityList" c
      WHERE 
        -- Matches if distname is populated:
        (c.distname IS NOT NULL AND LOWER(TRIM(c.distname)) = LOWER(TRIM($1::text)))
        -- Or matches dynamically against PinRegion if distname is NULL:
        OR (
          c.distname IS NULL 
          AND (
            c."PinRegion" ILIKE '%' || $1::text || '%'
            OR $1::text ILIKE '%' || c."PinRegion" || '%'
          )
        )
      ORDER BY c."CityCode" ASC
    `,
      [term],
    );

    return result.rows;
  } catch (error) {
    console.error("Model getCitiesByDistrict error:", error.message);
    return [];
  }
};

// 4. PINCODES - Dynamic from pincodeList
const getPincodesByCity = async (cityName) => {
  try {
    const city = String(cityName || "").trim();
    if (!city) return [];

    const result = await pool.query(
      `
      SELECT 
        ROW_NUMBER() OVER () AS id,
        "pincode" AS pincode,
        "PinArea" AS city_name,
        "HubCode" AS hub_code
      FROM "pincodeList"
      WHERE LOWER(TRIM("PinArea")) = LOWER(TRIM($1::text))
      ORDER BY "pincode" ASC
    `,
      [city],
    );
    return result.rows;
  } catch (error) {
    console.error("Model getPincodesByCity error:", error.message);
    return [];
  }
};

// 5. HUBS & HUBROUTE CRUD
const getHubs = async () => {
  try {
    const result = await pool.query(`
      SELECT
        h.hubid AS id,
        h.hubname AS hub_name,
        h.hubpincode AS pincode,
        h.is_active,
        h.created_at,
        h.updated_at,
        COALESCE(
          (
            SELECT json_agg(
              json_build_object(
                'route_id', hr.hubrouteid,
                'pincode', hr.hubroutepincode,
                'city_name', hr.hubroutename
              )
            )
            FROM hubroute hr
            WHERE hr.hubid = h.hubid
          ),
          '[]'::json
        ) AS routes
      FROM hubs h
      ORDER BY h.created_at DESC
    `);
    return result.rows;
  } catch (error) {
    console.error("Model getHubs error:", error.message);
    return [];
  }
};

const getHubById = async (hubId) => {
  const result = await pool.query(
    `
    SELECT
      h.hubid AS id,
      h.hubname AS hub_name,
      h.hubpincode AS pincode,
      h.is_active,
      h.created_at,
      h.updated_at,
      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'route_id', hr.hubrouteid,
              'pincode', hr.hubroutepincode,
              'city_name', hr.hubroutename
            )
          )
          FROM hubroute hr
          WHERE hr.hubid = h.hubid
        ),
        '[]'::json
      ) AS routes
    FROM hubs h
    WHERE h.hubid = $1
  `,
    [hubId],
  );
  return result.rows[0] || null;
};

const generateHubId = async (client) => {
  const result = await client.query(`
    SELECT hubid
    FROM hubs
    WHERE hubid ~ '^HUB[0-9]+$'
    ORDER BY CAST(SUBSTRING(hubid FROM 4) AS INTEGER) DESC
    LIMIT 1
  `);
  if (result.rows.length === 0) return "HUB001";
  const lastNumber = parseInt(result.rows[0].hubid.replace("HUB", ""), 10);
  return `HUB${String(lastNumber + 1).padStart(3, "0")}`;
};

const createHub = async (hubData) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const { hubName, pincodes, isActive = true } = hubData;

    if (!hubName || !hubName.trim()) throw new Error("Hub name is required");
    if (!pincodes || !Array.isArray(pincodes) || pincodes.length === 0) {
      throw new Error("At least one pincode must be selected");
    }

    const primaryPincode = String(pincodes[0].pincode).trim();
    const nonPrimaryPincodes = pincodes.slice(1);

    const existingCheck = await client.query(
      `
      SELECT hubid, hubname, hubpincode 
      FROM hubs 
      WHERE hubpincode = $1 OR LOWER(TRIM(hubname)) = LOWER(TRIM($2))
      LIMIT 1
    `,
      [primaryPincode, hubName.trim()],
    );

    if (existingCheck.rows.length > 0) {
      const existing = existingCheck.rows[0];
      throw new Error(
        `Hub already exists! Hub "${existing.hubname}" (${existing.hubid}) is already assigned to pincode ${existing.hubpincode}.`,
      );
    }

    const hubId = await generateHubId(client);

    const hubResult = await client.query(
      `
      INSERT INTO hubs (hubid, hubname, hubpincode, is_active, created_at, updated_at)
      VALUES ($1, $2, $3, $4, NOW(), NOW())
      RETURNING hubid AS id, hubname AS hub_name, hubpincode AS pincode, is_active, created_at, updated_at
    `,
      [hubId, hubName.trim(), primaryPincode, isActive],
    );

    try {
      await client.query(
        `UPDATE "pincodeList" SET "HubCode" = $1 WHERE "pincode" = $2`,
        [hubId, primaryPincode],
      );
    } catch (err) {}

    if (nonPrimaryPincodes.length > 0) {
      let baseRouteCount = 1;
      const lastRouteRes = await client.query(`
        SELECT hubrouteid FROM hubroute WHERE hubrouteid ~ '^HR[0-9]+$' 
        ORDER BY CAST(SUBSTRING(hubrouteid FROM 3) AS INTEGER) DESC LIMIT 1
      `);
      if (lastRouteRes.rows.length > 0) {
        baseRouteCount =
          parseInt(lastRouteRes.rows[0].hubrouteid.replace("HR", ""), 10) + 1;
      }

      for (let i = 0; i < nonPrimaryPincodes.length; i++) {
        const routeItem = nonPrimaryPincodes[i];
        const routeId = `HR${String(baseRouteCount + i).padStart(3, "0")}`;
        const routeName = routeItem.city_name || `${hubName} Route ${i + 1}`;
        const routePincode = String(routeItem.pincode).trim();

        await client.query(
          `
          INSERT INTO hubroute (hubrouteid, hubroutename, hubroutepincode, hubid, is_active, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
        `,
          [routeId, routeName, routePincode, hubId, isActive],
        );

        try {
          await client.query(
            `UPDATE "pincodeList" SET "HubCode" = $1 WHERE "pincode" = $2`,
            [hubId, routePincode],
          );
        } catch (err) {}
      }
    }

    await client.query("COMMIT");
    return hubResult.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

const updateHub = async (hubId, hubData) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const { hubName, pincodes, isActive = true } = hubData;

    if (!hubName || !hubName.trim()) throw new Error("Hub name is required");
    if (!pincodes || !Array.isArray(pincodes) || pincodes.length === 0) {
      throw new Error("At least one pincode must be selected");
    }

    const primaryPincode = String(pincodes[0].pincode).trim();
    const nonPrimaryPincodes = pincodes.slice(1);

    const existingCheck = await client.query(
      `
      SELECT hubid, hubname, hubpincode 
      FROM hubs 
      WHERE (hubpincode = $1 OR LOWER(TRIM(hubname)) = LOWER(TRIM($2))) AND hubid != $3
      LIMIT 1
    `,
      [primaryPincode, hubName.trim(), hubId],
    );

    if (existingCheck.rows.length > 0) {
      const existing = existingCheck.rows[0];
      throw new Error(
        `Another hub "${existing.hubname}" (${existing.hubid}) is already using pincode ${existing.hubpincode}.`,
      );
    }

    const hubResult = await client.query(
      `
      UPDATE hubs
      SET hubname = $1, hubpincode = $2, is_active = $3, updated_at = NOW()
      WHERE hubid = $4
      RETURNING hubid AS id, hubname AS hub_name, hubpincode AS pincode, is_active, created_at, updated_at
    `,
      [hubName.trim(), primaryPincode, isActive, hubId],
    );

    if (hubResult.rows.length === 0) throw new Error("Hub not found");

    try {
      await client.query(
        `UPDATE "pincodeList" SET "HubCode" = NULL WHERE "HubCode" = $1`,
        [hubId],
      );
    } catch (e) {}
    await client.query(`DELETE FROM hubroute WHERE hubid = $1`, [hubId]);

    try {
      await client.query(
        `UPDATE "pincodeList" SET "HubCode" = $1 WHERE "pincode" = $2`,
        [hubId, primaryPincode],
      );
    } catch (err) {}

    if (nonPrimaryPincodes.length > 0) {
      let baseRouteCount = 1;
      const lastRouteRes = await client.query(`
        SELECT hubrouteid FROM hubroute WHERE hubrouteid ~ '^HR[0-9]+$' 
        ORDER BY CAST(SUBSTRING(hubrouteid FROM 3) AS INTEGER) DESC LIMIT 1
      `);
      if (lastRouteRes.rows.length > 0) {
        baseRouteCount =
          parseInt(lastRouteRes.rows[0].hubrouteid.replace("HR", ""), 10) + 1;
      }

      for (let i = 0; i < nonPrimaryPincodes.length; i++) {
        const routeItem = nonPrimaryPincodes[i];
        const routeId = `HR${String(baseRouteCount + i).padStart(3, "0")}`;
        const routeName = routeItem.city_name || `${hubName} Route ${i + 1}`;
        const routePincode = String(routeItem.pincode).trim();

        await client.query(
          `
          INSERT INTO hubroute (hubrouteid, hubroutename, hubroutepincode, hubid, is_active, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
        `,
          [routeId, routeName, routePincode, hubId, isActive],
        );

        try {
          await client.query(
            `UPDATE "pincodeList" SET "HubCode" = $1 WHERE "pincode" = $2`,
            [hubId, routePincode],
          );
        } catch (err) {}
      }
    }

    await client.query("COMMIT");
    return hubResult.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

const deleteHub = async (hubId) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    try {
      await client.query(
        `UPDATE "pincodeList" SET "HubCode" = NULL WHERE "HubCode" = $1`,
        [hubId],
      );
    } catch (e) {}
    await client.query(`DELETE FROM hubroute WHERE hubid = $1`, [hubId]);
    const result = await client.query(
      `DELETE FROM hubs WHERE hubid = $1 RETURNING hubid AS id`,
      [hubId],
    );
    await client.query("COMMIT");
    return result.rows[0] || null;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

module.exports = {
  getStates,
  getDistrictsByState,
  getCitiesByDistrict,
  getPincodesByCity,
  getHubs,
  getHubById,
  createHub,
  updateHub,
  deleteHub,
};
