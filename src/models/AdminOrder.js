const { logException } = require("../utils/exceptionLogger.js");
const pool = require("../../db");

/* --------------------------------
   CREATE ADMIN ORDER
-------------------------------- */

// const createAdminOrder = async ({
//   user_id,
//   productId,
//   quantity = 1,
//   warehouse_id = null,
// }) => {
//   const client = await pool.connect();

//   try {
//     await client.query("BEGIN");

//     // --------------------------------
//     // GET CUSTOMER
//     // --------------------------------

//     const userResult = await client.query(
//       `
//       SELECT
//         ul.user_id,
//         ul.username,
//         ul.mobile_no,
//         ui.first_name,
//         ui.last_name,
//         ui.email,
//         ui.address,
//         ui.city,
//         ui.state,
//         ui.pincode
//       FROM user_login ul
//       LEFT JOIN user_info ui
//         ON ul.user_id = ui.user_id
//       WHERE ul.user_id = $1::varchar
//       `,
//       [String(user_id)],
//     );

//     if (userResult.rowCount === 0) {
//       throw new Error("Customer not found");
//     }

//     const customer = userResult.rows[0];

//     // --------------------------------
//     // GET PRODUCT
//     // --------------------------------

//     const productResult = await client.query(
//       `
//       SELECT
//         id,
//         name,
//         price,
//         stock
//       FROM lkp_public.lkp_products
//       WHERE id = $1::integer
//         AND is_active = 1
//       FOR UPDATE
//       `,
//       [Number(productId)],
//     );

//     if (productResult.rowCount === 0) {
//       throw new Error("Product not found");
//     }

//     const product = productResult.rows[0];

//     // --------------------------------
//     // VALIDATE QUANTITY
//     // --------------------------------

//     const orderQuantity = Number(quantity);

//     if (!Number.isInteger(orderQuantity) || orderQuantity <= 0) {
//       throw new Error("Quantity must be a positive number");
//     }

//     // --------------------------------
//     // STOCK CHECK
//     // --------------------------------

//     if (Number(product.stock) < orderQuantity) {
//       throw new Error(`Insufficient stock. Available stock: ${product.stock}`);
//     }

//     // --------------------------------
//     // CALCULATE TOTAL
//     // --------------------------------

//     const totalAmount = Number(product.price) * orderQuantity;

//     // --------------------------------
//     // CREATE ORDER
//     // --------------------------------

//     const orderResult = await client.query(
//       `
//       INSERT INTO orders
//       (
//         user_id,
//         actual_amount,
//         membership_discount,
//         wallet_claim,
//         delivery_charge,
//         item_id,
//         quantity,
//         unit_price,
//         payable_amount,
//         warehouse_id,
//         item_id,
//         quantity,
//         unit_price,
//         status,
//         payment_status,
//         is_active
//       )
//       VALUES
//       (
//         $1::varchar,
//         $2::numeric,
//         0,
//         0,
//         0,
//         ARRAY[$4::integer],
//         ARRAY[$5::integer],
//         ARRAY[$6::numeric],
//         $2::numeric,
//         $3::integer,
//         'PENDING',
//         'PENDING',
//         1
//       )
//       RETURNING *
//       `,
//       [
//         String(user_id),
//         totalAmount,
//         warehouse_id === null ? null : Number(warehouse_id),
//         Number(product.id),
//         orderQuantity,
//         Number(product.price),
//         [Number(product.id)],
//         [orderQuantity],
//         [Number(product.price)],
//       ],
//     );

//     const order = orderResult.rows[0];

//     // --------------------------------
//     // DEDUCT STOCK
//     // --------------------------------

//     const stockUpdate = await client.query(
//       `
//       UPDATE lkp_products
//       SET stock = stock - $1::integer
//       WHERE id = $2::integer
//         AND is_active = 1
//         AND stock >= $1::integer
//       RETURNING id
//       `,
//       [orderQuantity, Number(product.id)],
//     );
//     if (!stockUpdate.rows[0]) {
//       throw new Error("Product stock changed; admin order was not created");
//     }

//     // --------------------------------
//     // COMMIT
//     // --------------------------------

//     await client.query("COMMIT");

//     // --------------------------------
//     // RETURN CREATED ORDER
//     // --------------------------------

//     return {
//       ...order,

//       customer: {
//         user_id: customer.user_id,

//         name:
//           `${customer.first_name || ""} ${customer.last_name || ""}`.trim() ||
//           customer.username,

//         mobile_no: customer.mobile_no,
//         email: customer.email,
//         address: customer.address,
//         city: customer.city,
//         state: customer.state,
//         pincode: customer.pincode,
//       },

//       items: [
//         {
//           product_id: product.id,
//           product_name: product.name,
//           quantity: orderQuantity,
//           price: product.price,
//           subtotal: totalAmount,
//         },
//       ],
//     };
//   } catch (error) {
//     void logException(error);
//     await client.query("ROLLBACK");
//     throw error;
//   } finally {
//     client.release();
//   }
// };

/* --------------------------------
   GET ALL ADMIN ORDERS
-------------------------------- */

const getAdminOrders = async () => {
  const result = await pool.query(`
    SELECT
      o.id,
      o.order_id,
      o.user_id,
      o.address_id,

      -- Amount breakdown
      o.actual_amount,
      o.actual_amount AS total_amount,
      COALESCE(o.membership_discount, 0) AS membership_discount,
      COALESCE(o.wallet_claim, 0) AS wallet_claim,
      COALESCE(o.coupon_discount, 0) AS coupon_discount,
      COALESCE(o.delivery_charge, 0) AS delivery_charge,
      COALESCE(
        o.payable_amount,
        o.actual_amount
          - COALESCE(o.membership_discount, 0)
          - COALESCE(o.wallet_claim, 0)
          + COALESCE(o.delivery_charge, 0)
      ) AS payable_amount,

      o.item_id,
      o.quantity,
      o.unit_price,

      -- Product names and item totals
      COALESCE(items.items, '[]'::json) AS items,

      o.warehouse_id,
      o.hubcode,
      o.status,
      o.payment_status,
      o.tracking_number,
      o.courier_name,
      o.created_at,
      o.delivery_method,
      ul.username,

      COALESCE(
        NULLIF(TRIM(ua.phone), ''),
        NULLIF(TRIM(ul.mobile_no), '')
      ) AS customer_phone,

      ui.first_name,
      ui.last_name,
      ui.email AS customer_email,

      COALESCE(
        NULLIF(TRIM(ua.full_name), ''),
        NULLIF(TRIM(CONCAT_WS(' ', ui.first_name, ui.last_name)), ''),
        NULLIF(TRIM(ul.username), ''),
        CONCAT('Customer #', o.user_id)
      ) AS customer_name,

      COALESCE(
        NULLIF(TRIM(CONCAT_WS(
          ' ',
          NULLIF(TRIM(ua.address_line1), ''),
          NULLIF(TRIM(ua.address_line2), '')
        )), ''),
        NULLIF(TRIM(ui.address), '')
      ) AS customer_address,

      COALESCE(NULLIF(TRIM(ua.city), ''), NULLIF(TRIM(ui.city), ''))
        AS customer_city,

      COALESCE(NULLIF(TRIM(ua.state), ''), NULLIF(TRIM(ui.state), ''))
        AS customer_state,

      COALESCE(NULLIF(TRIM(ua.postal_code), ''), NULLIF(TRIM(ui.pincode), ''))
        AS customer_pincode,

      ua.country AS customer_country

    FROM public.orders o

    LEFT JOIN public.user_login ul
      ON CAST(o.user_id AS VARCHAR) = CAST(ul.user_id AS VARCHAR)

    LEFT JOIN public.user_info ui
      ON CAST(o.user_id AS VARCHAR) = CAST(ui.user_id AS VARCHAR)

    LEFT JOIN public.user_address ua
      ON ua.id = o.address_id
     AND CAST(ua.user_id AS VARCHAR) = CAST(o.user_id AS VARCHAR)

    LEFT JOIN LATERAL (
      SELECT json_agg(
        json_build_object(
          'product_id', oi.item_id,
          'product_name', p.name,
          'quantity', oi.quantity,
          'unit_price', oi.unit_price,
          'price', oi.unit_price,
          'subtotal', oi.quantity * oi.unit_price
        )
        ORDER BY oi.item_position
      ) AS items
      FROM unnest(o.item_id, o.quantity, o.unit_price)
        WITH ORDINALITY
        AS oi(item_id, quantity, unit_price, item_position)
      LEFT JOIN public.lkp_products p
        ON p.id = oi.item_id
    ) items ON TRUE

    ORDER BY o.id DESC
  `);

  return result.rows;
};

/* --------------------------------
   GET ADMIN ORDER BY ID
-------------------------------- */

const getAdminOrderById = async (id) => {
  const orderResult = await pool.query(
    `
    SELECT
      o.*,

      -- CUSTOMER NAME
      COALESCE(
        NULLIF(TRIM(ua.full_name), ''),
        NULLIF(
          TRIM(CONCAT_WS(' ', ui.first_name, ui.last_name)),
          ''
        ),
        NULLIF(TRIM(ul.username), ''),
        CONCAT('Customer #', o.user_id)
      ) AS customer_name,

      -- CUSTOMER CONTACT
      COALESCE(
        NULLIF(TRIM(ua.phone), ''),
        NULLIF(TRIM(ul.mobile_no), '')
      ) AS customer_phone,

      ui.email AS customer_email,

      -- DELIVERY ADDRESS LINKED TO THIS ORDER
      COALESCE(
        NULLIF(
          TRIM(CONCAT_WS(
            ' ',
            NULLIF(TRIM(ua.address_line1), ''),
            NULLIF(TRIM(ua.address_line2), '')
          )),
          ''
        ),
        NULLIF(TRIM(ui.address), '')
      ) AS address,

      ua.address_line1,
      ua.address_line2,
      ua.full_name AS delivery_name,
      ua.phone AS delivery_phone,
      ua.address_type,
      ua.country,

      COALESCE(
        NULLIF(TRIM(ua.city), ''),
        NULLIF(TRIM(ui.city), '')
      ) AS city,

      COALESCE(
        NULLIF(TRIM(ua.state), ''),
        NULLIF(TRIM(ui.state), '')
      ) AS state,

      COALESCE(
        NULLIF(TRIM(ua.postal_code), ''),
        NULLIF(TRIM(ui.pincode), '')
      ) AS pincode

    FROM public.orders o

    LEFT JOIN public.user_login ul
      ON CAST(o.user_id AS VARCHAR) = CAST(ul.user_id AS VARCHAR)

    LEFT JOIN public.user_info ui
      ON CAST(o.user_id AS VARCHAR) = CAST(ui.user_id AS VARCHAR)

    LEFT JOIN public.user_address ua
      ON ua.id = o.address_id
     AND CAST(ua.user_id AS VARCHAR) = CAST(o.user_id AS VARCHAR)

    WHERE o.id = $1::integer
    `,
    [Number(id)],
  );

  if (orderResult.rowCount === 0) {
    return null;
  }

  const order = orderResult.rows[0];

  // GET ORDER ITEMS
  const itemsResult = await pool.query(
    `
    SELECT
      oi.item_position::integer AS id,
      oi.item_id AS product_id,
      p.name AS product_name,
      oi.quantity,
      oi.unit_price,
      (oi.quantity * oi.unit_price) AS subtotal

    FROM public.orders o
    CROSS JOIN LATERAL
      unnest(o.item_id, o.quantity, o.unit_price)
      WITH ORDINALITY AS oi(item_id, quantity, unit_price, item_position)
    JOIN public.lkp_products p
      ON p.id = oi.item_id

    WHERE o.id = $1::integer


    ORDER BY oi.item_position
    `,
    [Number(id)],
  );

  return {
    ...order,
    items: itemsResult.rows,
  };
};

// const getAdminOrderById = async (id) => {
//   const orderResult = await pool.query(
//     `
//     SELECT
//       o.*,

//       COALESCE(
//         NULLIF(
//           TRIM(
//             CONCAT(
//               COALESCE(ui.first_name, ''),
//               ' ',
//               COALESCE(ui.last_name, '')
//             )
//           ),
//           ''
//         ),
//         ul.username
//       ) AS customer_name,

//       ul.mobile_no AS customer_phone,
//       ui.email AS customer_email,
//       ui.address,
//       ui.city,
//       ui.state,
//       ui.pincode

//     FROM orders o

//     LEFT JOIN user_login ul
//       ON o.user_id = ul.user_id

//     LEFT JOIN user_info ui
//       ON o.user_id = ui.user_id

//     WHERE o.id = $1::integer
//     `,
//     [Number(id)],
//   );

//   if (orderResult.rowCount === 0) {
//     return null;
//   }

//   const order = orderResult.rows[0];

//   // --------------------------------
//   // GET ORDER ITEMS
//   // --------------------------------

//   const itemsResult = await pool.query(
//     `
//     SELECT
//       item.item_index AS id,
//       item.item_id AS product_id,
//       p.name AS product_name,
//       item.quantity,
//       item.unit_price,
//       (item.quantity * item.unit_price) AS subtotal

//     FROM orders o
//     CROSS JOIN LATERAL unnest(o.item_id, o.quantity, o.unit_price)
//       WITH ORDINALITY AS item(item_id, quantity, unit_price, item_index)
//     JOIN public.lkp_products p
//       ON p.id = item.item_id

//     WHERE o.id = $1::integer

//     ORDER BY item.item_index
//     `,
//     [Number(id)],
//   );

//   return {
//     ...order,
//     items: itemsResult.rows,
//   };
// };

/* --------------------------------
   UPDATE ADMIN ORDER
-------------------------------- */

const updateAdminOrder = async (
  id,
  { status, payment_status, warehouse_id, tracking_number, courier_name },
) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET
      status = COALESCE($1, status),
      payment_status = COALESCE($2, payment_status),
      warehouse_id = COALESCE($3, warehouse_id),
      tracking_number = COALESCE($4, tracking_number),
      courier_name = COALESCE($5, courier_name)

    WHERE id = $6::integer

    RETURNING *
    `,
    [
      status ?? null,
      payment_status ?? null,

      warehouse_id === undefined || warehouse_id === null
        ? null
        : Number(warehouse_id),

      tracking_number ?? null,
      courier_name ?? null,

      Number(id),
    ],
  );

  return result.rows[0] || null;
};

/* --------------------------------
   DELETE ADMIN ORDER
-------------------------------- */

const deleteAdminOrder = async (id) => {
  void id;
  throw new Error(
    "Admin order deletion is unavailable because orders do not record whether inventory was deducted",
  );
};

/* --------------------------------
   DELETE ALL ADMIN ORDERS
-------------------------------- */

const deleteAllAdminOrders = async () => {
  throw new Error(
    "Bulk admin order deletion is unavailable because orders do not record whether inventory was deducted",
  );
};

/* --------------------------------
   VERIFY / ACCEPT ADMIN ORDER
-------------------------------- */

// const verifyAdminOrder = async (
//   id,
//   { status = "PROCESSING", delivery_method },
// ) => {
//   const result = await pool.query(
//     `
//     UPDATE orders
//     SET
//       status = $1,
//        admin_verified = TRUE,
//        admin_accepted = TRUE,
//       delivery_method = $2
//     WHERE id = $3::integer
//     RETURNING *
//     `,
//     [status, delivery_method, Number(id)],
//   );

//   return result.rows[0] || null;
// };

const verifyAdminOrder = async (
  id,
  { status = "PROCESSING", delivery_method },
) => {
  const result = await pool.query(
    `
    UPDATE public.orders
    SET
      status = $1,
      admin_verified = TRUE,
      admin_accepted = TRUE,
      delivery_method = $2
    WHERE id = $3::integer
      AND COALESCE(admin_verified, FALSE) = FALSE
      AND tracking_number IS NULL
    RETURNING *
    `,
    [status, delivery_method, Number(id)],
  );

  return result.rows[0] || null;
};

/* --------------------------------
   UPDATE SHIPMENT DETAILS
-------------------------------- */

const updateShipmentDetails = async (id, { tracking_number, courier_name }) => {
  const result = await pool.query(
    `
    UPDATE orders
    SET
      tracking_number = $1,
      courier_name = $2
    WHERE id = $3
    RETURNING *
    `,
    [tracking_number ?? null, courier_name ?? null, Number(id)],
  );

  return result.rows[0];
};
/* --------------------------------
   SYNC SHIPROCKET CANCELLATION
-------------------------------- */

const updateShiprocketCancellation = async (id) => {
  const result = await pool.query(
    `
    UPDATE public.orders
    SET status = 'CANCELLED'
    WHERE id = $1::integer
      AND UPPER(
        REPLACE(
          REPLACE(TRIM(COALESCE(delivery_method, '')), ' ', '_'),
          '-',
          '_'
        )
      ) IN ('MANAGANUGA', 'MANA_GANUGA')
      AND UPPER(TRIM(COALESCE(status, ''))) NOT IN (
        'DELIVERED',
        'RETURNED',
        'REFUNDED'
      )
    RETURNING id, status, delivery_method
    `,
    [Number(id)],
  );

  return result.rows[0] || null;
};

// =====================================================
// AUTOMATIC 3D OUTER BOX PACKING
// All dimensions are in centimetres.
// =====================================================

const getPackageOrientations = (length, breadth, height) => {
  const orientations = [
    [length, breadth, height],
    [length, height, breadth],
    [breadth, length, height],
    [breadth, height, length],
    [height, length, breadth],
    [height, breadth, length],
  ];

  // Remove duplicate orientations.
  return [
    ...new Map(
      orientations.map((dimensions) => [dimensions.join("x"), dimensions]),
    ).values(),
  ];
};

const boxesOverlap = (a, b) => {
  const epsilon = 0.000001;

  return (
    a.x < b.x + b.length - epsilon &&
    a.x + a.length > b.x + epsilon &&
    a.y < b.y + b.breadth - epsilon &&
    a.y + a.breadth > b.y + epsilon &&
    a.z < b.z + b.height - epsilon &&
    a.z + a.height > b.z + epsilon
  );
};

const calculateOuterBoxDimensions = (packages) => {
  if (!Array.isArray(packages) || packages.length === 0) {
    throw new Error("At least one package is required for 3D packing.");
  }

  const normalizedPackages = packages.map((pkg, index) => {
    const length = Number(pkg.length);
    const breadth = Number(pkg.breadth);
    const height = Number(pkg.height);

    if (
      !Number.isFinite(length) ||
      !Number.isFinite(breadth) ||
      !Number.isFinite(height) ||
      length <= 0 ||
      breadth <= 0 ||
      height <= 0
    ) {
      throw new Error(`Invalid dimensions for package ${index + 1}.`);
    }

    return {
      length,
      breadth,
      height,
      volume: length * breadth * height,
    };
  });

  // Try different package ordering strategies.
  const sortStrategies = [
    (a, b) => b.volume - a.volume,

    (a, b) =>
      Math.max(b.length, b.breadth, b.height) -
      Math.max(a.length, a.breadth, a.height),

    (a, b) => b.length * b.breadth - a.length * a.breadth,
  ];

  const arrangements = [];

  for (const sortPackages of sortStrategies) {
    const orderedPackages = [...normalizedPackages].sort(sortPackages);
    const placed = [];

    for (const pkg of orderedPackages) {
      const xPositions = new Set([0]);
      const yPositions = new Set([0]);
      const zPositions = new Set([0]);

      // Generate candidate positions from existing package edges.
      for (const box of placed) {
        xPositions.add(box.x + box.length);
        yPositions.add(box.y + box.breadth);
        zPositions.add(box.z + box.height);
      }

      let bestPlacement = null;

      for (const [length, breadth, height] of getPackageOrientations(
        pkg.length,
        pkg.breadth,
        pkg.height,
      )) {
        for (const x of xPositions) {
          for (const y of yPositions) {
            for (const z of zPositions) {
              const candidate = {
                x,
                y,
                z,
                length,
                breadth,
                height,
              };

              const hasCollision = placed.some((box) =>
                boxesOverlap(candidate, box),
              );

              if (hasCollision) continue;

              const outerLength = Math.max(
                0,
                ...placed.map((box) => box.x + box.length),
                x + length,
              );

              const outerBreadth = Math.max(
                0,
                ...placed.map((box) => box.y + box.breadth),
                y + breadth,
              );

              const outerHeight = Math.max(
                0,
                ...placed.map((box) => box.z + box.height),
                z + height,
              );

              const volume = outerLength * outerBreadth * outerHeight;

              const surfaceArea =
                2 *
                (outerLength * outerBreadth +
                  outerLength * outerHeight +
                  outerBreadth * outerHeight);

              const score = [
                volume,
                surfaceArea,
                Math.max(outerLength, outerBreadth, outerHeight),
              ];

              const isBetter =
                !bestPlacement ||
                score[0] < bestPlacement.score[0] ||
                (score[0] === bestPlacement.score[0] &&
                  score[1] < bestPlacement.score[1]) ||
                (score[0] === bestPlacement.score[0] &&
                  score[1] === bestPlacement.score[1] &&
                  score[2] < bestPlacement.score[2]);

              if (isBetter) {
                bestPlacement = {
                  box: candidate,
                  score,
                };
              }
            }
          }
        }
      }

      if (!bestPlacement) {
        throw new Error(
          "Unable to arrange all selected packages using the current 3D packing strategy.",
        );
      }

      placed.push(bestPlacement.box);
    }

    const outerLength = Math.max(...placed.map((box) => box.x + box.length));

    const outerBreadth = Math.max(...placed.map((box) => box.y + box.breadth));

    const outerHeight = Math.max(...placed.map((box) => box.z + box.height));

    arrangements.push({
      length: outerLength,
      breadth: outerBreadth,
      height: outerHeight,
      volume: outerLength * outerBreadth * outerHeight,
    });
  }

  // Choose the smallest calculated outer volume.
  arrangements.sort((a, b) => a.volume - b.volume);

  return {
    length: arrangements[0].length,
    breadth: arrangements[0].breadth,
    height: arrangements[0].height,
    volume: arrangements[0].volume,
  };
};

// =====================================================
// SAVE ORDER PACKAGES
// One database row per order.
// =====================================================

const saveOrderPackages = async (orderId, packages) => {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // -----------------------------------------------
    // VALIDATE SELECTED PACKAGES
    // -----------------------------------------------

    if (!Array.isArray(packages) || packages.length === 0) {
      const error = new Error("At least one package is required.");
      error.statusCode = 400;
      throw error;
    }

    // -----------------------------------------------
    // GET AND LOCK ORDER
    // -----------------------------------------------

    const orderResult = await client.query(
      `
      SELECT id, order_id
      FROM public.orders
      WHERE id = $1::integer
      FOR UPDATE
      `,
      [Number(orderId)],
    );

    if (orderResult.rowCount === 0) {
      const error = new Error("Order not found.");
      error.statusCode = 404;
      throw error;
    }

    const actualOrderId = String(orderResult.rows[0].order_id);

    // -----------------------------------------------
    // VALIDATION HELPERS
    // -----------------------------------------------

    const optionalNumber = (value, fieldName) => {
      if (value === null || value === undefined || value === "") {
        return null;
      }

      const number = Number(value);

      if (!Number.isFinite(number) || number < 0) {
        const error = new Error(`Invalid ${fieldName}.`);
        error.statusCode = 400;
        throw error;
      }

      return number;
    };

    const requiredPositiveNumber = (value, fieldName) => {
      const number = optionalNumber(value, fieldName);

      if (number === null || number <= 0) {
        const error = new Error(`${fieldName} must be greater than zero.`);
        error.statusCode = 400;
        throw error;
      }

      return number;
    };

    const getPackageValue = (inputValue, masterValue) => {
      return inputValue !== undefined &&
        inputValue !== null &&
        inputValue !== ""
        ? inputValue
        : masterValue;
    };

    const roundTo = (value, decimals = 3) =>
      Number(Number(value).toFixed(decimals));

    // -----------------------------------------------
    // PACKAGE ARRAYS
    // Each index corresponds to the same pckg_id.
    // -----------------------------------------------

    const packageIds = [];
    const packageNames = [];
    const packageTypes = [];

    const lengths = [];
    const breadths = [];
    const heights = [];

    const emptyWeights = [];
    const maxWeights = [];
    const capacities = [];
    const capacityUnits = [];
    const grossPackageWeights = [];

    // -----------------------------------------------
    // COMBINED ACTUAL WEIGHT
    // -----------------------------------------------

    let totalDeadWeight = 0;

    // -----------------------------------------------
    // PROCESS EACH SELECTED PACKAGE
    // -----------------------------------------------

    for (let index = 0; index < packages.length; index++) {
      const pkg = packages[index];

      const packageId = Number(pkg.pckgId);

      if (!Number.isInteger(packageId) || packageId <= 0) {
        const error = new Error(
          `Invalid package selection for Package ${index + 1}.`,
        );
        error.statusCode = 400;
        throw error;
      }

      // Get active package master details.
      const masterResult = await client.query(
        `
        SELECT
          pckg_id,
          pckg_name,
          pckg_type,
          capacity_value,
          capacity_unit,
          pck_weight,
          pck_length,
          pck_breadth,
          pck_height,
          max_weight,
          gross_pckg_wt
        FROM public.package_details
        WHERE pckg_id = $1::bigint
          AND is_active = 1
        LIMIT 1
        `,
        [packageId],
      );

      if (masterResult.rowCount === 0) {
        const error = new Error(
          `Selected package ${packageId} is unavailable.`,
        );
        error.statusCode = 400;
        throw error;
      }

      const master = masterResult.rows[0];

      // ---------------------------------------------
      // PACKAGE ID, NAME AND TYPE
      // ---------------------------------------------

      packageIds.push(packageId);

      packageNames.push(String(pkg.packageName ?? master.pckg_name ?? ""));

      packageTypes.push(String(pkg.packageType ?? master.pckg_type ?? ""));

      // ---------------------------------------------
      // CAPACITY
      // ---------------------------------------------

      const capacityValue = requiredPositiveNumber(
        master.capacity_value,
        `capacity for Package ${index + 1}`,
      );

      const capacityUnit = String(master.capacity_unit || "").trim();

      if (!capacityUnit) {
        const error = new Error(
          `Capacity unit is missing for Package ${index + 1}.`,
        );
        error.statusCode = 400;
        throw error;
      }

      capacities.push(roundTo(capacityValue));
      capacityUnits.push(capacityUnit);

      // ---------------------------------------------
      // GROSS PACKAGE WEIGHT
      // Must represent the filled individual package.
      // ---------------------------------------------

      const grossPckgWt = roundTo(
        requiredPositiveNumber(
          getPackageValue(pkg.grossPckgWt, master.gross_pckg_wt),
          `gross package weight for Package ${index + 1}`,
        ),
      );

      grossPackageWeights.push(grossPckgWt);

      // Add actual weight of each individual package.
      totalDeadWeight += grossPckgWt;

      // ---------------------------------------------
      // INDIVIDUAL OUTER DIMENSIONS
      // These dimensions are used for 3D arrangement.
      // ---------------------------------------------

      const length = roundTo(
        requiredPositiveNumber(
          getPackageValue(pkg.length, master.pck_length),
          `outer length for Package ${index + 1}`,
        ),
        2,
      );

      const breadth = roundTo(
        requiredPositiveNumber(
          getPackageValue(pkg.breadth, master.pck_breadth),
          `outer breadth for Package ${index + 1}`,
        ),
        2,
      );

      const height = roundTo(
        requiredPositiveNumber(
          getPackageValue(pkg.height, master.pck_height),
          `outer height for Package ${index + 1}`,
        ),
        2,
      );

      lengths.push(length);
      breadths.push(breadth);
      heights.push(height);
      // ---------------------------------------------
      // EMPTY PACKAGE WEIGHT
      // ---------------------------------------------

      emptyWeights.push(
        optionalNumber(
          getPackageValue(pkg.emptyWeight, master.pck_weight),
          `empty package weight for Package ${index + 1}`,
        ),
      );

      // ---------------------------------------------
      // MAXIMUM PACKAGE WEIGHT
      // ---------------------------------------------

      maxWeights.push(
        optionalNumber(
          getPackageValue(pkg.maxWeight, master.max_weight),
          `maximum weight for Package ${index + 1}`,
        ),
      );
    }

    // -----------------------------------------------
    // CALCULATE ONE COMMON OUTER SHIPPING BOX
    // -----------------------------------------------

    const outerBox = calculateOuterBoxDimensions(
      lengths.map((length, index) => ({
        length,
        breadth: breadths[index],
        height: heights[index],
      })),
    );

    // -----------------------------------------------
    // COMBINED ACTUAL WEIGHT
    // -----------------------------------------------

    totalDeadWeight = roundTo(totalDeadWeight);

    // -----------------------------------------------
    // OUTER BOX VOLUMETRIC WEIGHT
    // Formula: L x B x H / 5000
    // Dimensions are in centimetres.
    // -----------------------------------------------

    const totalVolumetricWeight = roundTo(
      (outerBox.length * outerBox.breadth * outerBox.height) / 5000,
    );

    // -----------------------------------------------
    // CHARGEABLE WEIGHT
    // -----------------------------------------------

    const totalChargeableWeight = roundTo(
      Math.max(totalDeadWeight, totalVolumetricWeight),
    );

    // -----------------------------------------------
    // DELETE PREVIOUS SAVED PACKAGE ROWS
    // -----------------------------------------------

    await client.query(
      `
      DELETE FROM public.order_packages
      WHERE order_id = $1
      `,
      [actualOrderId],
    );

    // -----------------------------------------------
    // INSERT ALL PACKAGES INTO ONE ROW
    // -----------------------------------------------

    const insertResult = await client.query(
      `
      INSERT INTO public.order_packages (
        order_id,
        pckg_id,
        dead_wt,
        vol_wt,
        chargeable_wt,
        length,
        breadth,
        height,
        packing_status,
        pckg_name,
        pckg_type,
        pck_weight,
        max_weight,
        capacity_value,
        capacity_unit,
        gross_pckg_wt
      )
      VALUES (
        $1,
        $2::bigint[],
        $3::numeric,
        $4::numeric,
        $5::numeric,
        $6::numeric[],
        $7::numeric[],
        $8::numeric[],
        'CONFIRMED',
        $9,
        $10,
        $11::numeric[],
        $12::numeric[],
        $13::numeric[],
        $14::text[],
        $15::numeric[]
      )
      RETURNING *
      `,
      [
        actualOrderId,
        packageIds,
        totalDeadWeight,
        totalVolumetricWeight,
        totalChargeableWeight,
        lengths,
        breadths,
        heights,

        // Preserve duplicate names and types.
        packageNames.join(", "),
        packageTypes.join(", "),

        emptyWeights,
        maxWeights,

        capacities,
        capacityUnits,
        grossPackageWeights,
      ],
    );

    // -----------------------------------------------
    // COMMIT TRANSACTION
    // -----------------------------------------------

    await client.query("COMMIT");

    return {
      order_id: actualOrderId,
      package_count: packages.length,
      database_rows: 1,

      // Combined weight calculations.
      dead_wt: totalDeadWeight,
      vol_wt: totalVolumetricWeight,
      chargeable_wt: totalChargeableWeight,

      // Calculated common outer shipping box.
      outer_box: outerBox,

      packages: insertResult.rows,
    };
  } catch (error) {
    await client.query("ROLLBACK");
    void logException(error);
    throw error;
  } finally {
    client.release();
  }
};



/* --------------------------------
   EXPORTS
-------------------------------- */

module.exports = {
  // createAdminOrder,
  getAdminOrders,
  getAdminOrderById,
  updateAdminOrder,
  deleteAdminOrder,
  deleteAllAdminOrders,
  verifyAdminOrder,
  updateShipmentDetails,
  updateShiprocketCancellation,
  saveOrderPackages,
  calculateOuterBoxDimensions,
};
