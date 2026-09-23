const Order = require("../models/Order");
const Payment = require("../models/Payment");
const Notification = require("../models/Notification");
const razorpayService = require("../services/razorpayService");
const Membership = require("../models/Membership");
const pool = require("../../db");
const xpressbeesService = require("../services/xpressbeesService");
const Address = require("../models/Address");
const Cart = require("../models/Cart");
const User = require("../models/User");

const { sendPushNotification } = require("../services/fcmService");

const {
  calculateMembershipBenefits,
} = require("../services/membershipCheckoutService");

const {
  processMembershipBenefit,
} = require("../services/membershipBenefitService");


/* --------------------------------
   CREATE ORDER
-------------------------------- */
const createOrder = async (req, res) => {
  try {
    console.log("CREATE ORDER HIT");
    console.log("BODY:", req.body);

    const {
      order_id,
      amount,
      entity_id,
      paymentType,
      membershipPlanId,
    } = req.body;

    let resolvedEntityId = entity_id;

    /*
     * Resolve public MGU ID directly through user_login.
     *
     * MGU26092101
     *       ↓
     * user_login.id = 124
     */
    if (
      typeof entity_id === "string" &&
      entity_id.startsWith("MGU")
    ) {
      const userResult = await pool.query(
        `
        SELECT id
        FROM user_login
        WHERE user_id = $1
          AND is_active = true
        LIMIT 1
        `,
        [entity_id]
      );

      if (!userResult.rows[0]) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      resolvedEntityId = userResult.rows[0].id;
    }

    const paymentTypeUpper =
      (paymentType || "ORDER").toUpperCase();

    let finalAmount = amount;

    /* --------------------------------
       MEMBERSHIP PAYMENT
    -------------------------------- */
    if (paymentTypeUpper === "MEMBERSHIP") {
      const planResult = await pool.query(
        `
        SELECT plan_price
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

      finalAmount = Number(plan.plan_price);
    }

    /* --------------------------------
       NORMAL PRODUCT ORDER
    -------------------------------- */
    if (paymentTypeUpper !== "MEMBERSHIP") {
      const cartItems = await Cart.getItems(
        "USER",
        resolvedEntityId
      );

      const benefits =
        await calculateMembershipBenefits(
          resolvedEntityId,
          cartItems
        );

      if (benefits) {
        finalAmount = Number(
          benefits.payableAmount
        );

        console.log(
          "Membership Benefits:",
          benefits
        );
      } else {
        const subtotal = cartItems.reduce(
          (sum, item) =>
            sum +
            Number(item.price || 0) *
              Number(item.quantity || 0),
          0
        );

        const deliveryCharge = 40;

        finalAmount =
          subtotal + deliveryCharge;
      }
    }

    console.log(
      "Final Amount:",
      finalAmount
    );

    /*
     * TEST MODE:
     * Send only ₹1 to Razorpay.
     * Keep actual order/payment amount unchanged.
     */
    const razorpayAmount = 1;

    const razorpayOrder =
      await razorpayService.createRazorpayOrder(
        razorpayAmount
      );

    const payment =
      await Payment.createPayment({
        order_id,

        payment_gateway: "RAZORPAY",

        amount: finalAmount,

        status: "PENDING",

        gateway_order_id:
          razorpayOrder.id,

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

        payableAmount:
          finalAmount,
      },
    });

  } catch (err) {
    console.log(
      "CREATE ORDER ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: err.message,
      stack: err.stack,
    });
  }
};


/* --------------------------------
   VERIFY PAYMENT
-------------------------------- */
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

    let resolvedUserId = userId;

    /*
     * Resolve MGU ID directly through user_login.
     */
    if (
      typeof userId === "string" &&
      userId.startsWith("MGU")
    ) {
      const userResult = await pool.query(
        `
        SELECT id
        FROM user_login
        WHERE user_id = $1
          AND is_active = true
        LIMIT 1
        `,
        [userId]
      );

      if (!userResult.rows[0]) {
        return res.status(404).json({
          success: false,
          message: "User account not found",
        });
      }

      resolvedUserId =
        userResult.rows[0].id;
    }

    /* --------------------------------
       VERIFY RAZORPAY SIGNATURE
    -------------------------------- */
    const isValid =
      razorpayService.verifyPaymentSignature(
        razorpay_order_id,
        razorpay_payment_id,
        razorpay_signature
      );

    if (!isValid) {
      return res
        .status(400)
        .json({
          success: false,
          message: "Invalid signature",
        });
    }

    /* --------------------------------
       UPDATE PAYMENT
    -------------------------------- */
    const payment =
      await Payment.updateByGatewayOrderId(
        razorpay_order_id,
        {
          status: "PAID",
          gateway_payment_id:
            razorpay_payment_id,
        }
      );

    /* --------------------------------
       PAYMENT SUCCESS NOTIFICATION
    -------------------------------- */
    try {
      await Notification.createNotification({
        userId: resolvedUserId,
        title: "Payment Successful",
        message:
          "Your payment was successfully completed.",
        type: "PAYMENT_SUCCESS",
        referenceId: payment.id,
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

    let membershipBenefits = null;

    if (
      (paymentType || "").toUpperCase() !==
      "MEMBERSHIP"
    ) {
      const cartItems = await Cart.getItems(
        "USER",
        resolvedUserId
      );

      membershipBenefits =
        await calculateMembershipBenefits(
          resolvedUserId,
          cartItems
        );
    }

    let order;

    /* --------------------------------
       MEMBERSHIP PAYMENT
    -------------------------------- */
    if (
      (paymentType || "").toUpperCase() ===
      "MEMBERSHIP"
    ) {
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

      const expiryDate = new Date();

      expiryDate.setFullYear(
        expiryDate.getFullYear() + 1
      );

      /* --------------------------------
         GET CUSTOMER ASSIGNMENT
         Directly from user_login
      -------------------------------- */
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

      const assignedBy =
        customer.assigned_by ||
        customer.created_by ||
        null;

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

        assignedRole =
          assignedUserResult
            .rows[0]?.role || null;
      }

      console.log(
        "===== MEMBERSHIP ASSIGNMENT ====="
      );

      console.log(
        "Customer numeric ID:",
        customer.numeric_user_id
      );

      console.log(
        "Customer login ID:",
        customer.login_user_id
      );

      console.log(
        "Assigned By:",
        assignedBy
      );

      console.log(
        "Assigned Role:",
        assignedRole
      );

      /* --------------------------------
         VALIDATE REFERRAL CODE
      -------------------------------- */
      let validatedReferralCode = null;

      if (
        typeof referralCode === "string" &&
        referralCode.trim() !== ""
      ) {
        const cleanReferralCode =
          referralCode.trim();

        const referralResult =
          await pool.query(
            `
            SELECT
              ul.id AS referrer_user_id,
              ul.user_id AS referral_code,
              ul.role
            FROM user_login ul
            WHERE ul.user_id = $1
              AND ul.is_active = true
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
          Number(
            referrer.referrer_user_id
          ) === Number(resolvedUserId)
        ) {
          return res.status(400).json({
            success: false,
            message:
              "You cannot use your own referral code",
          });
        }

        validatedReferralCode =
          referrer.referral_code;
      }

      /* --------------------------------
         CREATE MEMBERSHIP
      -------------------------------- */
      const membership =
        await Membership.createMembership({
          userId: resolvedUserId,
          planId: plan.id,
          paymentId: payment.id,
          walletBalance:
            plan.wallet_bonus,
          discountPercent:
            plan.discount_percentage,
          monthlyClaim:
            plan.monthly_claim,
          expiryDate,
          termsAndConditions: true,
          assignedBy,
          assignedRole,
          referralCode:
            validatedReferralCode,
        });

      /* --------------------------------
         PROCESS VENDOR / RESELLER BENEFIT
      -------------------------------- */
      const membershipBenefits =
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
        membershipBenefits
      );

      return res.json({
        success: true,
        payment,
        membership,
        message:
          "Membership activated successfully.",
      });
    }

    /* --------------------------------
       CREATE NORMAL ORDER
    -------------------------------- */
    if (buyNow) {
      order =
        await Order.createBuyNowOrder(
          "USER",
          resolvedUserId,
          address_id,
          productId,
          quantity || 1
        );
    } else {
      order =
        await Order.createOrder(
          "USER",
          resolvedUserId,
          address_id
        );
    }


    /* --------------------------------
   UPDATE PAYMENT + ORDER PAYMENT STATUS
-------------------------------- */

await pool.query(
  `
  UPDATE payments
  SET order_id = $1
  WHERE id = $2
  `,
  [order.id, payment.id]
);

await pool.query(
  `
  UPDATE orders
  SET payment_status = 'PAID'
  WHERE id = $1
  `,
  [order.id]
);

console.log(
  `Payment ${payment.id} linked to order ${order.id} and marked PAID`
);

    if (!order) {
      return res.status(400).json({
        success: false,
        message: "Order creation failed",
      });
    }

    /* --------------------------------
       GET DELIVERY ADDRESS
    -------------------------------- */
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
          String(resolvedUserId),
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

    /* --------------------------------
       ORDER NOTIFICATION
    -------------------------------- */
    try {
      const notification =
        await Notification.createNotification({
          userId: resolvedUserId,
          title:
            "Order Placed Successfully",
          message:
            `Your order #${order.id} has been placed successfully.`,
          type: "ORDER_PLACED",
          referenceId: order.id,
        });

      console.log(
        `Notification created for order ${order.id}`
      );

      /*
       * User model will be migrated separately
       * to user_login. Keeping this call here
       * preserves the existing FCM flow.
       */
      const user =
        await User.findById(
          resolvedUserId
        );

      console.log(
        "Order notification user:",
        user
      );

      if (!user?.fcm_token) {
        console.log(
          "User does not have an FCM token. Push not sent."
        );
      } else {
        const fcmResponse =
          await sendPushNotification({
            fcmToken:
              user.fcm_token,

            title:
              "Order Placed Successfully",

            body:
              `Your order #${order.id} has been placed successfully.`,

            data: {
              notificationId:
                notification.id,

              orderId:
                order.id,

              type:
                "ORDER_PLACED",
            },
          });

        console.log(
          "ORDER PUSH SENT:",
          fcmResponse
        );
      }

    } catch (notificationError) {
      console.error(
        "Order Notification/Push Error:",
        notificationError
      );
    }

    /* --------------------------------
       CREATE SHIPMENT
    -------------------------------- */
    let shipment;

    try {
      console.log(
        "========== XPRESSBEES PAYLOAD =========="
      );

      console.log(
        JSON.stringify(
          {
            order_number:
              String(order.id),

            payment_type:
              "prepaid",

            order_amount:
              Number(
                order.total_amount
              ),

            collectable_amount:
              0,
          },
          null,
          2
        )
      );

      console.log(
        "========================================"
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

      if (membershipBenefits) {
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
        return res.status(500).json({
          success: false,
          message:
            "Shipment creation failed.",
        });
      }

      const trackingNumber =
        shipment.data?.awb_number ||
        shipment.awb_number ||
        shipment.awb ||
        null;

      if (trackingNumber) {
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

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


/* --------------------------------
   GET PAYMENTS
-------------------------------- */
const getPayments = async (req, res) => {
  try {
    const payments =
      await Payment.getPayments();

    res.json({
      success: true,
      data: payments,
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


/* --------------------------------
   CHECKOUT SUMMARY
-------------------------------- */
const checkoutSummary = async (req, res) => {
  try {
    const { entity_id } =
      req.body;

    let resolvedEntityId =
      entity_id;

    /*
     * Resolve public MGU ID directly
     * through user_login.
     */
    if (
      typeof entity_id === "string" &&
      entity_id.startsWith("MGU")
    ) {
      const userResult =
        await pool.query(
          `
          SELECT id
          FROM user_login
          WHERE user_id = $1
            AND is_active = true
          LIMIT 1
          `,
          [entity_id]
        );

      if (!userResult.rows[0]) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      resolvedEntityId =
        userResult.rows[0].id;
    }

    const cartItems =
      await Cart.getItems(
        "USER",
        resolvedEntityId
      );

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

    const payableAmount =
      benefits
        ? Number(
            benefits.payableAmount
          )
        : subtotal + 40;

    return res.json({
      success: true,
      cartItems,
      membershipBenefits:
        benefits,
      payableAmount,
    });

  } catch (err) {
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