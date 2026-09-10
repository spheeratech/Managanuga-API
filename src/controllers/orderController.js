const Order = require("../models/Order");
const {
  sendOrderConfirmation,
} = require("../services/whatsappService");
const xpressbeesService = require("../services/xpressbeesService");
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
      tracking_number,
    } = req.body;

    const order = await Order.createOrder(
      entity_type,
      entity_id,
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
    // SEND WHATSAPP ORDER CONFIRMATION
    // --------------------------------
    try {
      const orderDetails = await Order.getOrderById(order.id);
      const orderItems = await Order.getOrderItems(order.id);

      const productNames = orderItems
        .map((item) => `${item.product_name} x${item.quantity}`)
        .join(", ");

      if (orderDetails?.phone) {
        await sendOrderConfirmation({
          mobile: orderDetails.phone,
          orderId: order.id,
          products: productNames,
          amount: order.total_amount,
        });
      } else {
        console.log(
          "WhatsApp skipped: customer mobile number not found."
        );
      }
    } catch (whatsappError) {
      // IMPORTANT:
      // WhatsApp failure must NOT fail the order.
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
    console.error("CREATE ORDER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getOrders = async (req, res) => {
  try {
    const { entity_type, entity_id } = req.query;

    let orders;

    if (entity_type && entity_id) {
      orders = await Order.getOrdersByEntity(entity_type, entity_id);
    } else {
      orders = await Order.getOrders();
    }

    res.json({
      success: true,
      count: orders.length,
      data: orders,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getOrderById = async (req, res) => {
  try {
    const order = await Order.getOrderById(req.params.id);

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

const getOrderItems = async (req, res) => {
  try {
    const items = await Order.getOrderItems(req.params.id);

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

const updateOrder = async (req, res) => {
  try {
    const order = await Order.updateOrder(req.params.id, req.body.status);

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

const deleteOrder = async (req, res) => {
  try {
    const order = await Order.deleteOrder(req.params.id);

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
const trackOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const order = await Order.getOrderById(id);

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

    const tracking = await xpressbeesService.trackShipment(
      order.tracking_number
    );

    res.json(tracking);
 } catch (err) {
  console.error("Tracking Error:", err.response?.data || err.message);

  res.status(500).json({
    success: false,
    message: err.response?.data || err.message,
  });
}
}

module.exports = {
  createOrder,
  getOrders,
  getOrderById,
  getOrderItems,
  updateOrder,
  deleteOrder,
  trackOrder,
};
