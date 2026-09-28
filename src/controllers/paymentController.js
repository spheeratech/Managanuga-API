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
   RESOLVE PUBLIC MGU USER ID
========================================================= */

const resolveUserId = async (userId) => {
  if (
    typeof userId === "string" &&
    userId.startsWith("MGU")
  ) {
    const result = await pool.query(
      `
      SELECT id
      FROM user_login
      WHERE user_id = $1
        AND is_active = true
      LIMIT 1
      `,
      [userId]
    );

    if (!result.rows[0]) {
      return null;
    }

    return result.rows[0].id;
  }

  return userId;
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
      entity_id,
      paymentType,
      membershipPlanId,
    } = req.body;

    let resolvedEntityId =
      await resolveUserId(entity_id);

    if (!resolvedEntityId) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const paymentTypeUpper =
      (paymentType || "ORDER").toUpperCase();

    let actualAmount = 0;
    let payableAmount = 0;


    /* =====================================================
       MEMBERSHIP PAYMENT
    ===================================================== */

    if (paymentTypeUpper === "MEMBERSHIP") {
      const planResult = await pool.query(
        `
        SELECT *
        FROM subscription_plans
        WHERE id = $1
        `,
        [membershipPlanId]
      );

      const plan = planResult.rows[0];

      if (!plan) {
        return res.status(404).json({
          success: false,
          message: "Membership plan not found",
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

    if (paymentTypeUpper !== "MEMBERSHIP") {
      const cartItems =
        await Cart.getItems(
          "USER",
          resolvedEntityId
        );

      if (!cartItems || cartItems.length === 0) {
        return res.status(400).json({
          success: false,
          message: "Cart is empty",
        });
      }

      const benefits =
        await calculateMembershipBenefits(
          resolvedEntityId,
          cartItems
        );

      const subtotal =
        cartItems.reduce(
          (sum, item) =>
            sum +
            Number(item.price || 0) *
              Number(item.quantity || 0),
          0
        );

      actualAmount = subtotal;

      if (benefits) {
        payableAmount =
          Number(benefits.payableAmount);

        console.log(
          "Membership Benefits:",
          benefits
        );
      } else {
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
        message: "Invalid payment amount",
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
      message: err.message,
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
       RESOLVE USER
    ===================================================== */

    const resolvedUserId =
      await resolveUserId(userId);

    if (!resolvedUserId) {
      return res.status(404).json({
        success: false,
        message: "User account not found",
      });
    }


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
        message: "Invalid signature",
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
          resolvedUserId,

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
      resolvedUserId
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
      const cartItems =
        await Cart.getItems(
          "USER",
          resolvedUserId
        );

      if (cartItems && cartItems.length > 0) {
        membershipBenefits =
          await calculateMembershipBenefits(
            resolvedUserId,
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
          WHERE ul.id = $1
            AND ul.is_active = true
          LIMIT 1
          `,
          [resolvedUserId]
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
              AND ul.is_active = true
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
          String(resolvedUserId)
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
            resolvedUserId,

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
            customer.login_user_id,

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
  await Notification.createNotification({
    userId: customer.login_user_id,
    title: "🎉 Membership Activated!",
    message:
      `Your membership has been activated successfully.\n` +
      `Plan: ${plan.plan_name || plan.name || "Membership"} 🌱`,
    type: "MEMBERSHIP_ACTIVATED",
    referenceId: membership.id,
  });

  console.log(
    `MEMBERSHIP NOTIFICATION CREATED FOR USER ${customer.login_user_id}`
  );
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
          WHERE id = $2
            AND is_active = true
          `,
          [
            assignedBy,
            resolvedUserId,
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
            customer.login_user_id,

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

    let order;

    if (buyNow) {
      order =
        await Order.createBuyNowOrder(
          "USER",
          resolvedUserId,
          address_id,
          productId,
          quantity || 1,
          userId
        );

    } else {
      order =
        await Order.createOrder(
          "USER",
          resolvedUserId,
          address_id,
          false,
          null,
          1,
          userId
        );
    }


    if (!order) {
      return res.status(400).json({
        success: false,
        message:
          "Order creation failed",
      });
    }

await pool.query(
  `
  UPDATE orders
  SET tnx_order_id = $1
  WHERE id = $2
  `,
  [
    razorpay_order_id,
    order.id,
  ]
);

order.tnx_order_id = razorpay_order_id;


/* =====================================================
   SAVE ORDER PRICE BREAKDOWN
===================================================== */

const actualOrderAmount = membershipBenefits
  ? Number(membershipBenefits.subtotal || 0)
  : Number(order.actual_amount || 0);

const membershipDiscount = membershipBenefits
  ? Number(
      membershipBenefits.membershipDiscount || 0
    )
  : 0;

const walletClaim = membershipBenefits
  ? Number(
      membershipBenefits.walletClaim || 0
    )
  : 0;

const deliveryCharge = membershipBenefits
  ? Number(
      membershipBenefits.deliveryCharge || 0
    )
  : 40;

const finalPayableAmount = membershipBenefits
  ? Number(
      membershipBenefits.payableAmount || 0
    )
  : actualOrderAmount + deliveryCharge;

await pool.query(
  `
  UPDATE orders
  SET
    actual_amount = $1,
    membership_discount = $2,
    wallet_claim = $3,
    delivery_charge = $4,
    payable_amount = $5
  WHERE id = $6
  `,
  [
    actualOrderAmount,
    membershipDiscount,
    walletClaim,
    deliveryCharge,
    finalPayableAmount,
    order.id,
  ]
);

console.log(
  "===== ORDER PRICE BREAKDOWN SAVED ====="
);

console.log({
  orderId: order.id,
  mgoOrderId: order.order_id,
  actualAmount: actualOrderAmount,
  membershipDiscount,
  walletClaim,
  deliveryCharge,
  payableAmount: finalPayableAmount,
});


    /* =====================================================
       ORDER AMOUNT

       IMPORTANT:
       Do NOT compare order payable amount
       with Razorpay's ₹1 test amount.

       The order keeps its REAL amount.
    ===================================================== */

    const orderActualAmount =
      Number(order.actual_amount || 0);

    const orderPayableAmount =
      Number(order.payable_amount || 0);


    console.log(
      "===== ORDER AMOUNT ====="
    );

    console.log({
      orderActualAmount,
      orderPayableAmount,
      razorpayTestAmount:
        1,
    });


    /* =====================================================
       LINK PAYMENT TO MGO ORDER
    ===================================================== */

    payment =
      await Payment.linkPaymentToOrder({
        paymentId:
          payment.id,

        orderId:
          order.order_id,

        tnxOrderId:
          order.tnx_order_id ||
          razorpay_order_id,

        status:
          "PAID",
      });


    if (!payment) {
      return res.status(500).json({
        success: false,
        message:
          "Failed to link payment to order",
      });
    }


    /* =====================================================
       UPDATE ORDER PAYMENT STATUS
    ===================================================== */

    await pool.query(
      `
      UPDATE orders
      SET payment_status = 'PAID'
      WHERE id = $1
      `,
      [order.id]
    );


    console.log(
      "===== ORDER PAYMENT LINKED ====="
    );

    console.log({
      numericOrderId:
        order.id,

      mgoOrderId:
        order.order_id,

      razorpayOrderId:
        order.tnx_order_id ||
        razorpay_order_id,

      paymentId:
        payment.payment_id,

      actualAmount:
        orderActualAmount,

      payableAmount:
        orderPayableAmount,

      razorpayPaidAmount:
        razorpayAmount,
    });


    /* =====================================================
       ORDER PAYMENT LOG
    ===================================================== */

    try {
      await Payment.createPaymentLog({
        user_id:
          userId,

        order_id:
          order.id,

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
        `Payment log created for order ${order.id}`
      );

    } catch (paymentLogError) {
      console.error(
        "ORDER PAYMENT LOG ERROR:",
        paymentLogError.message
      );
    }


    /* =====================================================
       ORDER WHATSAPP
    ===================================================== */

    try {
      const orderDetails =
        await Order.getOrderById(
          order.id
        );

      const orderItems =
        await Order.getOrderItems(
          order.id
        );


      const totalItemCount =
        orderItems.reduce(
          (sum, item) =>
            sum +
            Number(
              item.quantity || 1
            ),
          0
        );


      const itemsCost =
        Number(
          order.actual_amount || 0
        );


      const membershipDiscount =
        Number(
          order.membership_discount ||
          0
        );


      const walletClaim =
        Number(
          order.wallet_claim || 0
        );


      const deliveryCharge =
        Number(
          order.delivery_charge || 0
        );


      const finalAmount =
        Number(
          order.payable_amount || 0
        ).toFixed(2);


      const hasMembershipDetails =
        membershipDiscount > 0 ||
        walletClaim > 0;


      let orderSummary = "";

      orderSummary +=
        `Total Items: ${totalItemCount} ${
          totalItemCount === 1
            ? "Item"
            : "Items"
        }`;

      orderSummary +=
        ` | Items Cost: ₹${itemsCost.toFixed(2)}`;


      if (
        hasMembershipDetails
      ) {
        orderSummary +=
          ` | Membership Discount: -₹${membershipDiscount.toFixed(2)}`;

        orderSummary +=
          ` | Wallet Claim: -₹${walletClaim.toFixed(2)}`;

        orderSummary +=
          ` | Delivery: ${
            deliveryCharge === 0
              ? "FREE"
              : `₹${deliveryCharge.toFixed(2)}`
          }`;

      } else {
        orderSummary +=
          ` | Delivery Charges: ₹${deliveryCharge.toFixed(2)}`;
      }


      orderSummary +=
        ` | Payment Status: PAID`;

      orderSummary +=
        ` | Payable Amount: ₹${finalAmount}`;


      if (
        orderDetails?.phone
      ) {
        await sendOrderConfirmation({
          mobile:
            orderDetails.phone,

          customerName:
            orderDetails.full_name,

          orderId:
            order.order_id,

          amount:
            finalAmount,

          orderSummary,
        });

        console.log(
          `WHATSAPP ORDER CONFIRMATION SENT FOR ${order.order_id}`
        );
      }

    } catch (whatsappError) {
      console.error(
        "WHATSAPP ORDER CONFIRMATION FAILED:",
        whatsappError.message
      );
    }
        /* =====================================================
       GET DELIVERY ADDRESS
    ===================================================== */

    const addressResult =
      await pool.query(
        `
        SELECT *
        FROM addresses
        WHERE id = $1
          AND entity_type = 'USER'
          AND (
            entity_id = $2
            OR entity_id = $3
          )
        LIMIT 1
        `,
        [
          address_id,

          String(
            resolvedUserId
          ),

          String(userId),
        ]
      );

    const address =
      addressResult.rows[0];


    if (!address) {
      return res.status(400).json({
        success: false,
        message:
          "Delivery address not found",
      });
    }


    /* =====================================================
       ORDER NOTIFICATION
    ===================================================== */

    try {
      const notification =
        await Notification.createNotification({
          userId:
            resolvedUserId,

          title:
            "Order Placed Successfully",

          message:
            `Your order #${order.order_id} has been placed successfully.`,

          type:
            "ORDER_PLACED",

          referenceId:
            order.id,
        });


      const user =
        await User.findById(
          resolvedUserId
        );


      if (
        user?.fcm_token
      ) {
        const fcmResponse =
          await sendPushNotification({
            fcmToken:
              user.fcm_token,

            title:
              "Order Placed Successfully",

            body:
              `Your order #${order.order_id} has been placed successfully.`,

            data: {
              notificationId:
                notification.id,

              orderId:
                order.id,

              mgoOrderId:
                order.order_id,

              type:
                "ORDER_PLACED",
            },
          });


        console.log(
          "ORDER PUSH SENT:",
          fcmResponse
        );

      } else {
        console.log(
          "User does not have an FCM token. Push not sent."
        );
      }

    } catch (notificationError) {
      console.error(
        "Order Notification/Push Error:",
        notificationError
      );
    }


    /* =====================================================
       CREATE SHIPMENT
    ===================================================== */

    let shipment;


    try {
      console.log(
        "========== XPRESSBEES PAYLOAD =========="
      );


      console.log(
        JSON.stringify(
          {
            order_number:
              String(
                order.order_id
              ),

            payment_type:
              "prepaid",

            order_amount:
              Number(
                order.payable_amount
              ),

            collectable_amount:
              0,
          },
          null,
          2
        )
      );


      const warehouseResult =
        await pool.query(
          `
          SELECT *
          FROM warehouses
          WHERE id = 1
          `
        );


      const warehouse =
        warehouseResult.rows[0];


      /*
       * Membership usage is intentionally
       * kept unchanged.
       *
       * membershipBenefits comes from the
       * cart before Order.createOrder clears
       * the cart.
       */

      if (
        membershipBenefits
      ) {
        await Membership.updateMembershipUsage({
          userId:
            resolvedUserId,

          litresUsed:
            membershipBenefits.totalLitres,

          walletUsed:
            membershipBenefits.walletClaim,

          orderId:
            order.id,
        });
      }


      shipment =
        await xpressbeesService.createShipment({
          order,
          address,
          warehouse,
        });


      console.log(
        "XPRESSBEES RESPONSE:",
        JSON.stringify(
          shipment,
          null,
          2
        )
      );


      if (!shipment) {
        console.log(
          "Shipment creation failed."
        );
      }


      const trackingNumber =
        shipment?.data?.awb_number ||
        shipment?.awb_number ||
        shipment?.awb ||
        null;


      if (
        trackingNumber
      ) {
        await Order.shipOrder(
          order.id,
          trackingNumber,
          "Xpressbees"
        );

      } else {
        console.log(
          "AWB number not found in Xpressbees response."
        );
      }

    } catch (e) {
      console.error(
        "========== XPRESSBEES ERROR =========="
      );

      console.error(
        "Status:",
        e.response?.status
      );

      console.error(
        "Response:",
        JSON.stringify(
          e.response?.data,
          null,
          2
        )
      );

      console.error(
        "Message:",
        e.message
      );

      console.error(
        "======================================"
      );
    }


    /* =====================================================
       FINAL RESPONSE
    ===================================================== */

    return res.json({
      success: true,

      data: {
        payment,
        order,
        shipment,
      },
    });

  } catch (err) {
    console.error(
      "VERIFY PAYMENT ERROR:",
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
   GET PAYMENTS
========================================================= */

const getPayments = async (
  req,
  res
) => {
  try {
    const payments =
      await Payment.getPayments();

    return res.json({
      success: true,
      data: payments,
    });

  } catch (err) {
    return res.status(500).json({
      success: false,
      message:
        err.message,
    });
  }
};


/* =========================================================
   CHECKOUT SUMMARY
========================================================= */

const checkoutSummary = async (req, res) => {
  try {
    const {
      entity_id,
      buyNow,
      productId,
      quantity,
    } = req.body;

    const resolvedEntityId = entity_id;

    if (!resolvedEntityId) {
      return res.status(400).json({
        success: false,
        message: "entity_id is required",
      });
    }

    let cartItems;

    // --------------------------------
    // BUY NOW
    // --------------------------------
    if (buyNow && productId) {
      const productResult = await pool.query(
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

      if (!productResult.rows.length) {
        return res.status(404).json({
          success: false,
          message: "Product not found",
        });
      }

      const product = productResult.rows[0];

      const buyNowQuantity = Math.max(
        1,
        Number(quantity || 1)
      );

      cartItems = [
        {
          cart_id: null,
          entity_type: "USER",
          entity_id: resolvedEntityId,
          item_type: "PRODUCT",
          product_id: product.id,
          product_name: product.name,
          price: Number(product.price || 0),
          weight: Number(product.weight || 0),
          stock: Number(product.stock || 0),
          quantity: buyNowQuantity,
          total_price:
            Number(product.price || 0) *
            buyNowQuantity,
        },
      ];

    } else {

      // --------------------------------
      // NORMAL CART CHECKOUT
      // --------------------------------
      cartItems = await Cart.getItems(
        "USER",
        resolvedEntityId
      );
    }

    // --------------------------------
    // SAME MEMBERSHIP LOGIC
    // --------------------------------
    const benefits =
      await calculateMembershipBenefits(
        resolvedEntityId,
        cartItems
      );

    const subtotal = cartItems.reduce(
      (sum, item) =>
        sum +
        Number(item.price || 0) *
          Number(item.quantity || 0),
      0
    );

    const payableAmount = benefits
      ? Number(benefits.payableAmount)
      : subtotal + 40;

    return res.json({
      success: true,
      cartItems,
      membershipBenefits: benefits,
      actualAmount: subtotal,
      payableAmount,
    });

  } catch (err) {
    console.error(
      "CHECKOUT SUMMARY ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


module.exports = {
  createOrder,
  verifyPayment,
  getPayments,
  checkoutSummary,
};