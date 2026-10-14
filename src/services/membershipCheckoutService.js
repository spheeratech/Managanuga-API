const pool = require("../../db");

const roundMoney = (value) =>
  Math.round((Number(value) + Number.EPSILON) * 100) / 100;

const getDeliveryRule = async (cartCount) => {
  const deliveryRuleResult = await pool.query(
    `
    SELECT
      delivery_charges,
      expected_delivery_days
    FROM delivery_charges
    WHERE is_active = 1
      AND delivery_cart_count <= $1
    ORDER BY delivery_cart_count DESC, id DESC
    LIMIT 1
    `,
    [cartCount]
  );

  const deliveryRule = deliveryRuleResult.rows[0];
  if (!deliveryRule) {
    throw new Error(
      `Delivery charge configuration not found for cart count ${cartCount}`
    );
  }

  return deliveryRule;
};

const calculateMembershipBenefits = async (
  userId,
  cartItems,
  selectedMembershipId = undefined,
) => {

  // ============================================================
  // LOAD ACTIVE MEMBERSHIP
  // ============================================================

  if (selectedMembershipId === null) {
    return null;
  }

  const membershipResult = await pool.query(
    `
    SELECT *
    FROM user_memberships
    WHERE user_id = $1
      AND status = 'ACTIVE'
      AND is_active = 1
      AND ($2::integer IS NULL OR id = $2::integer)
    ORDER BY id DESC
    LIMIT 1
    `,
    [userId, selectedMembershipId ?? null]
  );

  const membership = membershipResult.rows[0];

  if (!membership) {
    if (selectedMembershipId !== undefined) {
      throw new Error(
        "The selected membership is not active for this customer"
      );
    }
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
      Number(item.quantity) *
      Number(item.weight || 0);
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

    INNER JOIN lkp_products p
      ON p.id = item_data.item_id

    WHERE o.user_id = $1
      AND o.payment_status = 'PAID'

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
      membership.last_reset_date || membership.start_date,
    ]
  );

  const previousOrderLitres =
    Number(
      previousOrdersResult.rows[0]
        ?.previous_order_litres || 0
    );


  const paymentUsageLitres =
    Math.max(
      Number(membership.used_litres || 0),
      previousOrderLitres
    );


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

  const remainingLitres =
    Math.max(
      monthlyLimit -
      paymentUsageLitres,
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

    const weight =
      Number(item.weight || 0);

    const itemLitres = quantity * weight;
    const fullLitres = Math.min(
      itemLitres,
      remainingFullLitres
    );
    const fullQuantity =
      weight > 0
        ? fullLitres / weight
        : 0;


    membershipDiscount +=
      fullQuantity *
      price *
      (discountPercent / 100);


    remainingFullLitres -= fullLitres;


    const halfQty =
      quantity -
      fullQuantity;


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


  const deliveryRule = await getDeliveryRule(cartItems.length);
  const deliveryCharge = Number(deliveryRule.delivery_charges);


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

    usedLitres: paymentUsageLitres,

    remainingLitres,

    paymentUsageLitres,

    paymentRemainingLitres,

    fullDiscountLitres,

    halfDiscountLitres,

    membershipDiscount,

    walletClaim,

    deliveryCharge,
    deliverySavings: 0,
    expectedDeliveryDays:
      deliveryRule.expected_delivery_days,

    payableAmount,
  };
};

const calculateCheckoutTotals = async (
  userId,
  cartItems,
  selectedMembershipId = undefined
) => {
  const membershipBenefits = await calculateMembershipBenefits(
    userId,
    cartItems,
    selectedMembershipId
  );

  let subtotal = 0;
  let totalLitres = 0;

  for (const item of cartItems) {
    const quantity = Number(item.quantity);
    const price = Number(item.price);
    const weight = Number(item.weight || 0);
    const stock = Number(item.stock);

    if (
      !Number.isFinite(quantity) ||
      quantity <= 0 ||
      !Number.isFinite(price) ||
      price < 0 ||
      !Number.isFinite(weight) ||
      weight < 0 ||
      (Number.isFinite(stock) && quantity > stock)
    ) {
      throw new Error("Invalid product quantity, price, weight, or stock");
    }

    subtotal += quantity * price;
    totalLitres += quantity * weight;
  }

  let deliveryCharge = membershipBenefits?.deliveryCharge;
  let deliverySavings = membershipBenefits?.deliverySavings;
  let expectedDeliveryDays =
    membershipBenefits?.expectedDeliveryDays;

  if (deliveryCharge === undefined) {
    const deliveryRule = await getDeliveryRule(cartItems.length);
    deliveryCharge = Number(deliveryRule.delivery_charges);
    deliverySavings = 0;
    expectedDeliveryDays = deliveryRule.expected_delivery_days;
  }

  const membershipDiscount = Number(
    membershipBenefits?.membershipDiscount || 0
  );
  const walletClaim = Number(membershipBenefits?.walletClaim || 0);
  const roundedSubtotal = roundMoney(subtotal);
  const roundedDiscount = roundMoney(membershipDiscount);
  const roundedClaim = roundMoney(walletClaim);
  const roundedDelivery = roundMoney(deliveryCharge);
  const payableAmount = roundMoney(
    roundedSubtotal -
    roundedDiscount -
    roundedClaim +
    roundedDelivery
  );

  if (!Number.isFinite(payableAmount) || payableAmount < 0) {
    throw new Error("Invalid checkout total");
  }

  return {
    membership: membershipBenefits?.membership || null,
    membershipBenefits,
    subtotal: roundedSubtotal,
    actualAmount: roundedSubtotal,
    totalLitres,
    membershipDiscount: roundedDiscount,
    walletClaim: roundedClaim,
    deliveryCharge: roundedDelivery,
    deliverySavings: roundMoney(deliverySavings),
    expectedDeliveryDays,
    payableAmount,
  };
};


module.exports = {
  calculateMembershipBenefits,
  calculateCheckoutTotals,
};