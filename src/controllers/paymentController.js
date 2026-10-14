const Order = require("../models/Order");
const Payment = require("../models/Payment");
const Notification = require("../models/Notification");
const razorpayService = require("../services/razorpayService");
const Membership = require("../models/Membership");
const pool = require("../../db");
const { getRoleName } = require("../utils/userRoles");
const xpressbeesService = require("../services/xpressbeesService");
const Cart = require("../models/Cart");
const User = require("../models/User");
const Coupon = require("../models/Coupon");

const {
  sendPushNotification,
} = require("../services/fcmService");

const {
  calculateCheckoutTotals,
} = require("../services/membershipCheckoutService");

const {
  processMembershipBenefit,
} = require("../services/membershipBenefitService");

const {
  sendOrderConfirmation,
  sendSubscriptionWhatsApp,
} = require("../services/whatsappService");

const roundMoney = (amount) =>
  Math.round((Number(amount) + Number.EPSILON) * 100) / 100;

const isRazorpayTestMode = () =>
  String(process.env.RAZORPAY_KEY_ID || "").startsWith("rzp_test_");


const applyCouponToCheckoutTotals = (checkoutTotals, couponPercentage) => {
  const subtotal = Number(
    checkoutTotals.actualAmount ?? checkoutTotals.subtotal ?? 0
  );

  const membershipDiscount = Number(
    checkoutTotals.membershipDiscount || 0
  );

  const walletClaim = Number(checkoutTotals.walletClaim || 0);
  const deliveryCharge = Number(checkoutTotals.deliveryCharge || 0);

  // Coupon applies to products after membership discount.
  // Delivery charges and wallet claims are excluded.
  const eligibleProductAmount = Math.max(
    0,
    roundMoney(subtotal - membershipDiscount)
  );

  const couponDiscount = roundMoney(
    (eligibleProductAmount * Number(couponPercentage)) / 100
  );

  const discountedProductAmount = Math.max(
    0,
    roundMoney(
      eligibleProductAmount - couponDiscount - walletClaim
    )
  );

  const otherApplicableFees = roundMoney(
    Number(checkoutTotals.payableAmount || 0) -
      (
        Number(checkoutTotals.subtotal ?? subtotal) -
        membershipDiscount -
        walletClaim +
        deliveryCharge
      )
  );

  const payableAmount = roundMoney(
    discountedProductAmount +
      deliveryCharge +
      otherApplicableFees
  );

  return { couponDiscount, payableAmount };
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
  quantity,
  address_id,
  couponCode,
} = req.body;

const publicUserId = user_id;


    if (!publicUserId) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const paymentTypeUpper =
      (paymentType || "ORDER").toUpperCase();

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
        [address_id, publicUserId]
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


    /* =====================================================
       MEMBERSHIP PAYMENT
    ===================================================== */

    if (
      paymentTypeUpper === "MEMBERSHIP"
    ) {
      const planResult =
        await pool.query(
          `
            SELECT *
            FROM lkp_subscription_plans
            WHERE id = $1
          `,
          [membershipPlanId]
        );


      const plan =
        planResult.rows[0];


      if (!plan) {
        return res.status(404).json({
          success: false,
          message:
            "Membership plan not found",
        });
      }

      actualAmount =
        Number(plan.plan_price);


      payableAmount =
        Number(plan.plan_price);
    }


    /* =====================================================
       NORMAL PRODUCT ORDER
    ===================================================== */

    if (
      paymentTypeUpper !== "MEMBERSHIP"
    ) {
      let cartItems = [];


      /* -----------------------------------------------
         BUY NOW
      ------------------------------------------------ */

      if (
        buyNow &&
        productId
      ) {
        const productResult =
          await pool.query(
            `
              SELECT
                id,
                name,
                price,
                weight,
                stock
              FROM lkp_products
              WHERE id = $1
                AND is_active = 1
              LIMIT 1
            `,
            [productId]
          );


        if (
          !productResult.rows.length
        ) {
          return res.status(404).json({
            success: false,
            message:
              "Product not found",
          });
        }


        const product =
          productResult.rows[0];


        const buyNowQuantity = Number(quantity ?? 1);


        /*
         * Create the same item structure that
         * calculateMembershipBenefits() expects.
         *
         * This is only an in-memory item.
         * It is NOT inserted into cart_items.
         */
        cartItems = [
          {
            cart_id: null,

            user_id:
              publicUserId,

            product_id:
              product.id,

            product_name:
              product.name,

            price:
              Number(product.price || 0),

            weight:
              Number(product.weight || 0),

            stock:
              Number(product.stock || 0),

            quantity:
              buyNowQuantity,

            total_price:
              Number(product.price || 0) *
              buyNowQuantity,
          },
        ];
      }


      /* -----------------------------------------------
         NORMAL CART
      ------------------------------------------------ */

      else {
        /*
         * IMPORTANT:
         *
         * New Cart model:
         *
         * Cart.getItems(user_id)
         */
        cartItems =
          await Cart.getItems(
            publicUserId
          );
      }


      if (
        !cartItems ||
        cartItems.length === 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Cart is empty",
        });
      }


      checkoutTotals = await calculateCheckoutTotals(
        publicUserId,
        cartItems
      );
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
  const coupon = await Coupon.findByCode(
    String(couponCode).trim()
  );

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
    coupon.coupon_percentage
  );
  couponDiscount = couponTotals.couponDiscount;
  payableAmount = couponTotals.payableAmount;

  couponDetails = {
    coupon_id: coupon.coupon_id,
    coupon_code: coupon.coupon_code,
    coupon_percentage: Number(coupon.coupon_percentage),
    coupon_discount: couponDiscount,
  };
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
        message:
          "Invalid payment amount",
      });
    }


    console.log(
      "Actual Amount:",
      actualAmount
    );

    console.log(
      "Payable Amount:",
      payableAmount
    );


    /* =====================================================
       CREATE RAZORPAY ORDER

       TEST MODE:
       Razorpay will charge only ₹1.

       Database still stores the REAL
       actualAmount and payableAmount.
    ===================================================== */

const razorpayAmount = isRazorpayTestMode() ? 1 : payableAmount;

const razorpayOrder =
  await razorpayService.createRazorpayOrder(
    razorpayAmount
  );

    console.log(
      "RAZORPAY ORDER:",
      razorpayOrder
    );


    /* =====================================================
       CREATE LOCAL PAYMENT

       IMPORTANT:
       Store REAL amounts here.
    ===================================================== */

    const payment =
      await Payment.createPayment({
        order_id: null,

        tnx_order_id:
          razorpayOrder.id,

        payment_gateway:
          "RAZORPAY",

        actual_amount:
          actualAmount,

        payable_amount:
          payableAmount,

        status:
          "PENDING",

        payment_type:
          paymentTypeUpper,

        membership_plan_id:
          membershipPlanId || null,

        membership_id:
          checkoutTotals?.membershipBenefits?.membership?.id ?? null,

        created_by:
          publicUserId,
      });


    return res.status(201).json({
      success: true,

      data: {
        payment,

        razorpayOrder,

        key:
          process.env.RAZORPAY_KEY_ID,

        actualAmount,

        payableAmount,

        razorpayAmount,

      },
    });


  } catch (err) {
    console.error(
      "CREATE ORDER ERROR:",
      err
    );


    return res.status(500).json({
      success: false,
      message:
        err.message,
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

  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      paymentType,
      membershipPlanId,
      userId,
      address_id,
      buyNow,
      productId,
      quantity,
      referralCode,
      couponCode,
    } = req.body;
    /* =====================================================
       VERIFY SIGNATURE
    ===================================================== */

    const isValid =
      razorpayService.verifyPaymentSignature(
        razorpay_order_id,
        razorpay_payment_id,
        razorpay_signature
      );


    if (!isValid) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid signature",
      });
    }


    /* =====================================================
       FETCH RAZORPAY PAYMENT
    ===================================================== */

    const razorpayPayment =
      await razorpayService.fetchRazorpayPayment(
        razorpay_payment_id
      );


    console.log(
      "RAZORPAY PAYMENT:",
      JSON.stringify(
        razorpayPayment,
        null,
        2
      )
    );


    if (!razorpayPayment) {
      return res.status(400).json({
        success: false,
        message:
          "Razorpay payment not found",
      });
    }


    /* =====================================================
       PAYMENT MUST BE CAPTURED
    ===================================================== */

    if (
      razorpayPayment.status !==
      "captured"
    ) {
      return res.status(400).json({
        success: false,
        message:
          `Payment is not captured. Status: ${razorpayPayment.status}`,
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

    verificationLockKey =
      `RAZORPAY_VERIFICATION:${razorpay_order_id}`;
    verificationLockClient = await pool.connect();
    await verificationLockClient.query(
      "SELECT pg_advisory_lock(hashtext($1))",
      [verificationLockKey]
    );

    /* =====================================================
       FIND LOCAL PAYMENT
    ===================================================== */

    const existingPayment =
      await verificationLockClient.query(
    `
      SELECT *
      FROM payments
      WHERE tnx_order_id = $1
      ORDER BY id DESC
      LIMIT 1
    `,
    [razorpay_order_id]
  );


const localPayment =
  existingPayment.rows[0];


if (!localPayment) {
  return res.status(404).json({
    success: false,
    message:
      "Local payment record not found",
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

if (
  String(localPayment.payment_type || "ORDER").toUpperCase() !==
  String(paymentType || "ORDER").toUpperCase()
) {
  return res.status(409).json({
    success: false,
    message: "Payment type does not match the local payment request",
  });
}

if (
  String(localPayment.payment_type || "").toUpperCase() === "MEMBERSHIP" &&
  Number(localPayment.membership_plan_id) !== Number(membershipPlanId)
) {
  return res.status(409).json({
    success: false,
    message: "Membership plan does not match the local payment request",
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

const razorpayAmountPaise =
  Number(razorpayPayment.amount);
const razorpayAmount =
  razorpayAmountPaise / 100;


const expectedAmount = isRazorpayTestMode()
  ? 1
  : Number(localPayment.payable_amount);


console.log(
  "Expected Razorpay Amount:",
  expectedAmount
);


console.log(
  "Razorpay Amount:",
  razorpayAmount
);


if (
  !Number.isFinite(razorpayAmountPaise) ||
  !Number.isFinite(expectedAmount) ||
  !Number.isInteger(razorpayAmountPaise) ||
  Math.round(razorpayAmountPaise) !== Math.round(expectedAmount * 100)
) {
  return res.status(400).json({
    success: false,
    message:
      "Payment amount mismatch",
    expectedAmount,
    razorpayAmount,
  });
}


/* =====================================================
   RAZORPAY PAYMENT DETAILS
===================================================== */

const paymentId =
  razorpayPayment.id ||
  razorpay_payment_id;

if (String(localPayment.status || "").toUpperCase() === "PAID") {
  if (String(localPayment.payment_id || "") !== String(paymentId)) {
    return res.status(409).json({
      success: false,
      message: "Payment was already verified with a different payment ID",
    });
  }

  if (String(localPayment.payment_type || "").toUpperCase() === "ORDER") {
    const existingOrderResult = await pool.query(
      `
      SELECT *
      FROM orders
      WHERE order_id = $1
        AND user_id = $2
        AND is_active = 1
      LIMIT 1
      `,
      [localPayment.order_id, userId]
    );
    const existingOrder = existingOrderResult.rows[0];

    if (!existingOrder) {
      return res.status(409).json({
        success: false,
        message:
          "Captured payment is marked paid but its order requires reconciliation",
        paymentId: localPayment.id,
      });
    }

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

  if (String(localPayment.payment_type || "").toUpperCase() === "MEMBERSHIP") {
    const membershipResult = await pool.query(
      `
      SELECT *
      FROM user_memberships
      WHERE payment_id = $1
        AND user_id = $2
      ORDER BY id DESC
      LIMIT 1
      `,
      [localPayment.id, userId]
    );
    if (!membershipResult.rows[0]) {
      return res.status(409).json({
        success: false,
        message:
          "Membership payment is marked paid but membership activation requires reconciliation",
        paymentId: localPayment.id,
      });
    }

    return res.json({
      success: true,
      payment: localPayment,
      membership: membershipResult.rows[0],
      message: "Membership payment was already verified.",
    });
  }

  return res.status(409).json({
    success: false,
    message: "Paid payment has no supported reconciliation path",
    paymentId: localPayment.id,
  });
}

if (String(localPayment.status || "").toUpperCase() !== "PENDING") {
  return res.status(409).json({
    success: false,
    message:
      "Payment is not in a reconcilable pending state",
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
  [razorpay_order_id, userId]
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
      const litresUsed = await Membership.calculateOrderLitres(
        pendingOrder.item_id,
        pendingOrder.quantity,
        verificationLockClient
      );

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
        updated_at = CURRENT_TIMESTAMP,
        updated_by = $1
      WHERE id = $2
        AND user_id = $1
        AND tnx_order_id = $3
        AND is_active = 1
        AND membership_id IS NOT DISTINCT FROM $4::integer
      RETURNING *
      `,
      [userId, pendingOrder.id, razorpay_order_id, paymentMembershipId]
    );
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
        AND status = 'PENDING'
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
      ]
    );

    if (!orderUpdate.rows[0] || !paymentUpdate.rows[0]) {
      throw new Error("Captured payment recovery update failed");
    }

    await verificationLockClient.query("COMMIT");
    return res.json({
      success: true,
      payment: paymentUpdate.rows[0],
      order: orderUpdate.rows[0],
      orderId: orderUpdate.rows[0].order_id,
      membershipBenefits: null,
      actualAmount: Number(orderUpdate.rows[0].actual_amount),
      membershipDiscount: Number(orderUpdate.rows[0].membership_discount || 0),
      walletClaim: Number(orderUpdate.rows[0].wallet_claim || 0),
      deliveryCharge: Number(orderUpdate.rows[0].delivery_charge || 0),
      payableAmount: Number(orderUpdate.rows[0].payable_amount),
      message: "Captured payment reconciled with its existing order.",
    });
  } catch (recoveryError) {
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
    [localPayment.order_id, userId]
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


const method =
  razorpayPayment.method ||
  null;


const upiTransactionId =
  razorpayPayment
    ?.acquirer_data
    ?.upi_transaction_id ||
  null;


let payment = localPayment;
const updateLocalPayment = async (status) => {
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
    }
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
    console.error(
      "PAYMENT SUCCESS NOTIFICATION ERROR:",
      notificationError.message
    );
  }
};

await updateLocalPayment("PENDING");


await Membership.checkAndResetMonthlyBenefits(
  userId
);


/* =====================================================
   MEMBERSHIP BENEFITS
===================================================== */

let membershipBenefits =
  null;
let checkoutTotals = null;
let checkoutItems = [];
let verifiedCoupon = null;
let verifiedCouponDiscount = 0;
const persistedMembershipId =
  localPayment.membership_id == null
    ? null
    : Number(localPayment.membership_id);


if (
  (paymentType || "").toUpperCase() !==
  "MEMBERSHIP"
) {

  /*
   * IMPORTANT:
   *
   * Cart.getItems() now accepts the public
   * MGU user_id.
   *
   * userId is the public value received from
   * the frontend.
   */
  let cartItems = [];


  /*
   * BUY NOW
   *
   * Buy Now is not necessarily stored in the cart,
   * so create the same temporary item structure
   * used during createOrder().
   */
  if (
    buyNow &&
    productId
  ) {
    const productResult =
      await pool.query(
        `
          SELECT
            id,
            name,
            price,
            weight,
            stock
          FROM lkp_products
          WHERE id = $1
            AND is_active = 1
          LIMIT 1
        `,
        [productId]
      );


    if (
      productResult.rows.length
    ) {
      const product =
        productResult.rows[0];


      const buyNowQuantity = Number(quantity ?? 1);


      cartItems = [
        {
          cart_id: null,

          user_id:
            userId,

          product_id:
            product.id,

          product_name:
            product.name,

          price:
            Number(product.price || 0),

          weight:
            Number(product.weight || 0),

          stock:
            Number(product.stock || 0),

          quantity:
            buyNowQuantity,

          total_price:
            Number(product.price || 0) *
            buyNowQuantity,
        },
      ];
    }

  } else {

    /*
     * NORMAL CART
     */
    cartItems =
      await Cart.getItems(
        userId
      );
  }


  if (!cartItems || cartItems.length === 0) {
    return res.status(409).json({
      success: false,
      message:
        "Captured payment requires reconciliation because checkout items are no longer available",
      paymentId: localPayment.id,
      paymentStatus: localPayment.status,
    });
  }

  checkoutItems = cartItems.map((item) => ({
    ...item,
    item_id: item.item_id ?? item.product_id,
  }));
  checkoutTotals = await calculateCheckoutTotals(
    userId,
    cartItems,
    persistedMembershipId
  );


if (couponCode && String(couponCode).trim()) {
  verifiedCoupon = await Coupon.findByCode(
    String(couponCode).trim()
  );

  if (!verifiedCoupon) {
    return res.status(400).json({
      success: false,
      message: "Invalid coupon",
    });
  }

  if (Number(verifiedCoupon.is_active) !== 1) {
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

  couponVerificationLockKey =
    `COUPON_USE:${req.authenticatedUser.id}:${verifiedCoupon.coupon_id}`;
  await verificationLockClient.query(
    "SELECT pg_advisory_lock(hashtext($1))",
    [couponVerificationLockKey]
  );

  if (
    await Coupon.hasSuccessfulUseForUser({
      userId: req.authenticatedUser.id,
      couponId: verifiedCoupon.coupon_id,
      excludePaymentId: localPayment.id,
      client: verificationLockClient,
    })
  ) {
    return res.status(409).json({
      success: false,
      message: "You have already used this coupon",
    });
  }

  const couponTotals = applyCouponToCheckoutTotals(
    checkoutTotals,
    verifiedCoupon.coupon_percentage
  );
  verifiedCouponDiscount = couponTotals.couponDiscount;

  checkoutTotals = {
    ...checkoutTotals,
    payableAmount: couponTotals.payableAmount,
  };
}

  membershipBenefits = checkoutTotals.membershipBenefits;
  const calculatedMembershipId =
    membershipBenefits?.membership?.id ?? null;

  const expectedPayable = Number(localPayment.payable_amount);
  const expectedActual = Number(localPayment.actual_amount);
  const calculatedPayable = Number(checkoutTotals.payableAmount);
  const calculatedActual = Number(checkoutTotals.actualAmount);
  if (
    !Number.isFinite(expectedPayable) ||
    !Number.isFinite(expectedActual) ||
    Math.round(expectedPayable * 100) !==
      Math.round(calculatedPayable * 100) ||
    Math.round(expectedActual * 100) !==
      Math.round(calculatedActual * 100)
  ) {
    return res.status(409).json({
      success: false,
      message:
        "Captured payment requires reconciliation because checkout totals changed",
      paymentId: localPayment.id,
      paymentStatus: localPayment.status,
    });
  }

  if (calculatedMembershipId !== persistedMembershipId) {
    return res.status(409).json({
      success: false,
      message:
        "Captured payment requires reconciliation because the selected membership no longer matches the payment",
      paymentId: localPayment.id,
      paymentStatus: localPayment.status,
    });
  }
}


/* =====================================================
   MEMBERSHIP PAYMENT
===================================================== */

if (
  (paymentType || "").toUpperCase() ===
  "MEMBERSHIP"
) {

  const planResult =
    await pool.query(
      `
        SELECT *
        FROM lkp_subscription_plans
        WHERE id = $1
      `,
      [membershipPlanId]
    );


  const plan =
    planResult.rows[0];


  if (!plan) {
    return res.status(404).json({
      success: false,
      message:
        "Membership plan not found",
    });
  }

  if (
    Math.round(Number(plan.plan_price) * 100) !==
    Math.round(expectedAmount * 100)
  ) {
    return res.status(409).json({
      success: false,
      message:
        "Captured membership payment amount does not match its persisted plan price",
      paymentId: localPayment.id,
    });
  }


  const expiryDate =
    new Date();


  expiryDate.setFullYear(
    expiryDate.getFullYear() + 1
  );


  /* =================================================
     CUSTOMER
  ================================================= */

  const assignmentResult =
    await pool.query(
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
      [userId]
    );


  const customer =
    assignmentResult.rows[0];


  if (!customer) {
    return res.status(404).json({
      success: false,
      message:
        "Customer account not found",
    });
  }


  /* =================================================
     DEFAULT ASSIGNMENT
  ================================================= */

  let assignedBy =
    customer.assigned_by ||
    customer.created_by ||
    null;


  let assignedRoleId = null;
  let assignedRole = null;


  if (assignedBy) {
    const assignedUserResult =
      await pool.query(
        `
          SELECT role
          FROM user_login
          WHERE user_id = $1
          LIMIT 1
        `,
        [assignedBy]
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

  let validatedReferralCode =
    null;


  if (
    typeof referralCode ===
      "string" &&
    referralCode.trim() !== ""
  ) {

    const cleanReferralCode =
      referralCode.trim();


    const referralResult =
      await pool.query(
        `
          SELECT
            ul.id AS referrer_user_id,
            ul.user_id AS referral_user_id,
            ul.role
          FROM user_login ul
          WHERE ul.user_id = $1
            AND ul.is_active = 1
            AND ul.role IN (3, 4)
          LIMIT 1
        `,
        [cleanReferralCode]
      );


    const referrer =
      referralResult.rows[0];


    if (!referrer) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid referral code",
      });
    }


    if (
      String(
        referrer.referrer_user_id
      ) ===
      String(userId)
    ) {
      return res.status(400).json({
        success: false,
        message:
          "You cannot use your own referral code",
      });
    }


    assignedBy =
      referrer.referral_user_id;


    assignedRoleId = Number(referrer.role);
    assignedRole = getRoleName(assignedRoleId);


    validatedReferralCode =
      referrer.referral_user_id;
  }
      /* =================================================
         CREATE MEMBERSHIP
      ================================================= */

      const membership =
        await Membership.createMembership({
          userId:
            userId,

          planId:
            plan.id,

          paymentId:
            payment.id,

          walletBalance:
            plan.wallet_bonus,

          discountPercent:
            plan.discount_percentage,

          monthlyClaim:
            plan.monthly_claim,

          expiryDate,

          termsAndConditions:
            true,

          assignedBy,

          assignedRole,

          referralCode:
            validatedReferralCode,
        });


      /* =================================================
         PAYMENT LOG
      ================================================= */

      try {
        await Payment.createPaymentLog({
          user_id:
            userId,

          order_id:
            membership.id,

          order_type:
            "MEMBERSHIP",

          payment_request: {
            razorpay_order_id,

            razorpay_payment_id,

            amount:
              razorpayPayment.amount,

            currency:
              razorpayPayment.currency,
          },

          payment_response:
            razorpayPayment,
        });


        console.log(
          `Payment log created for membership ${membership.id}`
        );

      } catch (paymentLogError) {
        console.error(
          "MEMBERSHIP PAYMENT LOG ERROR:",
          paymentLogError.message
        );
      }


      /* =================================================
         WHATSAPP SUBSCRIPTION
      ================================================= */

      try {
        if (customer?.mobile) {
          await sendSubscriptionWhatsApp({
            mobile:
              customer.mobile,

            customerName:
              customer.full_name ||
              "Customer",

            planName:
              plan.plan_name ||
              plan.name ||
              "Subscription",

            walletAmount:
              Number(
                plan.wallet_bonus || 0
              ).toFixed(2),

            validity:
              "1 Year",
          });


          console.log(
            `WHATSAPP SUBSCRIPTION SENT FOR MEMBERSHIP ${membership.id}`
          );
        }

      } catch (whatsappError) {
        console.error(
          "WHATSAPP SUBSCRIPTION FAILED:",
          whatsappError.message
        );
      }


      /* =================================================
         CREATE IN-APP MEMBERSHIP NOTIFICATION
      ================================================= */
try {
  const notification =
    await Notification.createNotification({
      userId: userId,

      title:
        "🎉 Membership Activated!",

      message:
        `Your membership has been activated successfully.\n` +
        `Plan: ${plan.plan_name || plan.name || "Membership"} 🌱`,

      type:
        "MEMBERSHIP_ACTIVATED",

      referenceId:
        membership.id,
    });

  console.log(
    `MEMBERSHIP NOTIFICATION CREATED FOR USER ${userId}`
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
    [userId]
  );

  const fcmToken =
    userResult.rows[0]?.fcm_token;

  if (fcmToken) {
    await sendPushNotification({
      fcmToken,

      title:
        notification.title,

      body:
        notification.message,

      data: {
        userId:
          userId,

        type:
          "MEMBERSHIP_ACTIVATED",

        membershipId:
          String(membership.id),
      },
    });

    console.log(
      `MEMBERSHIP push notification sent for membership ${membership.id}`
    );

  } else {
    console.log(
      `No FCM token found for user ${userId}`
    );
  }

} catch (notificationError) {
  console.error(
    "MEMBERSHIP NOTIFICATION FAILED:",
    notificationError.message
  );
}


      /* =================================================
         UPDATE REFERRAL ASSIGNMENT
      ================================================= */

      if (
        validatedReferralCode &&
        assignedBy
      ) {
        await pool.query(
          `
            UPDATE user_login
            SET assigned_by = $1
            WHERE user_id = $2
              AND is_active = 1
          `,
          [
            assignedBy,
            userId,
          ]
        );
      }


      /* =================================================
         PROCESS VENDOR / RESELLER BENEFIT
      ================================================= */

const membershipBenefitResult =
  await processMembershipBenefit({
    membershipId:
      membership.id,

    customerId:
      userId,

    assignedBy,

    assignedRole: assignedRoleId,

    subscriptionAmount:
      Number(plan.plan_price),
  });

await updateLocalPayment("PAID");
await createPaymentSuccessNotification();

console.log(
  "===== MEMBERSHIP WALLET BENEFITS ====="
);


console.log(
  membershipBenefitResult
);


/* =================================================
   VENDOR / RESELLER REFERRAL NOTIFICATION
================================================= */

try {
  /*
   * No referral/assignment means there is nobody
   * to notify.
   */
  if (
    assignedBy &&
    assignedRoleId
  ) {

    let shouldNotifyReferral =
      false;


    /*
     * DIRECT VENDOR
     *
     * Vendor gets 20% benefit.
     * Send notification to the Vendor.
     */
    if (
      assignedRoleId === 3
    ) {
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
    if (
      assignedRoleId === 4
    ) {

      const resellerResult =
        await pool.query(
          `
            SELECT
              created_by
            FROM user_login
            WHERE user_id = $1
              AND role = 4
              AND is_active = 1
            LIMIT 1
          `,
          [assignedBy]
        );


      const reseller =
        resellerResult.rows[0];


      let parentVendor = null;


      if (
        reseller?.created_by
      ) {
        const parentVendorResult =
          await pool.query(
            `
              SELECT
                user_id
              FROM user_login
              WHERE user_id = $1
                AND role = 3
                AND is_active = 1
              LIMIT 1
            `,
            [reseller.created_by]
          );


        parentVendor =
          parentVendorResult.rows[0] || null;
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

      const referralBenefit =
        membershipBenefitResult.find(
          (benefit) =>
            String(
              benefit.beneficiaryId
            ) ===
            String(assignedBy)
        );


      /*
       * Safety check:
       * If there is no matching benefit, do not
       * create a misleading notification.
       */
      if (referralBenefit) {

        const notification =
          await Notification.createNotification({
            userId:
              assignedBy,

            title:
              "🎉 New Membership Referral",

            message:
  `Customer ${userId} took the ${
    plan.plan_name ||
    plan.name ||
    "Membership"
  } using your referral.\n` +
  `You received ${
    referralBenefit.benefitPercent
  }% benefit (₹${
    Number(
      referralBenefit.benefitAmount
    ).toFixed(2)
  }) from this membership.`,

            type:
              "MEMBERSHIP_REFERRAL",

            referenceId:
              membership.id,
          });


        console.log(
          `MEMBERSHIP REFERRAL NOTIFICATION CREATED FOR ${assignedRole} ${assignedBy}`
        );

        console.log(
          "MEMBERSHIP REFERRAL NOTIFICATION:",
          notification
        );
      }
    }
  }

} catch (notificationError) {

  /*
   * Notification failure must never break
   * successful membership activation or benefit
   * processing.
   */
  console.error(
    "MEMBERSHIP REFERRAL NOTIFICATION FAILED:",
    notificationError.message
  );
}


      return res.json({
        success: true,

        payment,

        membership,

        message:
          "Membership activated successfully.",
      });
    }
        /* =====================================================
       CREATE NORMAL ORDER
    ===================================================== */

    let createdOrder = null;


    if (
      (paymentType || "").toUpperCase() !==
      "MEMBERSHIP"
    ) {

      console.log(
        "===== CREATING NORMAL ORDER ====="
      );


      /* ===================================================
         VALIDATE ADDRESS
      =================================================== */

      if (!address_id) {
        return res.status(400).json({
          success: false,
          message:
            "Delivery address is required",
        });
      }

      const addressResult =
        await pool.query(
          `
            SELECT *
            FROM user_address
            WHERE id = $1
              AND user_id = $2
            LIMIT 1
          `,
          [
            address_id,
            userId,
          ]
        );


      const selectedAddress =
        addressResult.rows[0];


      if (!selectedAddress) {
        return res.status(400).json({
          success: false,
          message:
            "Selected address does not belong to this user",
        });
      }


      console.log(
        "SELECTED ADDRESS:",
        selectedAddress
      );


      /* ===================================================
         BUY NOW ORDER
      =================================================== */

      if (
        buyNow &&
        productId
      ) {

        const buyNowQuantity = Number(quantity ?? 1);


        console.log(
          "===== BUY NOW ORDER ====="
        );


        console.log({
          userId,
          productId,
          quantity:
            buyNowQuantity,
          address_id,
        });


        createdOrder =
  await Order.createBuyNowOrder(
    userId,
    address_id,
    productId,
    buyNowQuantity,
    {
      cartItems: checkoutItems,
      checkoutTotals,
      membershipId: persistedMembershipId,
      gatewayOrderId: razorpay_order_id,
    }
  );


      } else {

        /* =================================================
           NORMAL CART ORDER
        ================================================= */

        console.log(
          "===== CART ORDER ====="
        );


       createdOrder =
  await Order.createOrder(
    userId,
    address_id,
    false,
    null,
    1,
    {
      cartItems: checkoutItems,
      checkoutTotals,
      membershipId: persistedMembershipId,
      gatewayOrderId: razorpay_order_id,
    }
  );
      }


      if (!createdOrder) {
        return res.status(500).json({
          success: false,
          message:
            "Failed to create order",
        });
      }


      console.log(
        "ORDER CREATED:",
        createdOrder
      );

      /* ===================================================
         ORDER ID
      =================================================== */

      const createdOrderDbId = createdOrder.id;
      const createdOrderId = createdOrder.order_id;

      if (!createdOrderDbId || !createdOrderId) {
        return res.status(500).json({
          success: false,
          message:
            "Order created but order ID was not returned",
        });
      }


      /* ===================================================
         SAVE ORDER BREAKDOWN
      =================================================== */

      const actualAmount = checkoutTotals.actualAmount;
      const membershipDiscount = checkoutTotals.membershipDiscount;
      const walletClaim = checkoutTotals.walletClaim;
      const deliveryCharge = checkoutTotals.deliveryCharge;
      const payableAmount = checkoutTotals.payableAmount;


      console.log(
        "===== FINAL ORDER BREAKDOWN ====="
      );


      console.log({
        orderId:
          createdOrderId,

        actualAmount,

        membershipDiscount,

        walletClaim,

        deliveryCharge,

        payableAmount,
      });


try {
  await verificationLockClient.query("BEGIN");

  if (Number(createdOrder.membership_id || 0) !== Number(persistedMembershipId || 0)) {
    throw new Error("Created order membership does not match its payment");
  }

  if (persistedMembershipId !== null) {
    const litresUsed = await Membership.calculateOrderLitres(
      createdOrder.item_id,
      createdOrder.quantity,
      verificationLockClient
    );

    await Membership.updateMembershipUsage({
      userId,
      membershipId: persistedMembershipId,
      litresUsed,
      walletUsed: Number(createdOrder.wallet_claim || 0),
      orderId: createdOrder.order_id,
      client: verificationLockClient,
    });
  }

const updatedOrderResult = await verificationLockClient.query(
  `
  UPDATE orders
  SET
    payment_status = 'PAID',
    coupon_discount = $5,
    payable_amount = $6,
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
    createdOrderDbId,
    razorpay_order_id,
    persistedMembershipId,
    Number(verifiedCouponDiscount || 0),
    Number(checkoutTotals.payableAmount),
  ]
);


if (verifiedCoupon && payment) {
  const couponUserResult = await verificationLockClient.query(
    `
    SELECT id
    FROM user_login
    WHERE user_id = $1
      AND is_active = 1
    LIMIT 1
    `,
    [req.authenticatedUser.id]
  );

  const couponNumericUserId = couponUserResult.rows[0]?.id;

  if (!couponNumericUserId) {
    throw new Error("Could not resolve numeric user ID for coupon transaction");
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
    verificationLockClient
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
      AND status = 'PENDING'
      AND membership_id IS NOT DISTINCT FROM $8::integer
    RETURNING *
    `,
    [
      createdOrder.order_id,
      paymentId,
      method,
      upiTransactionId,
      payment.id,
      userId,
      razorpay_order_id,
      persistedMembershipId,
    ]
  );

  if (!updatedOrderResult.rows[0] || !updatedPaymentResult.rows[0]) {
    throw new Error("Order and captured payment could not be reconciled");
  }

  await verificationLockClient.query("COMMIT");
  createdOrder = updatedOrderResult.rows[0];
  payment = updatedPaymentResult.rows[0];
  await createPaymentSuccessNotification();

  console.log(
    `Order ${createdOrderId} marked as PAID`
  );

  console.log(
    `Transaction order ID ${razorpay_order_id} saved`
  );

} catch (orderPaymentError) {
  await verificationLockClient.query("ROLLBACK");
  console.error(
    "ORDER PAYMENT STATUS ERROR:",
    orderPaymentError.message
  );

  throw orderPaymentError;
}


/* ===================================================
   CREATE ORDER PAYMENT LOG
=================================================== */

try {

  await Payment.createPaymentLog({
    user_id:
      userId,

    order_id:
     createdOrderDbId,

    order_type:
      "ORDER",

    payment_request: {
      razorpay_order_id,

      razorpay_payment_id,

      amount:
        razorpayPayment.amount,

      currency:
        razorpayPayment.currency,
    },

    payment_response:
      razorpayPayment,
  });

  console.log(
    `Order payment log created for order ${createdOrderId}`
  );

} catch (paymentLogError) {

  console.error(
    "ORDER PAYMENT LOG ERROR:",
    paymentLogError.message
  );
}


/* ===================================================
   ORDER SUCCESS NOTIFICATION
=================================================== */
try {

  const notification =
    await Notification.createNotification({
      userId:
        userId,

      title:
        "Order Placed Successfully",

      message:
        `Your order #${createdOrderId} has been placed successfully.`,

      type:
        "ORDER_PLACED",

      referenceId:
         createdOrderDbId,
    });

  console.log(
    `ORDER_PLACED notification created for order ${createdOrderId}`
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
    [userId]
  );

  const fcmToken =
    userResult.rows[0]?.fcm_token;

  if (fcmToken) {

    await sendPushNotification({
      fcmToken,

      title:
        notification.title,

      body:
        notification.message,

      data: {
        userId:
          userId,

        type:
          "ORDER_PLACED",

        orderId:
          String(createdOrderId),
      },
    });

    console.log(
      `ORDER_PLACED push notification sent for order ${createdOrderId}`
    );

  } else {

    console.log(
      `No FCM token found for user ${userId}`
    );

  }

} catch (notificationError) {

  console.error(
    "ORDER NOTIFICATION ERROR:",
    notificationError.message
  );
}


/* ===================================================
   WHATSAPP ORDER CONFIRMATION
=================================================== */

try {

  const customerResult =
    await pool.query(
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
      [createdOrder.address_id, userId]
    );


  const customer =
    customerResult.rows[0];


  if (
    customer &&
    customer.mobile_no
  ) {

    await sendOrderConfirmation({
      mobile:
        customer.mobile_no,

      customerName:
        customer.full_name ||
        "Customer",

      orderId:
        createdOrderId,

      amount:
        Number(
          payableAmount
        ).toFixed(2),

      orderSummary:
        "Order placed successfully",
    });


    console.log(
      `ORDER WHATSAPP SENT FOR ORDER ${createdOrderId}`
    );
  }

} catch (whatsappError) {

  console.error(
    "ORDER WHATSAPP FAILED:",
    whatsappError.message
  );
}


/* ===================================================
   FINAL NORMAL ORDER RESPONSE
=================================================== */

return res.json({
  success: true,

  payment,

  order:
    createdOrder,

  orderId:
    createdOrderId,

  membershipBenefits,

  actualAmount,

  membershipDiscount,

  walletClaim,

  deliveryCharge,

  payableAmount,

  message:
    "Payment verified and order created successfully.",
});
    }



/* =====================================================
   FALLBACK RESPONSE
===================================================== */

return res.json({
  success: true,

  payment,

  message:
    "Payment verified successfully.",
});


} catch (error) {

  console.error(
    "VERIFY PAYMENT ERROR:",
    error
  );

  if (error.code === "COUPON_ALREADY_USED") {
    return res.status(409).json({
      success: false,
      message: "You have already used this coupon",
    });
  }

  return res.status(500).json({
    success: false,

    message:
      error.message ||
      "Payment verification failed",
  });
} finally {
  if (verificationLockClient) {
    if (couponVerificationLockKey) {
      try {
        await verificationLockClient.query(
          "SELECT pg_advisory_unlock(hashtext($1))",
          [couponVerificationLockKey]
        );
      } catch (unlockError) {
        console.error(
          "COUPON VERIFICATION LOCK RELEASE ERROR:",
          unlockError.message
        );
      }
    }

    try {
      if (verificationLockKey) {
        await verificationLockClient.query(
          "SELECT pg_advisory_unlock(hashtext($1))",
          [verificationLockKey]
        );
      }
    } catch (unlockError) {
      console.error(
        "RAZORPAY VERIFICATION LOCK RELEASE ERROR:",
        unlockError.message
      );
    } finally {
      verificationLockClient.release();
    }
  }
}
};


/* =========================================================
   GET PAYMENTS
========================================================= */

const getPayments = async (req, res) => {
  try {

    const {
      user_id,
      order_id,
    } = req.query;


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

    console.error(
      "GET PAYMENTS ERROR:",
      error
    );


    return res.status(500).json({
      success: false,
      message:
        error.message ||
        "Failed to fetch payments",
    });
  }
};


/* =========================================================
   CHECKOUT SUMMARY
========================================================= */

const checkoutSummary = async (req, res) => {
  try {

const {
  user_id,
  buyNow,
  productId,
  quantity,
  couponCode,
} = req.body;

    const publicUserId = user_id;


    if (!publicUserId) {
      return res.status(400).json({
        success: false,
        message:
          "User ID is required",
      });
    }


    /* =====================================================
       CART ITEMS
    ===================================================== */

    let cartItems = [];


    /* =====================================================
       BUY NOW
    ===================================================== */

    if (
      buyNow &&
      productId
    ) {

      const productResult =
        await pool.query(
          `
            SELECT
              id,
              name,
              price,
              weight,
              stock
            FROM lkp_products
            WHERE id = $1
              AND is_active = 1
            LIMIT 1
          `,
          [productId]
        );


      if (
        productResult.rows.length === 0
      ) {

        return res.status(404).json({
          success: false,
          message:
            "Product not found",
        });
      }


      const product =
        productResult.rows[0];


      const buyNowQuantity = Number(quantity ?? 1);


      /*
       * Create the same in-memory cart
       * structure used by createOrder()
       * and verifyPayment().
       *
       * Nothing is inserted into cart_items.
       */
      cartItems = [
        {
          cart_id: null,

          user_id:
            publicUserId,

          product_id:
            product.id,

          product_name:
            product.name,

          price:
            Number(
              product.price || 0
            ),

          weight:
            Number(
              product.weight || 0
            ),

          stock:
            Number(
              product.stock || 0
            ),

          quantity:
            buyNowQuantity,

          total_price:
            Number(
              product.price || 0
            ) *
            buyNowQuantity,
        },
      ];

    } else {

      /* =================================================
         NORMAL CART
      ================================================= */

      cartItems =
        await Cart.getItems(
          publicUserId
        );
    }


    /* =====================================================
       EMPTY CART
    ===================================================== */

    if (
      !cartItems ||
      cartItems.length === 0
    ) {

      return res.status(400).json({
        success: false,
        message:
          "Cart is empty",
      });
    }


    /* =====================================================
       MEMBERSHIP BENEFITS
    ===================================================== */

    const checkoutTotals = await calculateCheckoutTotals(
      publicUserId,
      cartItems
    );
    const membershipBenefits = checkoutTotals.membershipBenefits;
    const subtotal = checkoutTotals.subtotal;
    const totalLitres = checkoutTotals.totalLitres;
    const membershipDiscount = checkoutTotals.membershipDiscount;
    const walletClaim = checkoutTotals.walletClaim;
    const deliveryCharge = checkoutTotals.deliveryCharge;
    const deliverySavings = checkoutTotals.deliverySavings;
    const expectedDeliveryDays = checkoutTotals.expectedDeliveryDays;

const actualAmount = checkoutTotals.actualAmount;
const payableAmount = Number(checkoutTotals.payableAmount);

let coupon = null;
let couponDiscount = 0;
let finalPayableAmount = payableAmount;


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
    coupon.coupon_percentage
  );
  couponDiscount = couponTotals.couponDiscount;
  finalPayableAmount = couponTotals.payableAmount;
}

    console.log(
      "===== CHECKOUT SUMMARY ====="
    );


    console.log({
      user_id:
        publicUserId,

      buyNow:
        !!buyNow,

      productId:
        productId || null,

      quantity:
        quantity || null,

      subtotal,

      actualAmount,

      membershipDiscount,

      walletClaim,

      deliveryCharge,

      expectedDeliveryDays,

      payableAmount,
    });


    /* =====================================================
       RESPONSE
    ===================================================== */

  return res.json({
  success: true,
  cartItems,
  membershipBenefits,
  subtotal,
  actualAmount,
  membershipDiscount,
  walletClaim,
  deliveryCharge,
  deliverySavings,
  expectedDeliveryDays,
  payableAmount,
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

    console.error(
      "CHECKOUT SUMMARY ERROR:",
      error
    );


    return res.status(500).json({
      success: false,

      message:
        error.message ||
        "Failed to calculate checkout summary",
    });
  }
};


/* =========================================================
   MODULE EXPORTS
========================================================= */

module.exports = {
  createOrder,
  verifyPayment,
  getPayments,
  checkoutSummary,
};