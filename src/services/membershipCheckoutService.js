const pool = require("../../db");

const calculateMembershipBenefits = async (
  userId,
  cartItems,
) => {

  // Load active membership
  const membershipResult = await pool.query(
    `
    SELECT *
    FROM user_memberships
    WHERE user_id = $1
      AND status = 'ACTIVE'
    ORDER BY id DESC
    LIMIT 1
    `,
    [userId]
  );

  const membership = membershipResult.rows[0];

  if (!membership) {
    return null;
  }

  // Calculate current cart subtotal and litres
  let subtotal = 0;
  let totalLitres = 0;

  for (const item of cartItems) {
    subtotal +=
      Number(item.price) * Number(item.quantity);

    totalLitres +=
      Number(item.quantity);
  }

  // --------------------------------------------------
  // PAYMENT SCREEN USAGE
  // Count litres from previous non-refunded orders
  // after the current membership started.
  // --------------------------------------------------

  const previousOrdersResult = await pool.query(
    `
    SELECT
      COALESCE(
        SUM(oi.quantity * COALESCE(p.weight, 0)),
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
      userId,
      membership.start_date,
    ]
  );

  const previousOrderLitres =
    Number(
      previousOrdersResult.rows[0]?.previous_order_litres || 0
    );

  const paymentUsageLitres =
    Number(membership.used_litres || 0) +
    previousOrderLitres;

  const monthlyLimit =
    Number(membership.monthly_limit_litres || 0);

  const paymentRemainingLitres =
    Math.max(
      monthlyLimit - paymentUsageLitres,
      0
    );

  // --------------------------------------------------
  // EXISTING MEMBERSHIP DISCOUNT CALCULATION
  // --------------------------------------------------

  const usedLitres =
    Number(membership.used_litres);

  const remainingLitres =
    Math.max(
      monthlyLimit - usedLitres,
      0
    );

  const fullDiscountLitres =
    Math.min(
      totalLitres,
      remainingLitres
    );

  const halfDiscountLitres =
    Math.max(
      totalLitres - remainingLitres,
      0
    );

  const discountPercent =
    Number(membership.discount_percent);

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

    remainingFullLitres -= fullQty;

    const halfQty =
      quantity - fullQty;

    membershipDiscount +=
      halfQty *
      price *
      (halfDiscountPercent / 100);
  }

  // Monthly wallet claim
  const monthlyClaim =
    Number(membership.monthly_claim);

  const monthlyClaimUsed =
    Number(membership.monthly_claim_used);

  const remainingWalletClaim =
    Math.max(
      monthlyClaim - monthlyClaimUsed,
      0
    );

  const walletClaim =
    Math.min(
      remainingWalletClaim,
      subtotal - membershipDiscount
    );

  // Members always get free delivery
  const deliveryCharge = 0;

  const payableAmount =
    subtotal -
    membershipDiscount -
    walletClaim +
    deliveryCharge;

  return {
    membership,

    subtotal,
    totalLitres,

    // Existing membership values
    usedLitres,
    remainingLitres,

    // Payment-screen-only values
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