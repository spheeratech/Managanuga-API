const Order = require("../models/Order");
const pool = require("../../db");

const {
  sendOrderConfirmation,
} = require("../services/whatsappService");

const xpressbeesService = require("../services/xpressbeesService");

/* --------------------------------
   RESOLVE PUBLIC MGU ID
   → INTERNAL user_login.id
-------------------------------- */

const resolveUserId = async (userId) => {
  if (
    typeof userId !== "string" ||
    !userId.startsWith("MGU")
  ) {
    return userId;
  }

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

  return result.rows[0]?.id || null;
};

/* --------------------------------
   CREATE ORDER
-------------------------------- */

const createOrder = async (req, res) => {
  console.log("ORDER BODY:", req.body);

  try {
    const {
      entity_type,
      entity_id,
      address_id,
      buyNow,
      productId,
      quantity,
    } = req.body;

    let resolvedEntityId = entity_id;
    let publicUserId = entity_id;

    if (
      entity_type === "USER" &&
      typeof entity_id === "string" &&
      entity_id.startsWith("MGU")
    ) {
      publicUserId = entity_id;

      resolvedEntityId =
        await resolveUserId(entity_id);

      if (!resolvedEntityId) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }
    } else if (entity_type === "USER") {
      /*
       * Legacy callers may still send the numeric
       * internal user_login.id.
       *
       * Convert it to the public MGU ID before
       * creating the order.
       */
      const userResult = await pool.query(
        `
        SELECT user_id
        FROM user_login
        WHERE id = $1
          AND is_active = true
        LIMIT 1
        `,
        [resolvedEntityId]
      );

      if (!userResult.rows[0]) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        });
      }

      publicUserId =
        userResult.rows[0].user_id;
    }

    const order = await Order.createOrder(
      entity_type,
      resolvedEntityId,
      address_id,
      buyNow,
      productId,
      quantity,
      publicUserId
    );

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Cart is empty",
      });
    }

    // --------------------------------
    // WHATSAPP ORDER CONFIRMATION
    // --------------------------------

    try {
      const orderDetails =
        await Order.getOrderById(order.id);

      const orderItems =
        await Order.getOrderItems(order.id);

      /* --------------------------------
         PRODUCT SUMMARY
      -------------------------------- */

      const productNames = orderItems
        .map(
          (item) =>
            `${item.product_name} x${item.quantity}`
        )
        .join(", ");

      /* --------------------------------
         TOTAL ITEMS
      -------------------------------- */

      const totalItems = orderItems.reduce(
        (sum, item) =>
          sum + Number(item.quantity || 0),
        0
      );

      const itemLabel =
        totalItems === 1 ? "Item" : "Items";

      /* --------------------------------
         EXISTING ORDER PRICE BREAKDOWN

         These values come from the same
         fields used by the Order Summary.
      -------------------------------- */

      const itemsCost = Number(
        orderDetails?.items_cost ??
        orderDetails?.total_amount ??
        0
      );

      const membershipDiscount = Number(
        orderDetails?.membership_discount || 0
      );

      const walletClaim = Number(
        orderDetails?.wallet_claim || 0
      );

      const deliveryCharge = Number(
        orderDetails?.delivery_charge || 0
      );

      const paymentStatus =
        orderDetails?.payment_status ||
        "PAID";

      /* --------------------------------
         MEMBERSHIP ORDER

         Membership fields are shown only
         when membership discount or wallet
         claim exists.
      -------------------------------- */

      const isMembershipOrder =
        membershipDiscount > 0 ||
        walletClaim > 0;

      let orderSummary;

      if (isMembershipOrder) {
        const deliveryText =
          deliveryCharge > 0
            ? `₹${deliveryCharge.toFixed(2)}`
            : "FREE";

        const payableAmount =
          itemsCost -
          membershipDiscount -
          walletClaim +
          deliveryCharge;

        orderSummary =
          `Total Items: ${totalItems} ${itemLabel} | ` +
          `Items Cost: ₹${itemsCost.toFixed(2)} | ` +
          `Membership Discount: -₹${membershipDiscount.toFixed(2)} | ` +
          `Wallet Claim: -₹${walletClaim.toFixed(2)} | ` +
          `Delivery: ${deliveryText} | ` +
          `Payment Status: ${paymentStatus} | ` +
          `Payable Amount: ₹${payableAmount.toFixed(2)}`;
      } else {
        /* --------------------------------
           NORMAL / NON-MEMBERSHIP ORDER

           Do NOT show membership discount
           or wallet claim.
        -------------------------------- */

        const totalAmount =
          itemsCost + deliveryCharge;

        orderSummary =
          `Total Items: ${totalItems} ${itemLabel} | ` +
          `Items Cost: ₹${itemsCost.toFixed(2)} | ` +
          `Delivery Charges: ₹${deliveryCharge.toFixed(2)} | ` +
          `Payment Status: ${paymentStatus} | ` +
          `Total Amount: ₹${totalAmount.toFixed(2)}`;
      }

      /* --------------------------------
         SEND WHATSAPP
      -------------------------------- */

      if (orderDetails?.phone) {
        await sendOrderConfirmation({
          mobile: orderDetails.phone,
          orderId: order.id,
          products: productNames,
          orderSummary,
        });

        console.log(
          "WHATSAPP ORDER CONFIRMATION SENT FOR ORDER:",
          order.id
        );
      } else {
        console.log(
          "WhatsApp skipped: customer mobile number not found."
        );
      }
    } catch (whatsappError) {
      /* --------------------------------
         WhatsApp failure must NOT fail
         the order itself.
      -------------------------------- */

      console.error(
        "WHATSAPP ORDER CONFIRMATION FAILED:",
        whatsappError.message
      );
    }

/* --------------------------------
   GET ORDERS
-------------------------------- */

const getOrders = async (req, res) => {
  try {
    const {
      entity_type,
      entity_id,
      user_id,
    } = req.query;

    /*
     * NEW:
     * Prefer public user_id.
     */
    if (user_id) {
      const orders =
        await Order.getOrdersByUserId(
          user_id
        );

      return res.json({
        success: true,
        count: orders.length,
        data: orders,
      });
    }

    /*
     * Existing frontend compatibility:
     * entity_id may still contain MGU ID.
     */
    if (
      entity_type === "USER" &&
      typeof entity_id === "string" &&
      entity_id.startsWith("MGU")
    ) {
      const orders =
        await Order.getOrdersByUserId(
          entity_id
        );

      return res.json({
        success: true,
        count: orders.length,
        data: orders,
      });
    }

    /*
     * Legacy numeric entity lookup.
     */
    if (entity_type && entity_id) {
      const orders =
        await Order.getOrdersByEntity(
          entity_type,
          entity_id
        );

      return res.json({
        success: true,
        count: orders.length,
        data: orders,
      });
    }

    const orders =
      await Order.getOrders();

    return res.json({
      success: true,
      count: orders.length,
      data: orders,
    });
  } catch (error) {
    console.error(
      "GET ORDERS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   GET ORDER BY ID
-------------------------------- */

const getOrderById = async (req, res) => {
  try {
    const order =
      await Order.getOrderById(
        req.params.id
      );

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   GET ORDER ITEMS
-------------------------------- */

const getOrderItems = async (req, res) => {
  try {
    const items =
      await Order.getOrderItems(
        req.params.id
      );

    res.json({
      success: true,
      count: items.length,
      data: items,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   UPDATE ORDER
-------------------------------- */

const updateOrder = async (req, res) => {
  try {
    const order =
      await Order.updateOrder(
        req.params.id,
        req.body.status
      );

    res.json({
      success: true,
      message: "Order updated successfully",
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   DELETE ORDER
-------------------------------- */

const deleteOrder = async (req, res) => {
  try {
    const order =
      await Order.deleteOrder(
        req.params.id
      );

    res.json({
      success: true,
      message: "Order deleted successfully",
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   TRACK ORDER
-------------------------------- */

const trackOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const order =
      await Order.getOrderById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    if (!order.tracking_number) {
      return res.status(400).json({
        success: false,
        message: "Tracking number not available",
      });
    }

    const tracking =
      await xpressbeesService.trackShipment(
        order.tracking_number
      );

    res.json(tracking);
  } catch (err) {
    console.error(
      "Tracking Error:",
      err.response?.data ||
        err.message
    );

    res.status(500).json({
      success: false,
      message:
        err.response?.data ||
        err.message,
    });
  }
};

module.exports = {
  createOrder,
  getOrders,
  getOrderById,
  getOrderItems,
  updateOrder,
  deleteOrder,
  trackOrder,
};