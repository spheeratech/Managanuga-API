const pool = require("../../db");

/**
 * Resolve any supported user identifier into both:
 * - publicUserId  -> user_login.user_id
 * - internalUserId -> user_login.id
 *
 * Supported inputs:
 * - MGU26092503
 * - "19", "20", "23" (public IDs that happen to be numeric)
 * - 170 (legacy internal user_login.id)
 */
const resolveUserIdentifiers = async (userId, client = pool) => {
  if (
    userId === null ||
    userId === undefined ||
    userId === ""
  ) {
    throw new Error("User ID is required");
  }

  const value = String(userId).trim();

  // First: treat the value as the PUBLIC user_id.
  // This is important because some older public IDs are numeric
  // such as "19", "20", "23".
  const publicResult = await client.query(
    `
    SELECT
      id,
      user_id
    FROM user_login
    WHERE user_id = $1
      AND is_active = true
    LIMIT 1
    `,
    [value]
  );

  if (publicResult.rows.length > 0) {
    return {
      publicUserId: publicResult.rows[0].user_id,
      internalUserId: publicResult.rows[0].id,
    };
  }

  // Second: support legacy/internal numeric user_login.id.
  if (/^\d+$/.test(value)) {
    const internalResult = await client.query(
      `
      SELECT
        id,
        user_id
      FROM user_login
      WHERE id = $1
        AND is_active = true
      LIMIT 1
      `,
      [Number(value)]
    );

    if (internalResult.rows.length > 0) {
      return {
        publicUserId: internalResult.rows[0].user_id,
        internalUserId: internalResult.rows[0].id,
      };
    }
  }

  throw new Error(`User not found: ${userId}`);
};


const calculateMembershipBenefits = async (
  userId,
  cartItems,
) => {

  /*
   * IMPORTANT
   *
   * user_memberships.user_id now stores:
   *
   *     user_login.user_id
   *
   * while old orders.entity_id still stores:
   *
   *     user_login.id
   *
   * Therefore we resolve BOTH identifiers here.
   */
  const {
    publicUserId,
    internalUserId,
  } = await resolveUserIdentifiers(userId);


  // ============================================================
  // LOAD ACTIVE MEMBERSHIP
  // ============================================================

  const membershipResult = await pool.query(
    `
    SELECT *
    FROM user_memberships
    WHERE user_id = $1
      AND status = 'ACTIVE'
    ORDER BY id DESC
    LIMIT 1
    `,
    [publicUserId]
  );

  const membership = membershipResult.rows[0];

  if (!membership) {
    return null;
  }


  // ============================================================
  // CALCULATE CURRENT CART SUBTOTAL + LITRES
  // ============================================================

  let subtotal = 0;
  let totalLitres = 0;

  for (const item of cartItems) {

    subtotal +=
      Number(item.price) *
      Number(item.quantity);

    totalLitres +=
      Number(item.quantity);
  }


  // ============================================================
  // PAYMENT SCREEN USAGE
  //
  // Existing orders still use:
  //
  // orders.entity_id = user_login.id
  //
  // So use INTERNAL user ID here.
  // ============================================================

  const previousOrdersResult = await pool.query(
    `
    SELECT
      COALESCE(
        SUM(
          oi.quantity *
          COALESCE(p.weight, 0)
        ),
        0
      ) AS previous_order_litres

    FROM orders o

    INNER JOIN order_items oi
      ON oi.order_id = o.id

    INNER JOIN products p
      ON p.id = oi.item_id

    WHERE o.entity_type = 'USER'
      AND o.entity_id = $1

      AND o.status IN (
        'PLACED',
        'PROCESSING',
        'PACKED',
        'DELIVERED'
      )

      AND o.created_at >= $2
    `,
    [
      internalUserId,
      membership.start_date,
    ]
  );

  const previousOrderLitres =
    Number(
      previousOrdersResult.rows[0]
        ?.previous_order_litres || 0
    );


  const paymentUsageLitres =
    Number(membership.used_litres || 0) +
    previousOrderLitres;


  const monthlyLimit =
    Number(
      membership.monthly_limit_litres || 0
    );


  const paymentRemainingLitres =
    Math.max(
      monthlyLimit -
      paymentUsageLitres,
      0
    );


  // ============================================================
  // MEMBERSHIP DISCOUNT CALCULATION
  // ============================================================

  const usedLitres =
    Number(
      membership.used_litres || 0
    );


  const remainingLitres =
    Math.max(
      monthlyLimit -
      usedLitres,
      0
    );


  const fullDiscountLitres =
    Math.min(
      totalLitres,
      remainingLitres
    );


  const halfDiscountLitres =
    Math.max(
      totalLitres -
      remainingLitres,
      0
    );


  const discountPercent =
    Number(
      membership.discount_percent || 0
    );


  const halfDiscountPercent =
    discountPercent / 2;


  let membershipDiscount = 0;


  let remainingFullLitres =
    fullDiscountLitres;


  for (const item of cartItems) {

    const quantity =
      Number(item.quantity);

    const price =
      Number(item.price);


    const fullQty =
      Math.min(
        quantity,
        remainingFullLitres
      );


    membershipDiscount +=
      fullQty *
      price *
      (discountPercent / 100);


    remainingFullLitres -=
      fullQty;


    const halfQty =
      quantity -
      fullQty;


    membershipDiscount +=
      halfQty *
      price *
      (halfDiscountPercent / 100);
  }


  // ============================================================
  // MONTHLY WALLET CLAIM
  // ============================================================

  const monthlyClaim =
    Number(
      membership.monthly_claim || 0
    );


  const monthlyClaimUsed =
    Number(
      membership.monthly_claim_used || 0
    );


  const remainingWalletClaim =
    Math.max(
      monthlyClaim -
      monthlyClaimUsed,
      0
    );


  const walletClaim =
    Math.min(
      remainingWalletClaim,
      Math.max(
        subtotal -
        membershipDiscount,
        0
      )
    );


  // ============================================================
  // MEMBERS GET FREE DELIVERY
  // ============================================================

  const deliveryCharge = 0;


  // ============================================================
  // FINAL PAYABLE AMOUNT
  // ============================================================

  const payableAmount =
    subtotal -
    membershipDiscount -
    walletClaim +
    deliveryCharge;


  // ============================================================
  // RETURN
  // ============================================================

  return {
    membership,

    subtotal,

    totalLitres,

    usedLitres,

    remainingLitres,

    paymentUsageLitres,

    paymentRemainingLitres,

    fullDiscountLitres,

    halfDiscountLitres,

    membershipDiscount,

    walletClaim,

    deliveryCharge,

    payableAmount,
  };
};


module.exports = {
  calculateMembershipBenefits,
};