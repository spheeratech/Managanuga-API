const pool = require("../../db");

// 1. STATES - Dynamic from StateList
const getStates = async () => {
  try {
    const result = await pool.query(`
      SELECT
        state_id AS id,
        TRIM("state_name") AS name
      FROM public.lkp_states      
        WHERE is_active = 1
      ORDER BY state_id ASC
    `);

    return result.rows;
  } catch (err) {
    console.error("Model getStates error:", err.message);
    return [];
  }
};
// 2. DISTRICTS - Dynamic from lkp_districts
const getDistrictsByState = async (stateId) => {
  try {
    const term = String(stateId ?? "").trim();

    console.log("DISTRICT API - Received stateId:", term);

    if (!term) return [];

    const result = await pool.query(
      `
      SELECT DISTINCT
        d.dist_id AS id,
        TRIM(d.dist_name) AS name,
        d.state_id
      FROM public.lkp_districts d
      INNER JOIN public.lkp_states s ON d.state_id = s.state_id
      WHERE d.state_id = $1
      ORDER BY dist_id ASC
    `,
      [term],
    );

    console.log("DISTRICT API - Returned:", result.rows.length);
    console.log("DISTRICT API - Sample:", result.rows.slice(0, 5));

    return result.rows;
  } catch (error) {
    console.error("getDistrictsByState error:", error.message);
    throw error;
  }
};

// 3. CITIES - Queries distname or matches via distcode

const getCitiesByDistrict = async (stateId, distId) => {
  const result = await pool.query(
    `
    SELECT DISTINCT
      c.city_id AS id,
      TRIM(c.city_name) AS name
    FROM public.lkp_cities c
    WHERE c.state_id = $1
      AND c.dist_id = $2
    ORDER BY c.city_id ASC
    `,
    [stateId, distId],
  );

  return result.rows;
};

// 4. PINCODES - Dynamic from lkp_area_pincode

const getPincodesByCity = async (stateId, distId, cityId) => {
  try {
    const stateTerm = String(stateId ?? "").trim();
    const districtTerm = String(distId ?? "").trim();
    const cityTerm = String(cityId ?? "").trim();

    console.log("GET PINCODES - State ID:", stateTerm);
    console.log("GET PINCODES - District ID:", districtTerm);
    console.log("GET PINCODES - City ID:", cityTerm);

    if (!stateTerm || !districtTerm || !cityTerm) {
      return [];
    }

    const result = await pool.query(
      `
      SELECT DISTINCT
        p.area_id AS id,
        

        p.area_name AS name,
        p.pincode As pincode
      FROM public.lkp_area_pincode p
      WHERE p.state_id = $1
        AND p.district_id = $2
        AND p.city_id = $3
        AND p.is_active = 1
        AND NOT EXISTS (
          SELECT 1
          FROM hubs h
          WHERE h.hubpincode = p.pincode
        )
        AND NOT EXISTS (
          SELECT 1
          FROM hubroute hr
          WHERE hr.hubroutepincode = p.pincode
        )
      ORDER BY p.pincode ASC
      `,
      [stateTerm, districtTerm, cityTerm],
    );

    console.log("GET PINCODES - Returned:", result.rows.length);
    console.log("GET PINCODES - Sample:", result.rows.slice(0, 5));

    return result.rows;
  } catch (error) {
    console.error("Model getPincodesByCity error:", error.message);
    throw error;
  }
};

// 5. HUBS & HUBROUTE CRUD
// const getHubs = async () => {
//   try {
//     const result = await pool.query(`
//       SELECT
//         h.hubid AS id,
//         h.hubname AS hub_name,
//         h.hubpincode AS pincode,
//         h.is_active,
//         h.created_at,
//         h.updated_at,
//         COALESCE(
//           (
//             SELECT json_agg(
//               json_build_object(
//                 'route_id', hr.hubrouteid,
//                 'pincode', hr.hubroutepincode,
//                 'city_name', hr.hubroutename
//               )
//             )
//             FROM hubroute hr
//             WHERE hr.hubid = h.hubid
//           ),
//           '[]'::json
//         ) AS routes
//       FROM hubs h
//       ORDER BY h.created_at DESC
//     `);
//     return result.rows;
//   } catch (error) {
//     console.error("Model getHubs error:", error.message);
//     return [];
//   }
// };
const getHubs = async () => {
  try {
    const result = await pool.query(`
      SELECT
        h.hubid AS id,
        h.hubname AS hub_name,
        h.hubpincode AS pincode,
        h.is_active,
        '[]'::json AS routes
      FROM hubs h
      ORDER BY h.hubid DESC
    `);
    return result.rows;
  } catch (error) {
    console.error("Model getHubs error:", error.message);
    throw error;
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
    const { hubName: requestedHubName, pincodes, isActive = 1 } = hubData;

    const activeValue =
      isActive === true || isActive === "true"
        ? 1
        : isActive === false || isActive === "false"
          ? 0
          : Number(isActive);

    if (!pincodes || !Array.isArray(pincodes) || pincodes.length === 0) {
      throw new Error("At least one pincode must be selected");
    }

    const areaName = String(pincodes[0].name ?? "").trim();
    const hubName = areaName || String(requestedHubName ?? "").trim();
    if (!hubName) throw new Error("Hub name or pincode area name is required");

    const primaryPincode = String(pincodes[0].pincode ?? "").trim();
    if (!primaryPincode) throw new Error("Selected pincode is required");
    const nonPrimaryPincodes = pincodes.slice(1);

    const existingCheck = await client.query(
      `
      SELECT h.hubid, h.hubname, h.hubpincode
      FROM hubs h
      LEFT JOIN hubroute hr ON hr.hubid = h.hubid
      WHERE h.hubpincode = $1 OR hr.hubroutepincode = $1
      LIMIT 1
    `,
      [primaryPincode],
    );

    if (existingCheck.rows.length > 0) {
      const existing = existingCheck.rows[0];
      throw new Error(
        `Pincode ${primaryPincode} is already assigned to hub "${existing.hubname}" (${existing.hubid}).`,
      );
    }

    const hubId = await generateHubId(client);

    const hubResult = await client.query(
      `
      INSERT INTO hubs (hubid, hubname, hubpincode, is_active, created_at, updated_at)
      VALUES ($1, $2, $3, $4, NOW(), NOW())
      RETURNING hubid AS id, hubname AS hub_name, hubpincode AS pincode, is_active, created_at, updated_at
    `,
      [hubId, hubName.trim(), primaryPincode, activeValue],
    );

    // try {
    //   await client.query(
    //     `UPDATE "pincodeList" SET "HubCode" = $1 WHERE "pincode" = $2`,
    //     [hubId, primaryPincode],
    //   );
    // } catch (err) {}

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
        const routeName =
          routeItem.name || routeItem.city_name || `${hubName} Route ${i + 1}`;
        const routePincode = String(routeItem.pincode).trim();

        await client.query(
          `
          INSERT INTO hubroute (hubrouteid, hubroutename, hubroutepincode, hubid, is_active, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
        `,
          [routeId, routeName, routePincode, hubId, activeValue],
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
    console.log(
      "SUCCESSFULLY COMMITTED HUB TO DATABASE:",
      hubResult.rows[0].id,
    ); // <-- ADD THIS
    return hubResult.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    console.error("CREATE HUB TRANSACTION FAILED:", error.message); // <-- ADD THIS
    throw error;
  } finally {
    client.release();
  }
};

const updateHub = async (hubId, hubData) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const { hubName: requestedHubName, pincodes, isActive = 1 } = hubData;

    const activeValue =
      isActive === true || isActive === "true"
        ? 1
        : isActive === false || isActive === "false"
          ? 0
          : Number(isActive);

    if (!pincodes || !Array.isArray(pincodes) || pincodes.length === 0) {
      throw new Error("At least one pincode must be selected");
    }

    const areaName = String(pincodes[0].name ?? "").trim();
    const hubName = areaName || String(requestedHubName ?? "").trim();
    if (!hubName) throw new Error("Hub name or pincode area name is required");

    const primaryPincode = String(pincodes[0].pincode ?? "").trim();
    if (!primaryPincode) throw new Error("Selected pincode is required");
    const nonPrimaryPincodes = pincodes.slice(1);

    const existingCheck = await client.query(
      `
      SELECT h.hubid, h.hubname, h.hubpincode
      FROM hubs h
      LEFT JOIN hubroute hr ON hr.hubid = h.hubid
      WHERE (h.hubpincode = $1 OR hr.hubroutepincode = $1) AND h.hubid != $2
      LIMIT 1
    `,
      [primaryPincode, hubId],
    );

    if (existingCheck.rows.length > 0) {
      const existing = existingCheck.rows[0];
      throw new Error(
        `Pincode ${primaryPincode} is already assigned to another hub "${existing.hubname}" (${existing.hubid}).`,
      );
    }

    const hubResult = await client.query(
      `
      UPDATE hubs
      SET hubname = $1, hubpincode = $2, is_active = $3, updated_at = NOW()
      WHERE hubid = $4
      RETURNING hubid AS id, hubname AS hub_name, hubpincode AS pincode, is_active, created_at, updated_at
    `,
      // [hubName.trim(), primaryPincode, isActive, hubId],
      [hubName.trim(), primaryPincode, activeValue, hubId],
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
        const routeName =
          routeItem.name || routeItem.city_name || `${hubName} Route ${i + 1}`;
        const routePincode = String(routeItem.pincode).trim();

        await client.query(
          `
          INSERT INTO hubroute (hubrouteid, hubroutename, hubroutepincode, hubid, is_active, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
        `,
          [routeId, routeName, routePincode, hubId, activeValue],
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
