const { logException } = require("../utils/exceptionLogger.js");
const Order = require("../models/Order");
const Payment = require("../models/Payment");
const Notification = require("../models/Notification");
const razorpayService = require("../services/razorpayService");
const Membership = require("../models/Membership");
const pool = require("../../db");
const { getRoleName } = require("../utils/userRoles");
// const xpressbeesService = require("../services/xpressbeesService");
const shiprocketService = require("../services/shiprocketService");
const Cart = require("../models/Cart");
const User = require("../models/User");
const Coupon = require("../models/Coupon");
const Wallet = require("../models/Wallet");
const {
  getPendingReferral,
} = require("../services/pendingCustomerReferralStore");

const { sendPushNotification } = require("../services/fcmService");

const {
  calculateCheckoutTotals,
  getUnitLitres,
} = require("../services/membershipCheckoutService");

const {
  processMembershipBenefit,
} = require("../services/membershipBenefitService");

const {
  sendOrderConfirmation,
  sendSubscriptionWhatsApp,
} = require("../services/whatsappService");

const {
  validateCustomerReferral,
  creditCustomerReferralRewardForMembership,
  redeemCustomerReferralWithClient,
} = require("../services/customerReferralService");

const roundMoney = (amount) =>
  Math.round((Number(amount) + Number.EPSILON) * 100) / 100;


const calculateSnapshotOrderLitres = (cartItems) => {
  if (!Array.isArray(cartItems) || cartItems.length === 0) {
    throw new Error("Checkout snapshot items are missing");
  }

  return cartItems.reduce((total, item) => {
    const quantity = Number(item.quantity);
    const weight = Number(item.weight);

    if (
      !Number.isFinite(quantity) ||
      quantity <= 0 ||
      !Number.isFinite(weight) ||
      weight <= 0
    ) {
      throw new Error("Invalid product quantity or weight in checkout snapshot");
    }

    return total + quantity * getUnitLitres(weight);
  }, 0);
};


const isRazorpayTestMode = () =>
  process.env.RAZORPAY_TEST_MODE === "true";




const applyCouponToCheckoutTotals = (checkoutTotals, couponPercentage) => {
  const subtotal = Number(
    checkoutTotals.actualAmount ?? checkoutTotals.subtotal ?? 0,
  );

  const originalMembershipDiscount = Number(
    checkoutTotals.membershipDiscount || 0,
  );

  const membershipBenefits = checkoutTotals.membershipBenefits;
  const isMembershipCheckout = Boolean(membershipBenefits?.membership);
  const membershipPlanPercentage = Number(
    membershipBenefits?.planDiscountPercentage ??
      membershipBenefits?.membership?.plan_discount_percentage ??
      membershipBenefits?.membership?.discount_percentage,
  );
  const normalizedCouponPercentage = Number(couponPercentage);

  if (
    !Number.isFinite(normalizedCouponPercentage) ||
    normalizedCouponPercentage < 0
  ) {
    throw new Error("Coupon percentage is invalid");
  }

  if (
    isMembershipCheckout &&
    (!Number.isFinite(membershipPlanPercentage) ||
      normalizedCouponPercentage <= membershipPlanPercentage)
  ) {
    const error = new Error("Coupon is invalid for this user.");
    error.code = "MEMBERSHIP_COUPON_NOT_ELIGIBLE";
    throw error;
  }

  const membershipDiscount = isMembershipCheckout
    ? 0
    : originalMembershipDiscount;
  const existingWalletClaim = Number(checkoutTotals.walletClaim || 0);
  const deliveryCharge = Number(checkoutTotals.deliveryCharge || 0);
  const deliveryDescription = checkoutTotals.deliveryDescription ?? null;

  // Non-members retain the existing post-membership calculation. For members,
  // the accepted coupon replaces the membership discount on the product total.
  const eligibleProductAmount = Math.max(
    0,
    roundMoney(subtotal - membershipDiscount),
  );

  const couponDiscount = Math.min(
    eligibleProductAmount,
    roundMoney((eligibleProductAmount * normalizedCouponPercentage) / 100),
  );

  const availableWalletClaim = isMembershipCheckout
    ? Number(membershipBenefits.remainingWalletClaim ?? existingWalletClaim)
    : existingWalletClaim;
  const walletClaim = isMembershipCheckout
    ? roundMoney(
        Math.min(
          Math.max(availableWalletClaim, 0),
          Math.max(eligibleProductAmount - couponDiscount, 0),
        ),
      )
    : existingWalletClaim;

  const discountedProductAmount = Math.max(
    0,
    roundMoney(eligibleProductAmount - couponDiscount - walletClaim),
  );

  const otherApplicableFees = roundMoney(
    Number(checkoutTotals.payableAmount || 0) -
      (Number(checkoutTotals.subtotal ?? subtotal) -
        originalMembershipDiscount -
        existingWalletClaim +
        deliveryCharge),
  );

  const payableAmount = roundMoney(
    discountedProductAmount + deliveryCharge + otherApplicableFees,
  );

  const adjustedMembershipBenefits = isMembershipCheckout
    ? {
        ...membershipBenefits,
        membershipDiscount,
        walletClaim,
        couponDiscount,
        payableAmount,
      }
    : membershipBenefits;

  return {
    couponDiscount,
    payableAmount,
    checkoutTotals: {
      ...checkoutTotals,
      membershipDiscount,
      walletClaim,
      couponDiscount,
      payableAmount,
      ...(isMembershipCheckout
        ? { membershipBenefits: adjustedMembershipBenefits }
        : {}),
    },
  };
};

/* =========================================================
   CREATE RAZORPAY ORDER
========================================================= */

const createOrder = async (req, res) => {
  try {
    console.log("CREATE ORDER HIT");
    console.log("BODY:", req.body);

const {
  order_id,
  user_id,
  paymentType,
  membershipPlanId,
  buyNow,
  productId,
  variantId,
  quantity,
  address_id,
  couponCode,
  referralCode,
  customerReferralId,
  referralBonus = 0,
} = req.body;

    const publicUserId = user_id;

    const requestedReferralBonus = roundMoney(Number(referralBonus));

    if (requestedReferralBonus > 0) {
      const referralWallet =
        await Wallet.getCustomerReferralWallet(publicUserId);

      const referralBalance = Number(referralWallet?.current_balance || 0);

      if (requestedReferralBonus > referralBalance) {
        return res.status(400).json({
          success: false,
          message: "Insufficient referral wallet balance",
        });
      }
    }

    if (
      !Number.isFinite(Number(referralBonus)) ||
      Number(referralBonus) < 0 ||
      requestedReferralBonus !== Number(referralBonus)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid referral wallet amount",
      });
    }

    if (!publicUserId) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const paymentTypeUpper = (paymentType || "ORDER").toUpperCase();
    if (paymentTypeUpper !== "MEMBERSHIP") {
      const addressResult = await pool.query(
        `
        SELECT 1
        FROM user_address
        WHERE id = $1
          AND user_id = $2
          AND is_active = 1
        LIMIT 1
        `,
        [address_id, publicUserId],
      );

      if (!addressResult.rows[0]) {
        return res.status(400).json({
          success: false,
          message: "Active delivery address does not belong to this user",
        });
      }
    }
let actualAmount = 0;
let payableAmount = 0;
let checkoutTotals = null;
let cartItems = [];
let membershipPlanSnapshot = null;

    /* =====================================================
       MEMBERSHIP PAYMENT
    ===================================================== */

    if (paymentTypeUpper === "MEMBERSHIP") {
      const planResult = await pool.query(
        `
            SELECT *
            FROM lkp_subscription_plans
            WHERE id = $1
          `,
        [membershipPlanId],
      );

      const plan = planResult.rows[0];

      if (!plan) {
        return res.status(404).json({
          success: false,
          message: "Membership plan not found",
        });
      }
actualAmount = Number(plan.plan_price);

payableAmount = Number(plan.plan_price);

membershipPlanSnapshot = {
  id: plan.id,
  plan_name: plan.plan_name ?? null,
  plan_price: Number(plan.plan_price),
  plan_discount: plan.plan_discount ?? null,
  wallet_bonus: Number(plan.wallet_bonus || 0),
  discount_percentage: Number(plan.discount_percentage || 0),
  monthly_claim: Number(plan.monthly_claim || 0),
};

    }

    /* =====================================================
       NORMAL PRODUCT ORDER
    ===================================================== */

if (paymentTypeUpper !== "MEMBERSHIP") {

      /* -----------------------------------------------
         BUY NOW
      ------------------------------------------------ */


if (buyNow && productId) {
  const selectedVariantId = Number(variantId);
  const buyNowQuantity = Number(quantity ?? 1);

  if (!Number.isInteger(selectedVariantId) || selectedVariantId <= 0) {
    return res.status(400).json({
      success: false,
      message: "A valid product variant is required",
    });
  }

  if (!Number.isInteger(buyNowQuantity) || buyNowQuantity <= 0) {
    return res.status(400).json({
      success: false,
      message: "Invalid product quantity",
    });
  }

  const productResult = await pool.query(
    `
    SELECT
      p.id,
      p.name,
      p.weight,
      pv.id AS variant_id,
      pv.size AS variant_size,
      pv.price,
      pv.stock
    FROM lkp_products p
    INNER JOIN product_variants pv
      ON pv.product_id = p.id
    WHERE p.id = $1
      AND pv.id = $2
      AND p.is_active = 1
      AND pv.is_active = 1
    LIMIT 1
    `,
    [productId, selectedVariantId],
  );

  if (productResult.rows.length === 0) {
    return res.status(404).json({
      success: false,
      message: "Selected product variant not found or inactive",
    });
  }

  const product = productResult.rows[0];

  if (Number(product.stock) < buyNowQuantity) {
    return res.status(400).json({
      success: false,
      message: "Insufficient stock for the selected variant",
    });
  }

  cartItems = [
    {
      cart_id: null,
      user_id: publicUserId,
      item_id: Number(product.id),
      product_id: Number(product.id),
      variant_id: Number(product.variant_id),
      variant_size: product.variant_size,
      product_name: product.name,
      price: Number(product.price),
      weight: Number(product.weight || 0),
      stock: Number(product.stock),
      quantity: buyNowQuantity,
      total_price: Number(product.price) * buyNowQuantity,
    },
  ];
} else {
  /* =================================================
     NORMAL CART
  ================================================= */

  cartItems = await Cart.getItems(publicUserId);
}


      if (!cartItems || cartItems.length === 0) {
        return res.status(400).json({
          success: false,
          message: "Cart is empty",
        });
      }

      const invalidVariantItem = cartItems.find((item) => {
  const id = Number(item.variant_id);
  return !Number.isInteger(id) || id <= 0;
});

if (invalidVariantItem) {
  return res.status(400).json({
    success: false,
    message:
      "A valid variant is missing for one or more cart items. Please update your cart.",
  });
}

      checkoutTotals = await calculateCheckoutTotals(publicUserId, cartItems);
      actualAmount = checkoutTotals.actualAmount;
      payableAmount = checkoutTotals.payableAmount;
    }

    if (
      paymentTypeUpper === "MEMBERSHIP" &&
      couponCode &&
      String(couponCode).trim()
    ) {
      return res.status(400).json({
        success: false,
        message: "Coupons can only be applied to product orders",
      });
    }

    let couponDetails = null;
    let couponDiscount = 0;

    if (couponCode && String(couponCode).trim()) {
      const coupon = await Coupon.findByCode(String(couponCode).trim());

      if (!coupon) {
        return res.status(400).json({
          success: false,
          message: "Invalid coupon",
        });
      }

      if (Number(coupon.is_active) !== 1) {
        return res.status(400).json({
          success: false,
          message: "Coupon expired",
        });
      }

      if (Number(checkoutTotals.totalLitres) < 2) {
        return res.status(400).json({
          success: false,
          message: "This coupon requires a minimum purchase of 2 litres",
        });
      }

      if (
        await Coupon.hasSuccessfulUseForUser({
          userId: req.authenticatedUser.id,
          couponId: coupon.coupon_id,
        })
      ) {
        return res.status(400).json({
          success: false,
          message: "You have already used this coupon",
        });
      }

      const couponTotals = applyCouponToCheckoutTotals(
        checkoutTotals,
        coupon.coupon_percentage,
      );
      couponDiscount = couponTotals.couponDiscount;
      payableAmount = couponTotals.payableAmount;
      checkoutTotals = couponTotals.checkoutTotals;

      couponDetails = {
        coupon_id: coupon.coupon_id,
        coupon_code: coupon.coupon_code,
        coupon_percentage: Number(coupon.coupon_percentage),
        coupon_discount: couponDiscount,
      };
    }

    // REFERRAL WALLET REDEMPTION
    if (paymentTypeUpper === "MEMBERSHIP" && requestedReferralBonus > 0) {
      return res.status(400).json({
        success: false,
        message: "Referral wallet cannot be used for membership",
      });
    }

    if (paymentTypeUpper !== "MEMBERSHIP") {
      const eligibleReferralAmount = roundMoney(
        Number(payableAmount) - Number(checkoutTotals.deliveryCharge || 0),
      );

      if (requestedReferralBonus > eligibleReferralAmount) {
        return res.status(400).json({
          success: false,
          message: "Referral amount exceeds eligible order amount",
        });
      }

      payableAmount = roundMoney(
        Number(payableAmount) - requestedReferralBonus,
      );
    }

    /* =====================================================
       SAFETY CHECK
    ===================================================== */

    if (
      !Number.isFinite(actualAmount) ||
      !Number.isFinite(payableAmount) ||
      payableAmount < 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid payment amount",
      });
    }

    console.log("Actual Amount:", actualAmount);

    console.log("Payable Amount:", payableAmount);


    /* =====================================================
       FREEZE CHECKOUT SNAPSHOT BEFORE RAZORPAY
    ===================================================== */
const pendingCustomerReferralId =
  getPendingReferral(publicUserId);


    const checkoutSnapshot = {
      version: 1,
      userId: publicUserId,
      paymentType: paymentTypeUpper,
      referralCode: referralCode ?? null,
      customerReferralId:
  (typeof customerReferralId === "string" &&
    customerReferralId.trim()) ||
  pendingCustomerReferralId ||
  null,
      addressId:
        paymentTypeUpper === "MEMBERSHIP" ? null : address_id,
buyNow: Boolean(buyNow),
productId: buyNow ? Number(productId) : null,
variantId: buyNow ? Number(variantId) : null,
quantity: buyNow ? Number(quantity ?? 1) : null,

cartItems: cartItems.map((item) => ({
  cart_id: item.cart_id ?? null,

  // Parent product ID
  item_id: Number(
    item.item_id ?? item.product_id ?? item.id
  ),
  product_id: Number(
    item.product_id ?? item.item_id ?? item.id
  ),

  // Selected variant details
  variant_id: Number(item.variant_id),
  variant_size: item.variant_size ?? null,

  product_name: item.product_name ?? item.name ?? null,
  quantity: Number(item.quantity),
  price: Number(item.price),
  weight: Number(item.weight ?? 0),
})),

      checkoutTotals,
      membershipPlan: membershipPlanSnapshot,

      membershipId:
        checkoutTotals?.membershipBenefits?.membership?.id ?? null,

      coupon: couponDetails,
      couponDiscount: Number(couponDiscount || 0),
      referralBonus: Number(requestedReferralBonus || 0),
      actualAmount: Number(actualAmount),
      payableAmount: Number(payableAmount),
      createdAt: new Date().toISOString(),
    };

    /* =====================================================
       CREATE LOCAL PAYMENT FIRST
    ===================================================== */

    const payment = await Payment.createPayment({
      order_id: null,
      tnx_order_id: null,
      payment_gateway: "RAZORPAY",
      actual_amount: actualAmount,
      payable_amount: payableAmount,
      status: "PENDING",
      payment_type: paymentTypeUpper,
      membership_plan_id: membershipPlanId || null,
      membership_id:
        checkoutTotals?.membershipBenefits?.membership?.id ?? null,
      fulfillment_data: {
        checkout_snapshot: checkoutSnapshot,
      },
      fulfillment_status: "PENDING",
      created_by: publicUserId,
    });

    /* =====================================================
       CREATE RAZORPAY ORDER
    ===================================================== */

    const razorpayAmount = isRazorpayTestMode()
      ? 1
      : payableAmount;

    const razorpayOrder =
      await razorpayService.createRazorpayOrder(razorpayAmount);

    console.log("RAZORPAY ORDER:", razorpayOrder);

    /* =====================================================
       ATTACH RAZORPAY ORDER ID TO SAVED PAYMENT
    ===================================================== */

    const updatedPayment = await Payment.updateRazorpayOrderId({
      paymentRecordId: payment.id,
      razorpayOrderId: razorpayOrder.id,
      userId: publicUserId,
    });

    return res.status(201).json({
      success: true,
      data: {
        payment: updatedPayment,
        razorpayOrder,
        key: process.env.RAZORPAY_KEY_ID,
        actualAmount,
        payableAmount,
        razorpayAmount,
      },
    });

  } catch (err) {
    void logException(err);
    console.error("CREATE ORDER ERROR:", err);
    if (err.code === "MEMBERSHIP_COUPON_NOT_ELIGIBLE") {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};
/* =========================================================
   VERIFY PAYMENT
========================================================= */

const verifyPayment = async (req, res) => {
  let verificationLockClient = null;
  let verificationLockKey = null;
  let couponVerificationLockKey = null;
  let membershipTransactionStarted = false;
  let verifiedCoupon = null;
  let verifiedCouponDiscount = 0;

  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      referralBonus = 0,
      paymentType,
      membershipPlanId,
      userId,
      address_id,
      buyNow,
      productId,
      quantity,
      referralCode,
      customerReferralId,
      couponCode,
    } = req.body;

let verifiedReferralBonus = 0;

    /* =====================================================
       VERIFY SIGNATURE
    ===================================================== */

    const isValid = razorpayService.verifyPaymentSignature(
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
    );

    if (!isValid && !req.isRazorpayWebhook) {
      return res.status(400).json({
        success: false,
        message: "Invalid signature",
      });
    }

    /* =====================================================
       FETCH RAZORPAY PAYMENT
    ===================================================== */

    let razorpayPayment;
    try {
      razorpayPayment =
        await razorpayService.fetchRazorpayPayment(razorpay_payment_id);
    } catch (error) {
      await logException(error, req);
      throw error;
    }

    console.log("[PAYMENT DIAGNOSTIC]", {
      razorpay_order_id,
      razorpay_payment_id,
      payment_type: paymentType,
      razorpay_status: razorpayPayment.status,
      razorpay_amount: razorpayPayment.amount,
      user_id: userId,
    });

    console.log("RAZORPAY PAYMENT:", JSON.stringify(razorpayPayment, null, 2));

    if (!razorpayPayment) {
      return res.status(400).json({
        success: false,
        message: "Razorpay payment not found",
      });
    }

    /* =====================================================
       PAYMENT MUST BE CAPTURED
    ===================================================== */

    if (razorpayPayment.status !== "captured") {
      return res.status(400).json({
        success: false,
        message: `Payment is not captured. Status: ${razorpayPayment.status}`,
      });
    }
    if (
      razorpayPayment.order_id !== razorpay_order_id ||
      String(razorpayPayment.currency || "").toUpperCase() !== "INR"
    ) {
      return res.status(400).json({
        success: false,
        message: "Payment order or currency mismatch",
      });
    }

    verificationLockKey = `RAZORPAY_VERIFICATION:${razorpay_order_id}`;
    verificationLockClient = await pool.connect();
    await verificationLockClient.query(
      "SELECT pg_advisory_lock(hashtext($1))",
      [verificationLockKey],
    );

    /* =====================================================
       FIND LOCAL PAYMENT
    ===================================================== */

    const existingPayment = await verificationLockClient.query(
      `
      SELECT *
      FROM payments
      WHERE tnx_order_id = $1
      ORDER BY id DESC
      LIMIT 1
    `,
      [razorpay_order_id],
    );

    const localPayment = existingPayment.rows[0];

    if (!localPayment) {
      return res.status(404).json({
        success: false,
        message: "Local payment record not found",
      });
    }
    if (
      String(localPayment.payment_gateway || "").toUpperCase() !== "RAZORPAY" ||
      String(localPayment.created_by || "") !== String(userId || "")
    ) {
      return res.status(403).json({
        success: false,
        message: "Payment does not belong to the authenticated user",
      });
    }
    
    /* =====================================================
   LOAD AND VALIDATE SAVED CHECKOUT SNAPSHOT
===================================================== */

const paymentFulfillmentData =
  typeof localPayment.fulfillment_data === "string"
    ? JSON.parse(localPayment.fulfillment_data)
    : (localPayment.fulfillment_data || {});

const savedCheckoutSnapshot =
  paymentFulfillmentData.checkout_snapshot;

if (
  !savedCheckoutSnapshot ||
  String(savedCheckoutSnapshot.userId) !== String(localPayment.created_by) ||
  String(savedCheckoutSnapshot.paymentType).toUpperCase() !==
    String(localPayment.payment_type).toUpperCase()
) {
  return res.status(400).json({
    success: false,
    message: "Saved checkout snapshot is missing or invalid",
  });
}

if (
  savedCheckoutSnapshot.gatewayOrderId &&
  String(savedCheckoutSnapshot.gatewayOrderId) !== String(razorpay_order_id)
) {
  return res.status(400).json({
    success: false,
    message: "Razorpay order ID does not match checkout snapshot",
  });
}

/* =====================================================
   USE SAVED CHECKOUT SNAPSHOT AS SOURCE OF TRUTH
===================================================== */

const snapshotPaymentType =
  String(savedCheckoutSnapshot.paymentType || "").toUpperCase();

const snapshotAddressId = savedCheckoutSnapshot.addressId ?? null;

const snapshotBuyNow = Boolean(savedCheckoutSnapshot.buyNow);

const snapshotProductId = savedCheckoutSnapshot.productId ?? null;

const snapshotQuantity = Number(savedCheckoutSnapshot.quantity ?? 1);

const snapshotReferralBonus = roundMoney(
  Number(savedCheckoutSnapshot.referralBonus || 0)
);

const snapshotReferralCode =
  savedCheckoutSnapshot.referralCode ?? referralCode ?? null;

const snapshotCustomerReferralId =
  savedCheckoutSnapshot.customerReferralId ?? customerReferralId ?? null;

const snapshotCoupon =
  savedCheckoutSnapshot.coupon ?? null;

const snapshotCouponCode =
  snapshotCoupon?.coupon_code ?? null;

const snapshotCouponDiscount = roundMoney(
  Number(savedCheckoutSnapshot.couponDiscount || 0)
);

const snapshotCheckoutTotals =
  savedCheckoutSnapshot.checkoutTotals ?? null;

const snapshotCartItems = Array.isArray(savedCheckoutSnapshot.cartItems)
  ? savedCheckoutSnapshot.cartItems.map((item) => ({
      ...item,
      item_id: item.item_id ?? item.product_id,
    }))
  : [];

const snapshotMembershipId =
  savedCheckoutSnapshot.membershipId ??
  localPayment.membership_id ??
  null;

  /* =====================================================
   VALIDATE REFERRAL BONUS FROM SAVED SNAPSHOT
===================================================== */

const snapshotReferralBonusAmount = Number(
  savedCheckoutSnapshot.referralBonus ?? 0
);

if (
  !Number.isFinite(snapshotReferralBonusAmount) ||
  snapshotReferralBonusAmount < 0 ||
  roundMoney(snapshotReferralBonusAmount) !==
    snapshotReferralBonusAmount
) {
  return res.status(400).json({
    success: false,
    message: "Saved referral wallet amount is invalid",
  });
}

verifiedReferralBonus = roundMoney(snapshotReferralBonusAmount);

const MIN_REFERRAL_REDEMPTION = 100;

if (
  verifiedReferralBonus > 0 &&
  verifiedReferralBonus < MIN_REFERRAL_REDEMPTION
) {
  return res.status(400).json({
    success: false,
    message: `Minimum referral wallet redemption is ₹${MIN_REFERRAL_REDEMPTION}`,
  });
}

if (
  snapshotPaymentType === "MEMBERSHIP" &&
  verifiedReferralBonus > 0
) {
  return res.status(400).json({
    success: false,
    message: "Referral wallet cannot be used for membership",
  });
}



  if (
  String(localPayment.payment_type || "").toUpperCase() !==
  String(savedCheckoutSnapshot.paymentType || "").toUpperCase()
) {
  return res.status(409).json({
    success: false,
    message: "Payment type does not match saved checkout snapshot",
  });
}
if (
  String(savedCheckoutSnapshot.paymentType).toUpperCase() === "MEMBERSHIP" &&
  Number(localPayment.membership_plan_id) !==
    Number(savedCheckoutSnapshot.membershipPlan?.id)
) {
  return res.status(409).json({
    success: false,
    message: "Membership plan does not match saved checkout snapshot",
  });
}

    if (
      localPayment.payment_id &&
      String(localPayment.payment_id) !== String(razorpay_payment_id)
    ) {
      return res.status(409).json({
        success: false,
        message:
          "A different gateway payment is already associated with this request",
      });
    }

    /* =====================================================
   VERIFY RAZORPAY AMOUNT

   TEST MODE:
   Razorpay must have charged ₹1.

   DO NOT compare this with the real
   order payable amount.
===================================================== */

    const razorpayAmountPaise = Number(razorpayPayment.amount);
    const razorpayAmount = razorpayAmountPaise / 100;

    const expectedAmount = isRazorpayTestMode()
      ? 1
      : Number(localPayment.payable_amount);

    console.log("RAZORPAY_TEST_MODE:", isRazorpayTestMode());
    console.log("Expected Razorpay Amount:", expectedAmount);
    console.log("Razorpay Amount:", razorpayAmount);

    if (
      !Number.isFinite(razorpayAmountPaise) ||
      !Number.isFinite(expectedAmount) ||
      !Number.isInteger(razorpayAmountPaise) ||
      Math.round(razorpayAmountPaise) !== Math.round(expectedAmount * 100)
    ) {
      return res.status(400).json({
        success: false,
        message: "Payment amount mismatch",
        expectedAmount,
        razorpayAmount,
      });
    }

    /* =====================================================
   RAZORPAY PAYMENT DETAILS
===================================================== */

    const paymentId = razorpayPayment.id || razorpay_payment_id;

    let recoverCapturedMembership = false;
    let recoverCapturedOrder = false;

    if (String(localPayment.status || "").toUpperCase() === "PAID") {
      if (String(localPayment.payment_id || "") !== String(paymentId)) {
        return res.status(409).json({
          success: false,
          message: "Payment was already verified with a different payment ID",
        });
      }

      if (String(localPayment.payment_type || "").toUpperCase() === "ORDER") {
        const existingOrderResult = localPayment.order_id
          ? await pool.query(
              `
      SELECT *
      FROM orders
      WHERE order_id = $1
        AND user_id = $2
        AND is_active = 1
      LIMIT 1
      `,
              [localPayment.order_id, userId],
            )
          : { rows: [] };
        const existingOrder = existingOrderResult.rows[0];

        if (!existingOrder) {
          recoverCapturedOrder = true;
        } else {
          return res.json({
            success: true,
            payment: localPayment,
            order: existingOrder,
            orderId: existingOrder.order_id,
            membershipBenefits: null,
            actualAmount: Number(existingOrder.actual_amount),
            membershipDiscount: Number(existingOrder.membership_discount || 0),
            walletClaim: Number(existingOrder.wallet_claim || 0),
            deliveryCharge: Number(existingOrder.delivery_charge || 0),
            payableAmount: Number(existingOrder.payable_amount),
            message: "Payment verified and order already created.",
          });
        }
      }

      if (
        String(localPayment.payment_type || "").toUpperCase() === "MEMBERSHIP"
      ) {
        const membershipResult = await pool.query(
          `
      SELECT *
      FROM user_memberships
      WHERE payment_id = $1
        AND user_id = $2
      ORDER BY id DESC
      LIMIT 1
      `,
          [localPayment.id, userId],
        );
        const existingMembership = membershipResult.rows[0];
        if (!existingMembership) {
          recoverCapturedMembership = true;
        } else {
          const requestedReferralInput =
            (typeof referralCode === "string" && referralCode.trim()) ||
            (typeof customerReferralId === "string" &&
              customerReferralId.trim()) ||
            "";

          const existingAssignedRole = String(
            existingMembership.assigned_role || "",
          )
            .trim()
            .toUpperCase();

          const isExistingVendorOrReseller =
            existingAssignedRole === "VENDOR" ||
            existingAssignedRole === "RESELLER";

          if (requestedReferralInput && !isExistingVendorOrReseller) {
            const vendorResellerCheck = await pool.query(
              `
            SELECT ul.user_id
            FROM user_login ul
            LEFT JOIN user_info ui ON ui.user_id = ul.user_id
            WHERE ul.is_active = 1
              AND ul.role IN (3, 4)
              AND (
                UPPER(TRIM(ul.user_id)) = UPPER(TRIM($1))
                OR (
                  ui.is_active = 1
                  AND UPPER(TRIM(ui.referral_code)) = UPPER(TRIM($1))
                )
              )
            LIMIT 1
            `,
              [requestedReferralInput],
            );

            if (!vendorResellerCheck.rows.length) {
              let validatedReferrerId;
              try {
                const referralValidation = await validateCustomerReferral({
                  referrerId: requestedReferralInput,
                  customerId: userId,
                });
                validatedReferrerId = referralValidation.referrerId;
              } catch (error) {
                void logException(error);
                return res.status(400).json({
                  success: false,
                  message: error.message,
                });
              }

              const recordedReferralId = String(
                existingMembership.referral_code || "",
              ).trim();

              if (!recordedReferralId) {
                const referralUpdate = await pool.query(
                  `
                UPDATE user_memberships
                SET referral_code = $1,
                    updated_at = NOW(),
                    updated_by = $2
                WHERE id = $3
                  AND user_id = $2
                  AND payment_id = $4
                  AND (referral_code IS NULL OR BTRIM(referral_code) = '')
                RETURNING referral_code
                `,
                  [
                    validatedReferrerId,
                    userId,
                    existingMembership.id,
                    localPayment.id,
                  ],
                );

            if (!referralUpdate.rows[0]) {
  return res.status(409).json({
    success: false,
    message:
      "Membership referral attribution changed; retry verification",
  });
}
existingMembership.referral_code =
  referralUpdate.rows[0].referral_code;

            } else if (
              recordedReferralId.toUpperCase() !==
              String(validatedReferrerId).trim().toUpperCase()
            ) {
              return res.status(409).json({
                success: false,
                message:
                  "A different referral is already recorded for this membership",
              });
            }
          }
        }
    
        await verificationLockClient.query("BEGIN");
        membershipTransactionStarted = true;

        const referralReward =
          await creditCustomerReferralRewardForMembership({
            membershipId: existingMembership.id,
            client: verificationLockClient,
          });

const membershipPaymentUpdate =
  await verificationLockClient.query(
    `
    UPDATE payments
    SET
      fulfillment_status = 'COMPLETED',
      fulfillment_data = jsonb_set(
        COALESCE(fulfillment_data, '{}'::jsonb),
        '{membership_id}',
        to_jsonb($1::integer),
        true
      ),
      updated_at = CURRENT_TIMESTAMP,
      updated_by = $2
    WHERE id = $3
      AND created_by = $2
      AND tnx_order_id = $4
    RETURNING *
    `,
    [
      existingMembership.id,
      userId,
      localPayment.id,
      razorpay_order_id,
    ],
  );

if (!membershipPaymentUpdate.rows[0]) {
  throw new Error("Failed to save membership payment fulfillment");
}


        if (requestedCustomerReferralId && !referralReward) {
          await verificationLockClient.query("ROLLBACK");
          membershipTransactionStarted = false;

          return res.status(409).json({
            success: false,
            message:
              "The recorded customer referral is not eligible for a reward",
          });
        }

        await verificationLockClient.query("COMMIT");
        membershipTransactionStarted = false;

          return res.json({
            success: true,
            payment: localPayment,
            membership: existingMembership,
            message: "Membership payment was already verified.",
          });
        }
      }

      if (!recoverCapturedMembership && !recoverCapturedOrder) {
        return res.status(409).json({
          success: false,
          message: "Paid payment has no supported reconciliation path",
          paymentId: localPayment.id,
        });
      }
    }

    if (
      String(localPayment.status || "").toUpperCase() !== "PENDING" &&
      !recoverCapturedMembership &&
      !recoverCapturedOrder
    ) {
      return res.status(409).json({
        success: false,
        message: "Payment is not in a reconcilable pending state",
        paymentId: localPayment.id,
      });
    }

    const pendingOrderResult = await verificationLockClient.query(
      `
  SELECT *
  FROM orders
  WHERE tnx_order_id = $1
    AND user_id = $2
    AND is_active = 1
  LIMIT 1
  `,
      [razorpay_order_id, userId],
    );
    const pendingOrder = pendingOrderResult.rows[0];

    if (pendingOrder) {
      const paymentMembershipId =
        localPayment.membership_id == null
          ? null
          : Number(localPayment.membership_id);
      const orderMembershipId =
        pendingOrder.membership_id == null
          ? null
          : Number(pendingOrder.membership_id);

      if (
        Math.round(Number(pendingOrder.payable_amount) * 100) !==
          Math.round(Number(localPayment.payable_amount) * 100) ||
        Math.round(Number(pendingOrder.actual_amount) * 100) !==
          Math.round(Number(localPayment.actual_amount) * 100) ||
        paymentMembershipId !== orderMembershipId
      ) {
        return res.status(409).json({
          success: false,
          message:
            "Captured payment and existing order totals require reconciliation",
          paymentId: localPayment.id,
        });
      }


      if (
        String(localPayment.payment_type || paymentType || "").toUpperCase() !== "MEMBERSHIP" &&
        snapshotCoupon
      ) {
        const savedCouponId = Number(snapshotCoupon.coupon_id);
        const savedCouponPercentage = Number(snapshotCoupon.coupon_percentage);

        if (
          !Number.isInteger(savedCouponId) ||
          savedCouponId <= 0 ||
          !Number.isFinite(savedCouponPercentage) ||
          savedCouponPercentage <= 0
        ) {
          return res.status(409).json({
            success: false,
            message: "Saved coupon details are invalid; payment requires reconciliation",
            paymentId: localPayment.id,
          });
        }

        verifiedCoupon = {
          coupon_id: savedCouponId,
          coupon_code: snapshotCoupon.coupon_code,
          coupon_percentage: savedCouponPercentage,
        };

        verifiedCouponDiscount = roundMoney(snapshotCouponDiscount);

        const expectedCouponPayable = roundMoney(
          Math.max(
            0,
            Number(pendingOrder.actual_amount) -
              verifiedCouponDiscount -
              Number(pendingOrder.wallet_claim || 0),
          ) + Number(pendingOrder.delivery_charge || 0),
        );

        if (
          Math.round(Number(pendingOrder.coupon_discount || 0) * 100) !==
            Math.round(verifiedCouponDiscount * 100) ||
          Math.round(expectedCouponPayable * 100) !==
            Math.round(Number(pendingOrder.payable_amount) * 100) ||
          (paymentMembershipId !== null &&
            Number(pendingOrder.membership_discount || 0) !== 0)
        ) {
          return res.status(409).json({
            success: false,
            message:
              "Saved coupon snapshot and captured payment totals require reconciliation",
            paymentId: localPayment.id,
          });
        }
      } else if (Number(pendingOrder.coupon_discount || 0) > 0) {
        return res.status(409).json({
          success: false,
          message: "Saved coupon details are missing; payment requires reconciliation",
          paymentId: localPayment.id,
        });
      }


      if (
        (Number(pendingOrder.membership_discount || 0) > 0 ||
          Number(pendingOrder.wallet_claim || 0) > 0) &&
        paymentMembershipId === null
      ) {
        return res.status(503).json({
          success: false,
          message:
            "Captured membership-benefit order requires reconciliation because its membership ID is missing",
          paymentId: localPayment.id,
        });
      }

      await verificationLockClient.query("BEGIN");
      try {
        if (paymentMembershipId !== null) {
          const litresUsed = calculateSnapshotOrderLitres(snapshotCartItems);

          await Membership.updateMembershipUsage({
            userId,
            membershipId: paymentMembershipId,
            litresUsed,
            walletUsed: Number(pendingOrder.wallet_claim || 0),
            orderId: pendingOrder.order_id,
            client: verificationLockClient,
          });
        }

        const orderUpdate = await verificationLockClient.query(
          `
      UPDATE orders
      SET
        payment_status = 'PAID',
        coupon_discount = $5,
        updated_at = CURRENT_TIMESTAMP,
        updated_by = $1
      WHERE id = $2
        AND user_id = $1
        AND tnx_order_id = $3
        AND is_active = 1
        AND membership_id IS NOT DISTINCT FROM $4::integer
      RETURNING *
      `,
          [
            userId,
            pendingOrder.id,
            razorpay_order_id,
            paymentMembershipId,
            verifiedCouponDiscount,
          ],
        );

        if (verifiedCoupon) {
          const couponUserResult = await verificationLockClient.query(
            `
        SELECT id
        FROM user_login
        WHERE user_id = $1
          AND is_active = 1
        LIMIT 1
        `,
            [userId],
          );
          const couponNumericUserId = couponUserResult.rows[0]?.id;
          if (!couponNumericUserId) {
            throw new Error(
              "Could not resolve numeric user ID for coupon transaction",
            );
          }
          await Coupon.createTransaction(
            {
              transactionId: razorpay_payment_id,
              userId: couponNumericUserId,
              orderId: pendingOrder.id,
              paymentId: localPayment.id,
              couponId: verifiedCoupon.coupon_id,
              status: "APPLIED",
              createdBy: String(userId),
              updatedBy: String(userId),
            },
            verificationLockClient,
          );
        }
        const paymentUpdate = await verificationLockClient.query(
          `
      UPDATE payments
      SET
        order_id = $1,
        status = 'PAID',
        payment_id = $2,
        method = $3,
        upi_transaction_id = $4,
        updated_at = CURRENT_TIMESTAMP,
        updated_by = $6
      WHERE id = $5
        AND created_by = $6
        AND tnx_order_id = $7
        AND payment_gateway = 'RAZORPAY'
        AND status IN ('PENDING', 'PAID')
        AND membership_id IS NOT DISTINCT FROM $8::integer
      RETURNING *
      `,
          [
            pendingOrder.order_id,
            paymentId,
            razorpayPayment.method || null,
            razorpayPayment?.acquirer_data?.upi_transaction_id || null,
            localPayment.id,
            userId,
            razorpay_order_id,
            paymentMembershipId,
          ],
        );

        if (!orderUpdate.rows[0] || !paymentUpdate.rows[0]) {
          throw new Error("Captured payment recovery update failed");
        }

const recoveryFulfillmentUpdate =
  await verificationLockClient.query(
    `
    UPDATE payments
    SET
      fulfillment_status = 'COMPLETED',
      fulfillment_data = jsonb_set(
        COALESCE(fulfillment_data, '{}'::jsonb),
        '{order_id}',
        to_jsonb($1::text),
        true
      ),
      updated_at = CURRENT_TIMESTAMP,
      updated_by = $2
    WHERE id = $3
      AND created_by = $2
      AND tnx_order_id = $4
    RETURNING *
    `,
    [
      orderUpdate.rows[0].order_id,
      userId,
      localPayment.id,
      razorpay_order_id,
    ],
  );

if (!recoveryFulfillmentUpdate.rows[0]) {
  throw new Error("Failed to complete recovered payment fulfillment");
}




        await verificationLockClient.query("COMMIT");
        return res.json({
          success: true,
          payment: paymentUpdate.rows[0],
          order: orderUpdate.rows[0],
          orderId: orderUpdate.rows[0].order_id,
          membershipBenefits: null,
          actualAmount: Number(orderUpdate.rows[0].actual_amount),
          membershipDiscount: Number(
            orderUpdate.rows[0].membership_discount || 0,
          ),
          walletClaim: Number(orderUpdate.rows[0].wallet_claim || 0),
          deliveryCharge: Number(orderUpdate.rows[0].delivery_charge || 0),
          payableAmount: Number(orderUpdate.rows[0].payable_amount),
          message: "Captured payment reconciled with its existing order.",
        });
      } catch (recoveryError) {
        void logException(recoveryError);
        await verificationLockClient.query("ROLLBACK");
        throw recoveryError;
      }
    }

    if (localPayment.order_id) {
      const priorOrderResult = await pool.query(
        `
    SELECT id
    FROM orders
    WHERE order_id = $1
      AND user_id = $2
      AND is_active = 1
    LIMIT 1
    `,
        [localPayment.order_id, userId],
      );
      if (priorOrderResult.rows[0]) {
        return res.status(409).json({
          success: false,
          message:
            "Captured payment is linked to an order that requires reconciliation",
          paymentId: localPayment.id,
        });
      }
    }

    const method = razorpayPayment.method || null;

    const upiTransactionId =
      razorpayPayment?.acquirer_data?.upi_transaction_id || null;

    let payment = localPayment;
    const updateLocalPayment = async (status, client = null) => {
      const updatedPayment = await Payment.updateByTnxOrderId(
        razorpay_order_id,
        {
          status,
          payment_id: paymentId,
          upi_transaction_id: upiTransactionId,
          method,
          actual_amount: localPayment.actual_amount,
          payable_amount: localPayment.payable_amount,
          created_by: userId,
          payment_record_id: localPayment.id,
        },
        client,
      );

      if (!updatedPayment) {
        throw new Error("Local payment state could not be updated");
      }

      payment = updatedPayment;
      return payment;
    };
    const createPaymentSuccessNotification = async () => {
      try {
        await Notification.createNotification({
          userId,
          title: "Payment Successful",
          message: "Your payment was successfully completed.",
          type: "PAYMENT_SUCCESS",
          referenceId: payment.id,
        });
      } catch (notificationError) {
        void logException(notificationError);
        console.error(
          "PAYMENT SUCCESS NOTIFICATION ERROR:",
          notificationError.message,
        );
      }
    };

await updateLocalPayment("PAID");


/* =====================================================
   MEMBERSHIP BENEFITS / SAVED CHECKOUT SNAPSHOT
===================================================== */

let membershipBenefits = null;
let checkoutTotals = null;
let checkoutItems = [];

const persistedMembershipId =
  localPayment.membership_id == null
    ? null
    : Number(localPayment.membership_id);

if (snapshotPaymentType !== "MEMBERSHIP") {
  // Use the cart items and totals saved BEFORE Razorpay payment.
  checkoutItems = snapshotCartItems;

  checkoutTotals = snapshotCheckoutTotals;

  if (!checkoutItems.length || !checkoutTotals) {
    throw new Error(
      "Captured payment has no valid saved checkout snapshot"
    );
  }

  // Restore coupon details from the saved snapshot.
  verifiedCoupon = snapshotCoupon
    ? {
        coupon_id: snapshotCoupon.coupon_id,
        coupon_code: snapshotCoupon.coupon_code,
        coupon_percentage: snapshotCoupon.coupon_percentage,
      }
    : null;

  verifiedCouponDiscount = snapshotCouponDiscount;

  // Verify the saved amounts match the payment record.
  const expectedPayable = roundMoney(
    Number(localPayment.payable_amount)
  );

  const expectedActual = roundMoney(
    Number(localPayment.actual_amount)
  );

  const snapshotPayable = roundMoney(
    Number(checkoutTotals.payableAmount) -
      verifiedReferralBonus
  );

  const snapshotActual = roundMoney(
    Number(checkoutTotals.actualAmount)
  );

  if (
    !Number.isFinite(expectedPayable) ||
    !Number.isFinite(expectedActual) ||
    expectedPayable !== snapshotPayable ||
    expectedActual !== snapshotActual
  ) {
    throw new Error(
      "Saved checkout snapshot amounts do not match captured payment"
    );
  }
}
    /* =====================================================
   MEMBERSHIP PAYMENT
===================================================== */

    if (
      String(localPayment.payment_type || paymentType || "").toUpperCase() ===
      "MEMBERSHIP"
    ) {
      const planResult = await pool.query(
        `
        SELECT *
        FROM lkp_subscription_plans
        WHERE id = $1
      `,
        [
  savedCheckoutSnapshot.membershipPlan?.id ||
  localPayment.membership_plan_id
],
      );

      const plan = planResult.rows[0];

      if (!plan) {
        return res.status(404).json({
          success: false,
          message: "Membership plan not found",
        });
      }

const savedPlanPrice = Number(
  savedCheckoutSnapshot.membershipPlan?.plan_price
);

if (
  !Number.isFinite(savedPlanPrice) ||
  savedPlanPrice <= 0 ||
  roundMoney(savedPlanPrice) !==
    roundMoney(Number(localPayment.actual_amount))
) {
  throw new Error(
    "Saved membership plan price does not match payment record"
  );
}

      const expiryDate = new Date();

      expiryDate.setFullYear(expiryDate.getFullYear() + 1);

      /* =================================================
     CUSTOMER
  ================================================= */

      const assignmentResult = await pool.query(
        `
        SELECT
          ul.id AS numeric_user_id,
          ul.mobile_no AS mobile,
          ul.user_id AS login_user_id,
          ul.role,
          ul.created_by,
          ul.assigned_by
        FROM user_login ul
        WHERE ul.user_id = $1
          AND ul.is_active = 1
        LIMIT 1
      `,
        [userId],
      );

      const customer = assignmentResult.rows[0];

      if (!customer) {
        return res.status(404).json({
          success: false,
          message: "Customer account not found",
        });
      }

      /* =================================================
     DEFAULT ASSIGNMENT
  ================================================= */

      let assignedBy = customer.assigned_by || customer.created_by || null;

      let assignedRoleId = null;
      let assignedRole = null;

      if (assignedBy) {
        const assignedUserResult = await pool.query(
          `
          SELECT role
          FROM user_login
          WHERE user_id = $1
          LIMIT 1
        `,
          [assignedBy],
        );

        assignedRoleId =
          assignedUserResult.rows[0]?.role == null
            ? null
            : Number(assignedUserResult.rows[0].role);
        assignedRole = getRoleName(assignedRoleId);
      }

      /* =================================================
     REFERRAL
  ================================================= */

      // let validatedReferralCode = null;

      // if (typeof referralCode === "string" && referralCode.trim() !== "") {
      //   const cleanReferralCode = referralCode.trim();

      //   const referralResult = await pool.query(
      //     `
      //     SELECT
      //       ul.id AS referrer_user_id,
      //       ul.user_id AS referral_user_id,
      //       ul.role
      //     FROM user_login ul
      //     WHERE ul.user_id = $1
      //       AND ul.is_active = 1
      //       AND ul.role IN (3, 4)
      //     LIMIT 1
      //   `,
      //     [cleanReferralCode],
      //   );

      //   const referrer = referralResult.rows[0];

      //   if (!referrer) {
      //     return res.status(400).json({
      //       success: false,
      //       message: "Invalid referral code",
      //     });
      //   }

      //   if (String(referrer.referrer_user_id) === String(userId)) {
      //     return res.status(400).json({
      //       success: false,
      //       message: "You cannot use your own referral code",
      //     });
      //   }

      //   assignedBy = referrer.referral_user_id;

      //   assignedRoleId = Number(referrer.role);
      //   assignedRole = getRoleName(assignedRoleId);

      //   validatedReferralCode = referrer.referral_user_id;
      // }
      /* =================================================
   REFERRAL
================================================= */
      let validatedReferralCode = null;
      let validatedCustomerReferralId = null;

const cleanReferralInput =
  (typeof snapshotReferralCode === "string" &&
    snapshotReferralCode.trim()) ||
  (typeof snapshotCustomerReferralId === "string" &&
    snapshotCustomerReferralId.trim()) ||
  (typeof referralCode === "string" && referralCode.trim()) ||
  (typeof customerReferralId === "string" &&
    customerReferralId.trim()) ||
  "";

      if (cleanReferralInput !== "") {
        const referralResult = await pool.query(
          `
    SELECT
      ul.id AS referrer_user_id,
      ul.user_id AS referral_user_id,
      ul.role,

      CASE
        WHEN ul.role = 3
          AND UPPER(TRIM(ui.referral_code)) ~ '^V[0-9]{4}$'
          THEN UPPER(TRIM(ui.referral_code))

        WHEN ul.role = 4
          AND UPPER(TRIM(ui.referral_code)) ~ '^R[0-9]{4}$'
          THEN UPPER(TRIM(ui.referral_code))

        ELSE ul.user_id
      END AS canonical_referral_code

    FROM user_login ul

    LEFT JOIN user_info ui
      ON ui.user_id = ul.user_id

    WHERE
      ul.is_active = 1
      AND ul.role IN (3, 4)
      AND (
        -- OLD LOGIC: Match Vendor / Reseller public user ID
        UPPER(TRIM(ul.user_id)) = UPPER(TRIM($1))

        OR

        -- NEW LOGIC: Match generated referral code
        (
          ui.is_active = 1
          AND UPPER(TRIM(ui.referral_code)) = UPPER(TRIM($1))
          AND (
            (
              ul.role = 3
              AND UPPER(TRIM(ui.referral_code)) ~ '^V[0-9]{4}$'
            )
            OR
            (
              ul.role = 4
              AND UPPER(TRIM(ui.referral_code)) ~ '^R[0-9]{4}$'
            )
          )
        )
      )

    LIMIT 1
    `,
          [cleanReferralInput],
        );

        const referrer = referralResult.rows[0];

        if (referrer) {
          // Prevent self-referral
          if (
            String(referrer.referral_user_id).trim().toUpperCase() ===
            String(userId).trim().toUpperCase()
          ) {
            return res.status(400).json({
              success: false,
              message: "You cannot use your own referral code",
            });
          }

          // Assign the referrer's public user ID
          assignedBy = referrer.referral_user_id;
          assignedRoleId = Number(referrer.role);
          assignedRole = getRoleName(assignedRoleId);

          // Store the generated code if valid; otherwise store the legacy user ID
          validatedReferralCode = referrer.canonical_referral_code;
        } else {
          // Fallback: validate as a Customer referral ID
          try {
            const referralValidation = await validateCustomerReferral({
              referrerId: cleanReferralInput,
              customerId: userId,
            });

            validatedCustomerReferralId = referralValidation.referrerId;
          } catch (error) {
            void logException(error);
            return res.status(400).json({
              success: false,
              message: error.message || "Invalid referral code",
            });
          }
        }
      }

      /* =================================================
         CREATE MEMBERSHIP
      ================================================= */
      await verificationLockClient.query("BEGIN");
      membershipTransactionStarted = true;

      const membership = await Membership.createMembership({
        userId: userId,

        planId: plan.id,

        paymentId: payment.id,

walletBalance:
  savedCheckoutSnapshot.membershipPlan.wallet_bonus,

discountPercent:
  savedCheckoutSnapshot.membershipPlan.discount_percentage,

monthlyClaim:
  savedCheckoutSnapshot.membershipPlan.monthly_claim,

        expiryDate,

        termsAndConditions: true,

        assignedBy,

        assignedRole,

        referralCode: validatedCustomerReferralId || validatedReferralCode,

        client: verificationLockClient,
      });

      await Payment.updateByTnxOrderId(
        razorpay_order_id,
        {
          created_by: userId,
          payment_record_id: payment.id,
          fulfillment_status: "COMPLETED",
          fulfillment_data: {
            membership_id: membership.id,
          },
        },
        verificationLockClient,
      );
      /* =================================================
         PAYMENT LOG
      ================================================= */

      try {
        await Payment.createPaymentLog(
          {
            user_id: userId,

            order_id: membership.id,

            order_type: "MEMBERSHIP",

            payment_request: {
              razorpay_order_id,

              razorpay_payment_id,

              amount: razorpayPayment.amount,

              currency: razorpayPayment.currency,
            },

            payment_response: razorpayPayment,
          },
          verificationLockClient,
        );

        console.log(`Payment log created for membership ${membership.id}`);
      } catch (paymentLogError) {
        void logException(paymentLogError);
        throw paymentLogError;
      }

      /* =================================================
         WHATSAPP SUBSCRIPTION
      ================================================= */

      try {
        if (customer?.mobile) {
          await sendSubscriptionWhatsApp({
            mobile: customer.mobile,

            customerName: customer.full_name || "Customer",

            planName: plan.plan_name || plan.name || "Subscription",

            walletAmount: Number(plan.wallet_bonus || 0).toFixed(2),

            validity: "1 Year",
          });

          console.log(
            `WHATSAPP SUBSCRIPTION SENT FOR MEMBERSHIP ${membership.id}`,
          );
        }
      } catch (whatsappError) {
        void logException(whatsappError);
        console.error("WHATSAPP SUBSCRIPTION FAILED:", whatsappError.message);
      }

      /* =================================================
         CREATE IN-APP MEMBERSHIP NOTIFICATION
      ================================================= */
      try {
        const notification = await Notification.createNotification({
          userId: userId,

          title: "🎉 Membership Activated!",

          message:
            `Your membership has been activated successfully.\n` +
            `Plan: ${plan.plan_name || plan.name || "Membership"} 🌱`,

          type: "MEMBERSHIP_ACTIVATED",

          referenceId: membership.id,
        });

        console.log(`MEMBERSHIP NOTIFICATION CREATED FOR USER ${userId}`);

        // Send push notification
        const userResult = await pool.query(
          `
      SELECT fcm_token
      FROM user_login
      WHERE user_id = $1
        AND is_active = 1
      LIMIT 1
    `,
          [userId],
        );

        const fcmToken = userResult.rows[0]?.fcm_token;

        if (fcmToken) {
          await sendPushNotification({
            fcmToken,

            title: notification.title,

            body: notification.message,

            data: {
              userId: userId,

              type: "MEMBERSHIP_ACTIVATED",

              membershipId: String(membership.id),
            },
          });

          console.log(
            `MEMBERSHIP push notification sent for membership ${membership.id}`,
          );
        } else {
          console.log(`No FCM token found for user ${userId}`);
        }
      } catch (notificationError) {
        void logException(notificationError);
        console.error(
          "MEMBERSHIP NOTIFICATION FAILED:",
          notificationError.message,
        );
      }

      /* =================================================
         UPDATE REFERRAL ASSIGNMENT
      ================================================= */

      if (validatedReferralCode && assignedBy) {
        await verificationLockClient.query(
          `
            UPDATE user_login
            SET assigned_by = $1
            WHERE user_id = $2
              AND is_active = 1
          `,
          [assignedBy, userId],
        );
      }

      /* =================================================
         PROCESS VENDOR / RESELLER BENEFIT
      ================================================= */

      const membershipBenefitResult = await processMembershipBenefit({
        membershipId: membership.id,

        customerId: userId,

        assignedBy,

        assignedRole: assignedRoleId,

        subscriptionAmount: Number(plan.plan_price),

        client: verificationLockClient,
      });

      await updateLocalPayment("PAID", verificationLockClient);
      await verificationLockClient.query("COMMIT");
      await createPaymentSuccessNotification();
      /* =================================================
   NOTIFY SUPER_ADMIN ABOUT MEMBERSHIP ACTIVATION
================================================= */

      try {
        const notificationResult = await Notification.notifySuperAdmins({
          title: "New Membership Activated",

          message:
            `${customer?.full_name || userId} (${userId}) has successfully activated the ` +
            `${plan.plan_name || plan.name || "Membership"}.`,

          type: "MEMBERSHIP_ACTIVATED",

          referenceId: membership.id,
        });

        console.log(
          "SUPER_ADMIN MEMBERSHIP NOTIFICATION RESULT:",
          notificationResult,
        );
      } catch (notificationError) {
        void logException(notificationError);

        console.error(
          "SUPER_ADMIN MEMBERSHIP NOTIFICATION FAILED:",
          notificationError.message,
        );
      }

      if (validatedCustomerReferralId) {
        const referralReward = await creditCustomerReferralRewardForMembership({
          membershipId: membership.id,
        });
if (validatedCustomerReferralId) {
  const referralReward =
    await creditCustomerReferralRewardForMembership({
      membershipId: membership.id,
      client: verificationLockClient,
    });

  if (referralReward) {
    console.log(
      `CUSTOMER REFERRAL REWARD: ₹${referralReward.rewardAmount} credited to ${validatedCustomerReferralId}`,
    );
  }
}
const membershipFulfillmentUpdate =
  await verificationLockClient.query(
    `
    UPDATE payments
    SET
      fulfillment_status = 'COMPLETED',
      fulfillment_data = jsonb_set(
        COALESCE(fulfillment_data, '{}'::jsonb),
        '{membership_id}',
        to_jsonb($1::integer),
        true
      ),
      updated_at = CURRENT_TIMESTAMP,
      updated_by = $2
    WHERE id = $3
      AND created_by = $2
      AND tnx_order_id = $4
    RETURNING id
    `,
    [
      membership.id,
      userId,
      localPayment.id,
      razorpay_order_id,
    ],
  );

if (!membershipFulfillmentUpdate.rows[0]) {
  throw new Error("Failed to complete membership payment fulfillment");
}



await updateLocalPayment("PAID", verificationLockClient);

await verificationLockClient.query("COMMIT");
membershipTransactionStarted = false;
await createPaymentSuccessNotification();

      console.log("===== MEMBERSHIP WALLET BENEFITS =====");

      console.log(membershipBenefitResult);

      /* =================================================
   VENDOR / RESELLER REFERRAL NOTIFICATION
================================================= */

      try {
        /*
         * No referral/assignment means there is nobody
         * to notify.
         */
        if (assignedBy && assignedRoleId) {
          let shouldNotifyReferral = false;

          /*
           * DIRECT VENDOR
           *
           * Vendor gets 20% benefit.
           * Send notification to the Vendor.
           */
          if (assignedRoleId === 3) {
            shouldNotifyReferral = true;
          }

          /*
           * RESELLER
           *
           * If this Reseller was created by a Vendor,
           * the existing benefit split is:
           *
           * Vendor    = 10%
           * Reseller  = 10%
           *
           * In this case, do NOT create a referral
           * notification for either one.
           *
           * Otherwise it is a direct Reseller referral:
           *
           * Reseller = 15%
           *
           * Send notification to the Reseller.
           */
          if (assignedRoleId === 4) {
            const resellerResult = await pool.query(
              `
            SELECT
              created_by
            FROM user_login
            WHERE user_id = $1
              AND role = 4
              AND is_active = 1
            LIMIT 1
          `,
              [assignedBy],
            );

            const reseller = resellerResult.rows[0];

            let parentVendor = null;

            if (reseller?.created_by) {
              const parentVendorResult = await pool.query(
                `
              SELECT
                user_id
              FROM user_login
              WHERE user_id = $1
                AND role = 3
                AND is_active = 1
              LIMIT 1
            `,
                [reseller.created_by],
              );

              parentVendor = parentVendorResult.rows[0] || null;
            }

            /*
             * Only notify a direct Reseller.
             *
             * Vendor-created Reseller:
             * parentVendor exists → NO notification.
             */
            if (!parentVendor) {
              shouldNotifyReferral = true;
            }
          }

          /*
           * Create notification only for the person
           * who directly shared the referral.
           */
          if (shouldNotifyReferral) {
            const referralBenefit = membershipBenefitResult.find(
              (benefit) => String(benefit.beneficiaryId) === String(assignedBy),
            );

            /*
             * Safety check:
             * If there is no matching benefit, do not
             * create a misleading notification.
             */
            if (referralBenefit) {
              const notification = await Notification.createNotification({
                userId: assignedBy,

                title: "🎉 New Membership Referral",

                message:
                  `Customer ${userId} took the ${
                    plan.plan_name || plan.name || "Membership"
                  } using your referral.\n` +
                  `You received ${
                    referralBenefit.benefitPercent
                  }% benefit (₹${Number(referralBenefit.benefitAmount).toFixed(
                    2,
                  )}) from this membership.`,

                type: "MEMBERSHIP_REFERRAL",

                referenceId: membership.id,
              });

              console.log(
                `MEMBERSHIP REFERRAL NOTIFICATION CREATED FOR ${assignedRole} ${assignedBy}`,
              );

              console.log("MEMBERSHIP REFERRAL NOTIFICATION:", notification);
            }
          }
        }
      } catch (notificationError) {
        void logException(notificationError);
        /*
         * Notification failure must never break
         * successful membership activation or benefit
         * processing.
         */
        console.error(
          "MEMBERSHIP REFERRAL NOTIFICATION FAILED:",
          notificationError.message,
        );
      }

      return res.json({
        success: true,

        payment,

        membership,

        message: "Membership activated successfully.",
      });
    }
    /* =====================================================
       CREATE NORMAL ORDER
    ===================================================== */

    let createdOrder = null;

    if (
      String(localPayment.payment_type || paymentType || "").toUpperCase() !==
      "MEMBERSHIP"
    ) {
      console.log("===== CREATING NORMAL ORDER =====");

      /* ===================================================
         VALIDATE ADDRESS
      =================================================== */
if (!snapshotAddressId) {
  return res.status(400).json({
    success: false,
    message: "Saved delivery address is missing",
  });
}

      const addressResult = await pool.query(
        `
            SELECT *
            FROM user_address
            WHERE id = $1
              AND user_id = $2
            LIMIT 1
          `,
        [snapshotAddressId, userId],
      );

      const selectedAddress = addressResult.rows[0];

      if (!selectedAddress) {
        return res.status(400).json({
          success: false,
          message: "Selected address does not belong to this user",
        });
      }

      console.log("SELECTED ADDRESS:", selectedAddress);


      

      /* ===================================================
         BUY NOW ORDER
      =================================================== */
let createdOrderDbId = null;
let createdOrderId = null;

try {
  await verificationLockClient.query("BEGIN");


      if (snapshotBuyNow && snapshotProductId) {
        const buyNowQuantity = snapshotQuantity;

        console.log("===== BUY NOW ORDER =====");

        console.log({
          userId,
          productId,
          quantity: buyNowQuantity,
          address_id,
        });

createdOrder = await Order.createBuyNowOrder(
  userId,
  snapshotAddressId,
  snapshotProductId,
  snapshotQuantity,
  savedCheckoutSnapshot,
  verificationLockClient,
  "PAID"
);
      } else {
        /* =================================================
           NORMAL CART ORDER
        ================================================= */

        console.log("===== CART ORDER =====");

createdOrder = await Order.createOrder(
  userId,
  snapshotAddressId,
  false,
  null,
  1,
  savedCheckoutSnapshot,
  verificationLockClient,
  "PAID"
);
      }

if (!createdOrder) {
  throw new Error("Failed to create order");
}

      console.log("ORDER CREATED:", createdOrder);

      /* ===================================================
         ORDER ID
      =================================================== */

      createdOrderDbId = createdOrder.id;
      createdOrderId = createdOrder.order_id;

if (!createdOrderDbId || !createdOrderId) {
  throw new Error("Order created but order ID was not returned");
}

      /* ===================================================
         SAVE ORDER BREAKDOWN
      =================================================== */

      const actualAmount = checkoutTotals.actualAmount;
      const membershipDiscount = checkoutTotals.membershipDiscount;
      const walletClaim = checkoutTotals.walletClaim;
      const deliveryCharge = checkoutTotals.deliveryCharge;
      const payableAmount = checkoutTotals.payableAmount;

      console.log("===== FINAL ORDER BREAKDOWN =====");

      console.log({
        orderId: createdOrderId,

        actualAmount,

        membershipDiscount,

        walletClaim,

        deliveryCharge,

        payableAmount,
      });

        if (
          Number(createdOrder.membership_id || 0) !==
          Number(persistedMembershipId || 0)
        ) {
          throw new Error(
            "Created order membership does not match its payment",
          );
        }

        if (persistedMembershipId !== null) {
         const litresUsed = calculateSnapshotOrderLitres(snapshotCartItems);

          await Membership.updateMembershipUsage({
            userId,
            membershipId: persistedMembershipId,
            litresUsed,
            walletUsed: Number(createdOrder.wallet_claim || 0),
            orderId: createdOrder.order_id,
            client: verificationLockClient,
          });
        }

        if (verifiedReferralBonus > 0) {
          await redeemCustomerReferralWithClient({
            client: verificationLockClient,
            userId,
            amount: verifiedReferralBonus,
            referenceType: "ORDER_REFERRAL_REDEMPTION",
            referenceId: createdOrderId,
          });
        }

        const updatedOrderResult = await verificationLockClient.query(
          `
            UPDATE orders
            SET
              payment_status = 'PAID',
              tnx_order_id = COALESCE(tnx_order_id, $3),
              coupon_discount = $5,
              payable_amount = $6,
              referral_bonus = $7,
              updated_at = CURRENT_TIMESTAMP,
              updated_by = $1
            WHERE id = $2
              AND user_id = $1
              AND is_active = 1
              AND membership_id IS NOT DISTINCT FROM $4::integer
            RETURNING *
            `,
          [
            userId,
            createdOrderDbId,
            razorpay_order_id,
            persistedMembershipId,
            Number(verifiedCouponDiscount || 0),
            roundMoney(
              Number(checkoutTotals.payableAmount) - verifiedReferralBonus,
            ),
            verifiedReferralBonus,
          ],
        );

          if (!updatedOrderResult.rows[0]) {
  throw new Error("Failed to mark created order as PAID");
}



        if (verifiedCoupon && payment) {
          const couponUserResult = await verificationLockClient.query(
            `
    SELECT id
    FROM user_login
    WHERE user_id = $1
      AND is_active = 1
    LIMIT 1
    `,
            [userId],
          );

          const couponNumericUserId = couponUserResult.rows[0]?.id;

          if (!couponNumericUserId) {
            throw new Error(
              "Could not resolve numeric user ID for coupon transaction",
            );
          }

          await Coupon.createTransaction(
            {
              transactionId: razorpay_payment_id,
              userId: couponNumericUserId,
              orderId: createdOrderDbId,
              paymentId: payment.id,
              couponId: verifiedCoupon.coupon_id,
              status: "APPLIED",
              createdBy: String(userId),
              updatedBy: String(userId),
            },
            verificationLockClient,
          );

          console.log("Coupon transaction recorded", {
            couponId: verifiedCoupon.coupon_id,
            orderId: createdOrderDbId,
            paymentId: payment.id,
          });
        }

const updatedPaymentResult = await verificationLockClient.query(
  `
  UPDATE payments
  SET
   order_id = $1::varchar,
    status = 'PAID',
    fulfillment_status = 'COMPLETED',
    fulfillment_data = jsonb_set(
      COALESCE(fulfillment_data, '{}'::jsonb),
      '{order_id}',
      to_jsonb($1::varchar),
      true
    ),
    payment_id = $2,
    method = $3,
    upi_transaction_id = $4,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = $6
  WHERE id = $5
    AND created_by = $6
  RETURNING *
  `,
  [
    createdOrder.order_id,
    paymentId,
    method,
    upiTransactionId,
    localPayment.id,
    userId,
  ],
);

        if (!updatedPaymentResult.rows[0]) {
          const currentPaymentCheck = await verificationLockClient.query(
            `SELECT id, status, created_by, payment_gateway, tnx_order_id FROM payments WHERE id = $1`,
            [localPayment?.id],
          );
          console.error("PAYMENT ROW MISMATCH DEBUG:", {
            localPaymentId: localPayment?.id,
            userId,
            actualDbRow: currentPaymentCheck.rows[0] || "ROW_NOT_FOUND",
          });
          throw new Error("PAYMENT UPDATE FAILED: no matching payment row");
        }

        await verificationLockClient.query("COMMIT");
        createdOrder = updatedOrderResult.rows[0];
        payment = updatedPaymentResult.rows[0];
        await createPaymentSuccessNotification();

        console.log(`Order ${createdOrderId} marked as PAID`);

        console.log(`Transaction order ID ${razorpay_order_id} saved`);
      } catch (orderPaymentError) {
        void logException(orderPaymentError);
        await verificationLockClient.query("ROLLBACK");
        console.error("ORDER PAYMENT STATUS ERROR:", orderPaymentError.message);

        throw orderPaymentError;
      }

      /* ===================================================
   CREATE ORDER PAYMENT LOG
=================================================== */

      try {
        await Payment.createPaymentLog({
          user_id: userId,

          order_id: createdOrderDbId,

          order_type: "ORDER",

          payment_request: {
            razorpay_order_id,

            razorpay_payment_id,

            amount: razorpayPayment.amount,

            currency: razorpayPayment.currency,
          },

          payment_response: razorpayPayment,
        });

        console.log(`Order payment log created for order ${createdOrderId}`);
      } catch (paymentLogError) {
        void logException(paymentLogError);
        console.error("ORDER PAYMENT LOG ERROR:", paymentLogError.message);
      }

      /* ===================================================
   ORDER SUCCESS NOTIFICATION
=================================================== */
      try {
        const notification = await Notification.createNotification({
          userId: userId,

          title: "Order Placed Successfully",

          message: `Your order #${createdOrderId} has been placed successfully.`,

          type: "ORDER_PLACED",

          referenceId: createdOrderDbId,
        });

        console.log(
          `ORDER_PLACED notification created for order ${createdOrderId}`,
        );

        // Send push notification
        const userResult = await pool.query(
          `
      SELECT fcm_token
      FROM user_login
      WHERE user_id = $1
        AND is_active = 1
      LIMIT 1
    `,
          [userId],
        );

        const fcmToken = userResult.rows[0]?.fcm_token;

        if (fcmToken) {
          await sendPushNotification({
            fcmToken,

            title: notification.title,

            body: notification.message,

            data: {
              userId: userId,

              type: "ORDER_PLACED",

              orderId: String(createdOrderId),
            },
          });

          console.log(
            `ORDER_PLACED push notification sent for order ${createdOrderId}`,
          );
        } else {
          console.log(`No FCM token found for user ${userId}`);
        }
      } catch (notificationError) {
        void logException(notificationError);
        console.error("ORDER NOTIFICATION ERROR:", notificationError.message);
      }

      /* ===================================================
   WHATSAPP ORDER CONFIRMATION
=================================================== */

      try {
        const customerResult = await pool.query(
          `
        SELECT
          a.user_id,
          a.phone AS mobile_no,
          a.full_name
        FROM user_address a
        WHERE a.id = $1
          AND a.user_id = $2
          AND a.is_active = 1
        LIMIT 1
      `,
          [createdOrder.address_id, userId],
        );

        const customer = customerResult.rows[0];

        if (customer && customer.mobile_no) {
          await sendOrderConfirmation({
            mobile: customer.mobile_no,

            customerName: customer.full_name || "Customer",

            orderId: createdOrderId,

            amount: Number(createdOrder.payable_amount).toFixed(2),

            orderSummary: "Order placed successfully",
          });

          console.log(`ORDER WHATSAPP SENT FOR ORDER ${createdOrderId}`);
        }
      } catch (whatsappError) {
        void logException(whatsappError);
        console.error("ORDER WHATSAPP FAILED:", whatsappError.message);
      }

      /* ===================================================
   FINAL NORMAL ORDER RESPONSE
=================================================== */

      return res.json({
        success: true,

        payment,

        order: createdOrder,

        orderId: createdOrderId,

        membershipBenefits,
        
actualAmount: Number(createdOrder.actual_amount),

membershipDiscount: Number(createdOrder.membership_discount),

walletClaim: Number(createdOrder.wallet_claim),

deliveryCharge: Number(createdOrder.delivery_charge),

payableAmount: Number(createdOrder.payable_amount),

        message: "Payment verified and order created successfully.",
      });
    }

    /* =====================================================
   FALLBACK RESPONSE
===================================================== */

    return res.json({
      success: true,

      payment,

      message: "Payment verified successfully.",
    });
  } catch (error) {
    void logException(error);
    if (membershipTransactionStarted && verificationLockClient) {
      try {
        await verificationLockClient.query("ROLLBACK");
        membershipTransactionStarted = false;
      } catch (rollbackError) {
        void logException(rollbackError);
        console.error(
          "MEMBERSHIP TRANSACTION ROLLBACK ERROR:",
          rollbackError.message,
        );
      }
    }

    console.error("VERIFY PAYMENT ERROR:", error);
    if (error.code === "COUPON_ALREADY_USED") {
      return res.status(409).json({
        success: false,
        message: "You have already used this coupon",
      });
    }

    if (error.code === "MEMBERSHIP_COUPON_NOT_ELIGIBLE") {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,

      message: error.message || "Payment verification failed",
    });
  } finally {
    if (verificationLockClient) {
      if (couponVerificationLockKey) {
        try {
          await verificationLockClient.query(
            "SELECT pg_advisory_unlock(hashtext($1))",
            [couponVerificationLockKey],
          );
        } catch (unlockError) {
          void logException(unlockError);
          console.error(
            "COUPON VERIFICATION LOCK RELEASE ERROR:",
            unlockError.message,
          );
        }
      }

      try {
        if (verificationLockKey) {
          await verificationLockClient.query(
            "SELECT pg_advisory_unlock(hashtext($1))",
            [verificationLockKey],
          );
        }
      } catch (unlockError) {
        void logException(unlockError);
        console.error(
          "RAZORPAY VERIFICATION LOCK RELEASE ERROR:",
          unlockError.message,
        );
      } finally {
        verificationLockClient.release();
      }
    }
  }
};

const recoverMembershipCustomerReferralReward = async (req, res) => {
  const membershipId = Number(req.params.membershipId);
  const customerId = String(req.authenticatedUser?.id || "").trim();

  if (!Number.isInteger(membershipId) || membershipId <= 0) {
    return res.status(400).json({
      success: false,
      message: "Valid membership ID is required",
    });
  }

  if (!customerId) {
    return res.status(401).json({
      success: false,
      message: "Authenticated customer is required",
    });
  }

  try {
    const reward = await creditCustomerReferralRewardForMembership({
      membershipId,
      customerId,
    });

    if (!reward) {
      return res.status(409).json({
        success: false,
        message:
          "No reward was credited: the membership must be paid, belong to this customer, and have an eligible customer referrer",
      });
    }

    return res.json({
      success: true,
      membershipId,
      rewardAmount: reward.rewardAmount,
      duplicate: reward.transaction.duplicate,
      walletBalance: Number(reward.transaction.wallet.current_balance),
      transactionId: reward.transaction.transaction.id,
    });
  } catch (error) {
    void logException(error);
    console.error("CUSTOMER REFERRAL REWARD RECOVERY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Customer referral reward recovery failed",
    });
  }
};

/* =========================================================
   GET PAYMENTS
========================================================= */

const getPayments = async (req, res) => {
  try {
    const { user_id, order_id } = req.query;

    let payments;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    payments = order_id
      ? await Payment.getPaymentsByUserAndOrderId(user_id, order_id)
      : await Payment.getPaymentsByUserId(user_id);

    return res.json({
      success: true,
      data: payments,
    });
  } catch (error) {
    void logException(error);
    console.error("GET PAYMENTS ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch payments",
    });
  }
};

/* =========================================================
   CHECKOUT SUMMARY
========================================================= */

const checkoutSummary = async (req, res) => {
  try {
    const { user_id, buyNow, productId, quantity, variantId,couponCode } = req.body;

    const publicUserId = user_id;

    if (!publicUserId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    /* =====================================================
       CART ITEMS
    ===================================================== */

    let cartItems = [];

    /* =====================================================
       BUY NOW
    ===================================================== */


if (buyNow && productId) {
  const selectedVariantId = Number(variantId);
  const buyNowQuantity = Number(quantity ?? 1);

  if (!Number.isInteger(selectedVariantId) || selectedVariantId <= 0) {
    return res.status(400).json({
      success: false,
      message: "A valid product variant is required",
    });
  }

  if (!Number.isInteger(buyNowQuantity) || buyNowQuantity <= 0) {
    return res.status(400).json({
      success: false,
      message: "Invalid product quantity",
    });
  }

  const productResult = await pool.query(
    `
    SELECT
      p.id,
      p.name,
      p.weight,
      pv.id AS variant_id,
      pv.size AS variant_size,
      pv.price,
      pv.stock
    FROM lkp_products p
    INNER JOIN product_variants pv
      ON pv.product_id = p.id
    WHERE p.id = $1
      AND pv.id = $2
      AND p.is_active = 1
      AND pv.is_active = 1
    LIMIT 1
    `,
    [productId, selectedVariantId],
  );

  if (productResult.rows.length === 0) {
    return res.status(404).json({
      success: false,
      message: "Selected product variant not found or inactive",
    });
  }

  const product = productResult.rows[0];

  if (Number(product.stock) < buyNowQuantity) {
    return res.status(400).json({
      success: false,
      message: "Insufficient stock for the selected variant",
    });
  }

  cartItems = [
    {
      cart_id: null,
      user_id: publicUserId,
      item_id: Number(product.id),
      product_id: Number(product.id),
      variant_id: Number(product.variant_id),
      variant_size: product.variant_size,
      product_name: product.name,
      price: Number(product.price),
      weight: Number(product.weight || 0),
      stock: Number(product.stock),
      quantity: buyNowQuantity,
      total_price: Number(product.price) * buyNowQuantity,
    },
  ];
} else {
  /* =================================================
     NORMAL CART
  ================================================= */

  cartItems = await Cart.getItems(publicUserId);
}


    /* =====================================================
       EMPTY CART
    ===================================================== */

    if (!cartItems || cartItems.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Cart is empty",
      });
    }

    /* =====================================================
       MEMBERSHIP BENEFITS
    ===================================================== */

    let checkoutTotals = await calculateCheckoutTotals(publicUserId, cartItems);

    // Total quantity of items in cart
    const totalItemsCount = cartItems.reduce(
      (total, item) => total + Number(item.quantity || 0),
      0,
    );

    const membershipBenefits = checkoutTotals.membershipBenefits;
    const subtotal = checkoutTotals.subtotal;
    const totalLitres = checkoutTotals.totalLitres;
    const membershipDiscount = checkoutTotals.membershipDiscount;
    const walletClaim = checkoutTotals.walletClaim;
    const deliveryCharge = checkoutTotals.deliveryCharge;
    const deliverySavings = checkoutTotals.deliverySavings;
    const expectedDeliveryDays = checkoutTotals.expectedDeliveryDays;

    /* =====================================================
   DELIVERY DESCRIPTION
===================================================== */

    const deliveryDescriptionResult = await pool.query(
      `
    SELECT description
    FROM delivery_charges
    WHERE is_active = 1
      AND delivery_cart_count = $1
    LIMIT 1
  `,
      [totalItemsCount],
    );

    const deliveryDescription =
      deliveryDescriptionResult.rows[0]?.description ?? null;

    const actualAmount = checkoutTotals.actualAmount;
    const payableAmount = Number(checkoutTotals.payableAmount);

    let coupon = null;
    let couponDiscount = 0;
    let finalPayableAmount = payableAmount;
    let appliedMembershipDiscount = membershipDiscount;
    let appliedWalletClaim = walletClaim;
    let appliedMembershipBenefits = membershipBenefits;

    if (couponCode && String(couponCode).trim()) {
      coupon = await Coupon.findByCode(String(couponCode).trim());

      if (!coupon) {
        return res.status(400).json({
          success: false,
          message: "Invalid coupon",
        });
      }

      if (Number(coupon.is_active) !== 1) {
        return res.status(400).json({
          success: false,
          message: "Coupon expired",
        });
      }

      if (Number(totalLitres) < 2) {
        return res.status(400).json({
          success: false,
          message: "This coupon requires a minimum purchase of 2 litres",
        });
      }

      const couponTotals = applyCouponToCheckoutTotals(
        checkoutTotals,
        coupon.coupon_percentage,
      );
      couponDiscount = couponTotals.couponDiscount;
      checkoutTotals = couponTotals.checkoutTotals;
      finalPayableAmount = checkoutTotals.payableAmount;
      appliedMembershipDiscount = checkoutTotals.membershipDiscount;
      appliedWalletClaim = checkoutTotals.walletClaim;
      appliedMembershipBenefits = checkoutTotals.membershipBenefits;
    }

    console.log("===== CHECKOUT SUMMARY =====");

    console.log({
      user_id: publicUserId,

      buyNow: !!buyNow,

      productId: productId || null,

      quantity: quantity || null,

      subtotal,

      actualAmount,

      membershipDiscount: appliedMembershipDiscount,

      walletClaim: appliedWalletClaim,

      deliveryCharge,

      expectedDeliveryDays,

      payableAmount: finalPayableAmount,
    });

    /* =====================================================
       RESPONSE
    ===================================================== */

    return res.json({
      success: true,
      cartItems,
      membershipBenefits: appliedMembershipBenefits,
      subtotal,
      actualAmount,
      membershipDiscount: appliedMembershipDiscount,
      walletClaim: appliedWalletClaim,
      deliveryCharge,
      deliveryDescription,
      deliverySavings,
      expectedDeliveryDays,
      payableAmount: finalPayableAmount,
      coupon: coupon
        ? {
            coupon_id: coupon.coupon_id,
            coupon_code: coupon.coupon_code,
            coupon_percentage: Number(coupon.coupon_percentage),
          }
        : null,
      couponDiscount,
      finalPayableAmount,
    });
  } catch (error) {
    void logException(error);
    console.error("CHECKOUT SUMMARY ERROR:", error);

    return res
      .status(error.code === "MEMBERSHIP_COUPON_NOT_ELIGIBLE" ? 400 : 500)
      .json({
        success: false,

        message: error.message || "Failed to calculate checkout summary",
      });
  }
};

const razorpayWebhook = async (req, res) => {
  try {
    const signature = req.get("x-razorpay-signature");

    // Verify Razorpay webhook signature using the raw request body.
    const isValid = razorpayService.verifyWebhookSignature(
      req.body,
      signature,
    );

    if (!isValid) {
      return res.status(400).json({
        success: false,
        message: "Invalid webhook signature",
      });
    }

    const event = JSON.parse(req.body.toString("utf8"));

    // Process only captured payments.
    if (event.event !== "payment.captured") {
      return res.status(200).json({
        success: true,
        message: "Event ignored",
      });
    }

    const paymentEntity = event?.payload?.payment?.entity;
    const razorpay_order_id = paymentEntity?.order_id;
    const razorpay_payment_id = paymentEntity?.id;

    if (!razorpay_order_id || !razorpay_payment_id) {
      return res.status(400).json({
        success: false,
        message: "Missing Razorpay payment details",
      });
    }

    const result = await pool.query(
      `SELECT created_by, payment_type, membership_plan_id, fulfillment_data
       FROM payments
       WHERE tnx_order_id = $1
         AND payment_gateway = 'RAZORPAY'
       ORDER BY id DESC
       LIMIT 1`,
      [razorpay_order_id],
    );

    if (result.rows.length === 0) {
      throw new Error("Local payment record not found for webhook order");
    }

    const localPayment = result.rows[0];

    const fulfillmentData =
      typeof localPayment.fulfillment_data === "string"
        ? JSON.parse(localPayment.fulfillment_data)
        : localPayment.fulfillment_data;

    const snapshot = fulfillmentData?.checkout_snapshot;

    if (!snapshot || !snapshot.userId) {
      throw new Error("Checkout snapshot missing for webhook payment");
    }

    if (String(snapshot.userId) !== String(localPayment.created_by)) {
      throw new Error("Webhook payment user does not match checkout snapshot");
    }

    // Reuse the existing verified payment fulfillment flow.
    req.body = {
      razorpay_order_id,
      razorpay_payment_id,
      userId: snapshot.userId,
      paymentType: snapshot.paymentType ?? localPayment.payment_type,
      membershipPlanId:
        snapshot.membershipPlan?.id ?? localPayment.membership_plan_id,
      address_id: snapshot.addressId ?? null,
buyNow: Boolean(snapshot.buyNow),
productId: snapshot.productId ?? null,

variantId:
  snapshot.variantId ??
  snapshot.cartItems?.[0]?.variant_id ??
  null,

quantity: snapshot.quantity ?? 1,
      referralCode: snapshot.referralCode ?? null,
      customerReferralId: snapshot.customerReferralId ?? null,
      couponCode: snapshot.coupon?.coupon_code ?? null,
      referralBonus: snapshot.referralBonus ?? 0,
    };

    req.isRazorpayWebhook = true;

    return await verifyPayment(req, res);
  } catch (error) {
    await logException(error, req);

    return res.status(500).json({
      success: false,
      message: "Webhook processing failed",
    });
  }
};

/* =========================================================
   MODULE EXPORTS
========================================================= */

module.exports = {
  createOrder,
  verifyPayment,
  recoverMembershipCustomerReferralReward,
  getPayments,
  checkoutSummary,
  applyCouponToCheckoutTotals,
  razorpayWebhook,
};
