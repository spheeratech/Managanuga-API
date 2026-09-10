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
  // Calculate subtotal and total litres
let subtotal = 0;
let totalLitres = 0;

for (const item of cartItems) {

  subtotal +=
    Number(item.price) * Number(item.quantity);

  totalLitres +=
    Number(item.quantity);

}
// Membership usage
const usedLitres =
  Number(membership.used_litres);

const monthlyLimit =
  Number(membership.monthly_limit_litres);

const remainingLitres =
  Math.max(
    monthlyLimit - usedLitres,
    0
  );

// Full discount litres
const fullDiscountLitres =
  Math.min(
    totalLitres,
    remainingLitres
  );

// Half discount litres
const halfDiscountLitres =
  Math.max(
    totalLitres - remainingLitres,
    0
  );
  // Membership discount calculation
const discountPercent =
  Number(membership.discount_percent);

const halfDiscountPercent =
  discountPercent / 2;

let membershipDiscount = 0;

// Calculate discount item-wise
let remainingFullLitres =
  fullDiscountLitres;

for (const item of cartItems) {

  const quantity =
    Number(item.quantity);

  const price =
    Number(item.price);

  // Full discount litres
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

  // Remaining litres get half discount
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

// Wallet deduction cannot exceed subtotal after discount
const walletClaim =
  Math.min(
    remainingWalletClaim,
    subtotal - membershipDiscount
  );
  // Delivery charge
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

  usedLitres,

  remainingLitres,

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