const razorpayService = require("../services/razorpayService");
const pool = require("../../db");
const generateUserId = require("../utils/generatedUserId");
const Subscription = require("../models/Subscription");
const Membership = require("../models/Membership");

const getSubscriptionPlans = async (req, res) => {
  try {
    const plans = await Subscription.getPlans();

    res.status(200).json({
      success: true,
      plans,
    });
  } catch (error) {
    console.error("Subscription Plans Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch subscription plans",
    });
  }
};


const getMyMembership = async (req, res) => {
  try {
    const { userId } = req.query;

    const membership = await Membership.getActiveMembership(userId);

    res.status(200).json({
      success: true,
      membership,
    });
  } catch (error) {
    console.error("Get Membership Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const acceptSubscriptionTerms = async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const membership = await Membership.acceptTerms(userId);

    res.status(200).json({
      success: true,
      message: "Subscription terms accepted",
      membership,
    });
  } catch (error) {
    console.error("Accept Subscription Terms Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getAdminSubscriptionPlans = async (req, res) => {
  try {
    const plans = await Subscription.getAdminPlans();

    res.status(200).json({
      success: true,
      plans,
    });
  } catch (error) {
    console.error("Admin Subscription Plans Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch subscription plans",
      error: error.message,
    });
  }
};
const createSubscriptionPlan = async (req, res) => {
  try {
    const {
      plan_name,
      plan_price,
      wallet_bonus,
      monthly_claim,
      discount_percentage,
      monthly_limit_litres,
      validity_months,
      description,
      display_order,
    } = req.body;

    // Validation
    if (
      !plan_name ||
      plan_price === undefined ||
      validity_months === undefined
    ) {
      return res.status(400).json({
        success: false,
        message: "plan_name, plan_price and validity_months are required",
      });
    }

    const plan = await Subscription.createPlan({
      plan_name,
      plan_price,
      wallet_bonus,
      monthly_claim,
      discount_percentage,
      monthly_limit_litres,
      validity_months,
      description,
      display_order,
    });

    res.status(201).json({
      success: true,
      message: "Subscription plan created successfully",
      plan,
    });
  } catch (error) {
    console.error("Create Subscription Plan Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to create subscription plan",
      error: error.message,
    });
  }
};
const verifySubscriptionPayment = async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      plan,
      first_name,
      last_name,
      phone,
      email,
      address,
      city,
      state,
      pincode,
      amount,
    } = req.body;

    // =====================================================
    // 1. VALIDATE PAYMENT DETAILS
    // =====================================================

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({
        success: false,
        message: "Payment details are required",
      });
    }

    // =====================================================
    // 2. VALIDATE CUSTOMER DETAILS
    // =====================================================

    if (!first_name || !last_name || !phone) {
      return res.status(400).json({
        success: false,
        message: "First name, last name and phone are required",
      });
    }

    if (!plan || plan === "None") {
      return res.status(400).json({
        success: false,
        message: "Valid subscription plan is required",
      });
    }

    // =====================================================
    // 3. VERIFY RAZORPAY PAYMENT
    // =====================================================

    const isValid = razorpayService.verifyPaymentSignature(
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
    );

    if (!isValid) {
      return res.status(400).json({
        success: false,
        message: "Invalid payment signature",
      });
    }

    console.log("Subscription payment verified successfully");

    console.log("Plan:", plan);
    console.log("Payment ID:", razorpay_payment_id);

    // =====================================================
    // 4. START DATABASE TRANSACTION
    // =====================================================

    await client.query("BEGIN");

    // =====================================================
    // 5. CHECK WHETHER CUSTOMER ALREADY EXISTS
    // =====================================================

    const existingUser = await client.query(
      `
      SELECT
        ul.user_id,
        ul.username,
        ul.mobile_no,
        ul.role,
        ul.is_active,

        ui.first_name,
        ui.last_name,
        ui.email,
        ui.address,
        ui.city,
        ui.state,
        ui.pincode,
        ui.subscription

      FROM user_login ul

      LEFT JOIN user_info ui
        ON ul.user_id = ui.user_id

      WHERE ul.mobile_no = $1

      LIMIT 1
      `,
      [phone],
    );

    let userId;

    // =====================================================
    // CASE 1: EXISTING CUSTOMER
    // =====================================================

    if (existingUser.rows.length > 0) {
      const user = existingUser.rows[0];

      userId = user.user_id;

      console.log("Existing customer found:", userId);

      // Make account CUSTOMER and active
      await client.query(
        `
        UPDATE user_login
        SET
          role = 'CUSTOMER',
          is_active = true
        WHERE user_id = $1
        `,
        [userId],
      );

      // ===================================================
      // CHECK USER_INFO
      // ===================================================

      const userInfoCheck = await client.query(
        `
        SELECT user_id
        FROM user_info
        WHERE user_id = $1
        LIMIT 1
        `,
        [userId],
      );

      // ===================================================
      // UPDATE EXISTING USER_INFO
      // ===================================================

      if (userInfoCheck.rows.length > 0) {
        await client.query(
          `
          UPDATE user_info
          SET
            first_name = $1,
            last_name = $2,
            email = $3,
            address = $4,
            city = $5,
            state = $6,
            pincode = $7,
            subscription = $8
          WHERE user_id = $9
          `,
          [
            first_name,
            last_name,
            email || null,
            address || null,
            city || null,
            state || null,
            pincode || null,
            plan,
            userId,
          ],
        );

        console.log("Existing customer subscription updated:", userId);
      }

      // ===================================================
      // CREATE USER_INFO IF MISSING
      // ===================================================
      else {
        await client.query(
          `
          INSERT INTO user_info
          (
            user_id,
            first_name,
            last_name,
            email,
            address,
            city,
            state,
            pincode,
            subscription
          )
          VALUES
          (
            $1,
            $2,
            $3,
            $4,
            $5,
            $6,
            $7,
            $8,
            $9
          )
          `,
          [
            userId,
            first_name,
            last_name,
            email || null,
            address || null,
            city || null,
            state || null,
            pincode || null,
            plan,
          ],
        );

        console.log("Missing user_info created:", userId);
      }
    }

    // =====================================================
    // CASE 2: NEW CUSTOMER
    // =====================================================
    else {
      console.log("New customer. Creating user...");

      // Generate customer ID
      userId = await generateUserId("CUSTOMER");

      console.log("Generated customer ID:", userId);

      // Create username
      let username = `${first_name} ${last_name}`.trim();

      const usernameCheck = await client.query(
        `
        SELECT id
        FROM user_login
        WHERE username = $1
        LIMIT 1
        `,
        [username],
      );

      if (usernameCheck.rows.length > 0) {
        username = `${first_name} ${last_name} ${phone.slice(-4)}`;
      }

      // Temporary password
      const temporaryPassword = phone;

      // ===================================================
      // INSERT USER_LOGIN
      // ===================================================

      await client.query(
        `
        INSERT INTO user_login
        (
          user_id,
          username,
          mobile_no,
          password,
          role,
          is_active,
          created_by,
          assigned_by,
          relationship_type
        )
        VALUES
        (
          $1,
          $2,
          $3,
          $4,
          'CUSTOMER',
          true,
          'SUPER_ADMIN',
          NULL,
          'CUSTOMER'
        )
        `,
        [userId, username, phone, temporaryPassword],
      );

      console.log("New user_login created:", userId);

      // ===================================================
      // INSERT USER_INFO
      // ===================================================

      await client.query(
        `
        INSERT INTO user_info
        (
          user_id,
          first_name,
          last_name,
          email,
          address,
          city,
          state,
          pincode,
          subscription
        )
        VALUES
        (
          $1,
          $2,
          $3,
          $4,
          $5,
          $6,
          $7,
          $8,
          $9
        )
        `,
        [
          userId,
          first_name,
          last_name,
          email || null,
          address || null,
          city || null,
          state || null,
          pincode || null,
          plan,
        ],
      );

      console.log("New user_info created:", userId);
    }

    // =====================================================
    // COMMIT
    // =====================================================

    await client.query("COMMIT");

    console.log("Customer registered successfully:", userId);

    // =====================================================
    // RESPONSE
    // =====================================================

    return res.status(200).json({
      success: true,

      message: "Payment verified and customer registered successfully",

      payment: {
        razorpay_order_id,
        razorpay_payment_id,
        plan,
        amount,
      },

      customer: {
        user_id: userId,
        first_name,
        last_name,
        phone,
        email: email || null,
        address: address || null,
        city: city || null,
        state: state || null,
        pincode: pincode || null,
        role: "CUSTOMER",
        subscription: plan,
      },
    });
  } catch (error) {
    // =====================================================
    // ROLLBACK
    // =====================================================

    try {
      await client.query("ROLLBACK");
    } catch (rollbackError) {
      console.error("Rollback error:", rollbackError);
    }

    console.error("Verify Subscription Payment Error:", error);

    return res.status(500).json({
      success: false,
      message:
        error?.detail ||
        error?.message ||
        "Payment verification failed and customer was not created",
    });
  } finally {
    client.release();
  }
};
const createSubscriptionOrder = async (req, res) => {
  try {
    const { amount, plan, customer_name, customer_phone, customer_email } =
      req.body;

    if (!amount || !plan || !customer_name || !customer_phone) {
      return res.status(400).json({
        success: false,
        message: "Amount, plan, customer name and phone are required",
      });
    }

    console.log("Creating subscription Razorpay order...");
    console.log("Plan:", plan);
    console.log("Amount:", amount);

    const order = await razorpayService.createRazorpayOrder(amount);

    console.log("Razorpay order created:", order.id);

    res.status(200).json({
      success: true,
      key_id: process.env.RAZORPAY_KEY_ID,
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      plan,
      customer_name,
      customer_phone,
      customer_email: customer_email || "",
    });
  } catch (error) {
    console.error("Create Subscription Order Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to create subscription order",
      error: error.message,
    });
  }
};
const assignSubscriptionToCustomer = async (req, res) => {
  try {
    const { userId } = req.params;
    const { planName } = req.body;

    if (!userId || !planName) {
      return res.status(400).json({
        success: false,
        message: "userId and planName are required",
      });
    }

    const customer = await Subscription.assignSubscription(userId, planName);

    res.status(200).json({
      success: true,
      message: "Subscription assigned successfully",
      customer,
    });
  } catch (error) {
    console.error("Assign Subscription Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to assign subscription",
      error: error.message,
    });
  }
};
const toggleSubscriptionPlanStatus = async (req, res) => {
  try {
    const { planId } = req.params;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: "planId is required",
      });
    }

    const plan = await Subscription.togglePlanStatus(planId);

    res.status(200).json({
      success: true,
      message: plan.is_active
        ? "Subscription plan activated successfully"
        : "Subscription plan deactivated successfully",
      plan,
    });
  } catch (error) {
    console.error("Toggle Subscription Plan Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const deleteSubscriptionPlan = async (req, res) => {
  try {
    const { planId } = req.params;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: "planId is required",
      });
    }

    const deletedPlan = await Subscription.deletePlan(planId);

    res.status(200).json({
      success: true,
      message: "Subscription plan deleted successfully",
      plan: deletedPlan,
    });
  } catch (error) {
    console.error("Delete Subscription Plan Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to delete subscription plan",
      error: error.message,
    });
  }
};
module.exports = {
  getSubscriptionPlans,
  getMyMembership,
  getAdminSubscriptionPlans,
  acceptSubscriptionTerms,
  createSubscriptionOrder,
  verifySubscriptionPayment,
  createSubscriptionPlan,
  assignSubscriptionToCustomer,
  toggleSubscriptionPlanStatus,
  deleteSubscriptionPlan,
};
