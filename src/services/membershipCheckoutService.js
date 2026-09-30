const pool = require("../../db");

const calculateMembershipBenefits = async (
  userId,
  cartItems,
) => {

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
    [userId]
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
  // ============================================================

  const previousOrdersResult = await pool.query(
    `
    SELECT
      COALESCE(
        SUM(
          item_data.quantity *
          COALESCE(p.weight, 0)
        ),
        0
      ) AS previous_order_litres

    FROM orders o

    CROSS JOIN LATERAL unnest(
      o.item_id,
      o.quantity,
      o.unit_price
    ) AS item_data(
      item_id,
      quantity,
      unit_price
    )

    INNER JOIN products p
      ON p.id = item_data.item_id

    WHERE o.user_id = $1

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