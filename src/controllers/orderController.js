const Order = require("../models/Order");

const {
  sendOrderConfirmation,
} = require("../services/whatsappService");

const xpressbeesService = require("../services/xpressbeesService");

/* --------------------------------
   CREATE ORDER
-------------------------------- */

const createOrder = async (req, res) => {
  console.log("ORDER BODY:", req.body);

  try {
   const {
  user_id,
  address_id,
  buyNow = false,
  productId = null,
  quantity = 1,
} = req.body;

if (!user_id) {
  return res.status(400).json({
    success: false,
    message: "User ID is required",
  });
}
 const order = await Order.createOrder(
  user_id,
  address_id,
  buyNow,
  productId,
  quantity
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
        orderDetails?.actual_amount ?? 0
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

        const payableAmount = Number(
          orderDetails?.payable_amount ??
          (
            itemsCost -
            membershipDiscount -
            walletClaim +
            deliveryCharge
          )
        );

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

        const totalAmount = Number(
          orderDetails?.payable_amount ??
          (itemsCost + deliveryCharge)
        );

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
  
    return res.status(201).json({
      success: true,
      message: "Order created successfully",
      data: order,
    });
  } catch (error) {
    console.error(
      "CREATE ORDER ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
/* --------------------------------
   GET ORDERS
-------------------------------- */

const getOrders = async (req, res) => {
  try {
    const { user_id } = req.query;

    if (user_id) {
      const orders = await Order.getOrdersByUserId(user_id);

      return res.json({
        success: true,
        count: orders.length,
        data: orders,
      });
    }

    const orders = await Order.getOrders();

    return res.json({
      success: true,
      count: orders.length,
      data: orders,
    });
  } catch (error) {
    console.error("GET ORDERS ERROR:", error);

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