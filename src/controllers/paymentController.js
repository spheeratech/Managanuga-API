const Order = require("../models/Order");
const Payment = require("../models/Payment");
const Notification = require("../models/Notification");
const razorpayService = require("../services/razorpayService");
const Membership = require("../models/Membership");
const pool = require("../../db");
const xpressbeesService = require("../services/xpressbeesService");
const Cart = require("../models/Cart");
const User = require("../models/User");

const {
  sendPushNotification,
} = require("../services/fcmService");

const {
  calculateMembershipBenefits,
} = require("../services/membershipCheckoutService");

const {
  processMembershipBenefit,
} = require("../services/membershipBenefitService");

const {
  sendOrderConfirmation,
  sendSubscriptionWhatsApp,
} = require("../services/whatsappService");
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


    let actualAmount = 0;
    let payableAmount = 0;


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
            FROM subscription_plans
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
              FROM products
              WHERE id = $1
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


        const buyNowQuantity =
          Math.max(
            1,
            Number(quantity || 1)
          );


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


      /*
       * Use the SAME membership calculation
       * that Checkout Summary uses.
       */
      const benefits =
        await calculateMembershipBenefits(
          publicUserId,
          cartItems
        );


      /*
       * Calculate actual item subtotal.
       */
      const subtotal =
        cartItems.reduce(
          (sum, item) =>
            sum +
            Number(item.price || 0) *
            Number(item.quantity || 0),
          0
        );


      actualAmount =
        subtotal;


      if (benefits) {
        /*
         * MEMBERSHIP USER
         *
         * payableAmount comes from the central
         * membership calculation service.
         */
        payableAmount =
          Number(
            benefits.payableAmount
          );


        console.log(
          "Membership Benefits:",
          benefits
        );
      } else {
        /*
         * NORMAL USER
         *
         * Existing delivery charge remains ₹40.
         */
        payableAmount =
          subtotal + 40;
      }
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

  const razorpayTestAmount = 1;

const razorpayOrder =
  await razorpayService.createRazorpayOrder(
    razorpayTestAmount
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
        order_id:
          order_id || null,

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

        razorpayTestAmount,
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


    /* =====================================================
       FIND LOCAL PAYMENT
    ===================================================== */

    const existingPayment =
  await pool.query(
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


/* =====================================================
   VERIFY RAZORPAY AMOUNT

   TEST MODE:
   Razorpay must have charged ₹1.

   DO NOT compare this with the real
   order payable amount.
===================================================== */

const razorpayAmount =
  Number(razorpayPayment.amount) /
  100;


const expectedAmount = 1;

console.log(
  "Expected Razorpay Test Amount:",
  expectedAmount
);


console.log(
  "Razorpay Amount:",
  razorpayAmount
);


if (
  Math.abs(
    razorpayAmount -
    expectedAmount
  ) > 0.01
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


const method =
  razorpayPayment.method ||
  null;


const upiTransactionId =
  razorpayPayment
    ?.acquirer_data
    ?.upi_transaction_id ||
  null;


/* =====================================================
   UPDATE LOCAL PAYMENT

   IMPORTANT:
   Keep REAL actual/payable amounts.
===================================================== */

let payment =
  await Payment.updateByTnxOrderId(
    razorpay_order_id,
    {
      status: "PAID",

      payment_id:
        paymentId,

      upi_transaction_id:
        upiTransactionId,

      method,

      actual_amount:
        localPayment.actual_amount,

      payable_amount:
        localPayment.payable_amount,
    }
  );


if (!payment) {
  return res.status(404).json({
    success: false,
    message:
      "Unable to update payment",
  });
}


console.log(
  "PAYMENT UPDATED:",
  payment
);


/* =====================================================
   PAYMENT SUCCESS NOTIFICATION
===================================================== */

try {
  await Notification.createNotification({
    userId:
      userId,

    title:
      "Payment Successful",

    message:
      "Your payment was successfully completed.",

    type:
      "PAYMENT_SUCCESS",

    referenceId:
      payment.id,
  });


  console.log(
    `Payment notification created for payment ${payment.id}`
  );

} catch (notificationError) {
  console.error(
    "Payment Notification Error:",
    notificationError
  );
}


await Membership.checkAndResetMonthlyBenefits(
  userId
);


/* =====================================================
   MEMBERSHIP BENEFITS
===================================================== */

let membershipBenefits =
  null;


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
          FROM products
          WHERE id = $1
          LIMIT 1
        `,
        [productId]
      );


    if (
      productResult.rows.length
    ) {
      const product =
        productResult.rows[0];


      const buyNowQuantity =
        Math.max(
          1,
          Number(quantity || 1)
        );


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


  if (
    cartItems &&
    cartItems.length > 0
  ) {
    membershipBenefits =
      await calculateMembershipBenefits(
        userId,
        cartItems
      );
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
        FROM subscription_plans
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


  let assignedRole =
    null;


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


    assignedRole =
      assignedUserResult
        .rows[0]
        ?.role || null;
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
            AND ul.role IN ('VENDOR', 'RESELLER')
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


    assignedRole =
      referrer.role;


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

    assignedRole,

    subscriptionAmount:
      Number(plan.plan_price),
  });


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
    assignedRole
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
      assignedRole === "VENDOR"
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
      assignedRole === "RESELLER"
    ) {

      const resellerResult =
        await pool.query(
          `
            SELECT
              created_by
            FROM user_login
            WHERE user_id = $1
              AND role = 'RESELLER'
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
                AND role = 'VENDOR'
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
            FROM addresses
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

        const buyNowQuantity =
          Math.max(
            1,
            Number(quantity || 1)
          );


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
    buyNowQuantity
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
    address_id
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
  console.error(
    "Created order does not contain required order IDs:",
    createdOrder
  );

  return res.status(500).json({
    success: false,
    message: "Order created but order ID was not returned",
  });
}
        console.error(
          "Created order does not contain order ID:",
          createdOrder
        );


        return res.status(500).json({
          success: false,
          message:
            "Order created but order ID was not returned",
        });
      }


      /* ===================================================
         SAVE ORDER BREAKDOWN
      =================================================== */

      const actualAmount =
        membershipBenefits
          ?.actualAmount ??
        Number(
          localPayment.actual_amount ||
          0
        );


      const membershipDiscount =
        membershipBenefits
          ?.membershipDiscount ??
        0;


      const walletClaim =
        membershipBenefits
          ?.walletClaim ??
        0;


      const deliveryCharge =
        membershipBenefits
          ? Number(
              membershipBenefits.deliveryCharge ||
              0
            )
          : 40;


      const payableAmount =
        membershipBenefits
          ?.payableAmount ??
        (
          Number(actualAmount) +
          Number(deliveryCharge)
        );


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


      /* ===================================================
         INSERT / UPDATE ORDER BREAKDOWN
      =================================================== */

      try {

        await pool.query(
          `
            UPDATE orders
            SET
              actual_amount = $1,
              membership_discount = $2,
              wallet_claim = $3,
              delivery_charge = $4,
              payable_amount = $5,
              updated_at = CURRENT_TIMESTAMP
            WHERE id = $6
          `,
          [
            actualAmount,
            membershipDiscount,
            walletClaim,
            deliveryCharge,
            payableAmount,
            createdOrderDbId,
          ]
        );


        console.log(
          `Order breakdown updated for order ${createdOrderId}`
        );

      } catch (breakdownError) {

        console.error(
          "ORDER BREAKDOWN UPDATE ERROR:",
          breakdownError.message
        );

        /*
         * Do not fail an already-created order
         * only because the breakdown update failed.
         */
      }

/* ===================================================
   LINK PAYMENT TO ORDER
=================================================== */

try {

  await pool.query(
    `
      UPDATE payments
      SET
        order_id = $1,
        tnx_order_id = $2,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
    `,
    [
      createdOrder.order_id,
      createdOrder.tnx_order_id || razorpay_order_id,
      payment.id,
    ]
  );

  console.log(
    `Payment ${payment.id} linked to MGO order ${createdOrder.order_id}`
  );

} catch (paymentLinkError) {

  console.error(
    "PAYMENT ORDER LINK ERROR:",
    paymentLinkError.message
  );

  throw paymentLinkError;
}


/* ===================================================
   UPDATE ORDER PAYMENT STATUS
=================================================== */

try {

  await pool.query(
    `
      UPDATE orders
      SET
        tnx_order_id = $1,
        payment_status = 'PAID',
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
    `,
    [
      razorpay_order_id,
      createdOrderDbId,
    ]
  );

  console.log(
    `Order ${createdOrderId} marked as PAID`
  );

  console.log(
    `Transaction order ID ${razorpay_order_id} saved`
  );

  /* ===================================================
   UPDATE MEMBERSHIP USAGE
=================================================== */

if (membershipBenefits) {

  try {

    await Membership.updateMembershipUsage({
      userId,

      litresUsed:
        membershipBenefits.totalLitres,

      walletUsed:
        membershipBenefits.walletClaim,

      orderId:
        createdOrder.id,
    });

    console.log(
      `Membership usage updated for order ${createdOrder.order_id}`
    );

  } catch (membershipUsageError) {

    console.error(
      "MEMBERSHIP USAGE UPDATE ERROR:",
      membershipUsageError.message
    );

    throw membershipUsageError;
  }
}

} catch (orderPaymentError) {

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
      createdOrderId,

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
        createdOrderId,
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
        FROM addresses a
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


  return res.status(500).json({
    success: false,

    message:
      error.message ||
      "Payment verification failed",
  });
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


    if (user_id) {

      payments =
        await Payment.getPaymentsByUserId(
          user_id
        );

    } else if (order_id) {

      payments =
        await Payment.getPaymentsByOrderId(
          order_id
        );

    } else {

      payments =
        await Payment.getAllPayments();
    }


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
            FROM products
            WHERE id = $1
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


      const buyNowQuantity =
        Math.max(
          1,
          Number(quantity || 1)
        );


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

    const membershipBenefits =
      await calculateMembershipBenefits(
        publicUserId,
        cartItems
      );


    /* =====================================================
       SUBTOTAL
    ===================================================== */

    const subtotal =
      cartItems.reduce(
        (
          total,
          item
        ) =>
          total +
          (
            Number(
              item.price || 0
            ) *
            Number(
              item.quantity || 0
            )
          ),
        0
      );


    /* =====================================================
       MEMBERSHIP DISCOUNT
    ===================================================== */

    const membershipDiscount =
      Number(
        membershipBenefits
          ?.membershipDiscount || 0
      );


    /* =====================================================
       WALLET CLAIM
    ===================================================== */

    const walletClaim =
      Number(
        membershipBenefits
          ?.walletClaim || 0
      );


    /* =====================================================
       DELIVERY CHARGE
    ===================================================== */

    const totalLitres =
      cartItems.reduce(
        (total, item) =>
          total +
          Number(item.weight || 0) *
          Number(item.quantity || 0),
        0
      );

    const deliveryRuleResult =
      await pool.query(
        `
          SELECT
            delivery_cart_count,
            delivery_charges,
            expected_delivery_days
          FROM delivery_charges
          WHERE is_active = 1
          ORDER BY id DESC
          LIMIT 1
        `
      );

    if (
      !deliveryRuleResult.rows.length
    ) {
      return res.status(500).json({
        success: false,
        message:
          "Delivery charge configuration not found",
      });
    }

    const deliveryCartCount =
      Number(
        deliveryRuleResult.rows[0]
          .delivery_cart_count
      );

    const configuredDeliveryCharge =
      Number(
        deliveryRuleResult.rows[0]
          .delivery_charges
      );

    const expectedDeliveryDays =
      deliveryRuleResult.rows[0]
        .expected_delivery_days;

    const deliveryCharge =
      totalLitres >= deliveryCartCount
        ? 0
        : configuredDeliveryCharge;

    const deliverySavings =
      deliveryCharge === 0
        ? configuredDeliveryCharge
        : 0;


    /* =====================================================
       ACTUAL AMOUNT
    ===================================================== */

    const actualAmount =
      Number(
        membershipBenefits
          ?.actualAmount ??
        subtotal
      );


    /* =====================================================
       PAYABLE AMOUNT
    ===================================================== */

    const payableAmount =
      Number(actualAmount) -
      Number(membershipDiscount) -
      Number(walletClaim) +
      Number(deliveryCharge);


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