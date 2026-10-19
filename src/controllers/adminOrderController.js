const pool = require("../../db");
const AdminOrder = require("../models/AdminOrder");
// const xpressbeesService = require("../services/xpressbeesService");
const shiprocketService = require("../services/shiprocketService");
// const Warehouse = require("../models/Warehouse");
const { sendSMS } = require("../services/smsService");

const createAdminOrder = async (req, res) => {
  try {
    const { user_id, productId, quantity, warehouse_id } = req.body || {};

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: "productId is required",
      });
    }

    const order = await AdminOrder.createAdminOrder({
      user_id,
      productId,
      quantity: quantity || 1,
      warehouse_id: warehouse_id || null,
    });

    return res.status(201).json({
      success: true,
      message: "Admin order created successfully",
      data: order,
    });
  } catch (error) {
    console.error("CREATE ADMIN ORDER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   GET ALL ADMIN ORDERS
-------------------------------- */

const getAdminOrders = async (req, res) => {
  try {
    const orders = await AdminOrder.getAdminOrders();

    return res.status(200).json({
      success: true,
      count: orders.length,
      data: orders,
    });
  } catch (error) {
    console.error("GET ADMIN ORDERS ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   GET ADMIN ORDER BY ID
-------------------------------- */

const getAdminOrderById = async (req, res) => {
  try {
    const { id } = req.params;

    const order = await AdminOrder.getAdminOrderById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: order,
    });
  } catch (error) {
    console.error("GET ADMIN ORDER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   UPDATE ADMIN ORDER
-------------------------------- */

const updateAdminOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      status,
      payment_status,
      warehouse_id,
      tracking_number,
      courier_name,
    } = req.body || {};

    const order = await AdminOrder.updateAdminOrder(id, {
      status,
      payment_status,
      warehouse_id,
      tracking_number,
      courier_name,
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Order updated successfully",
      data: order,
    });
  } catch (error) {
    console.error("UPDATE ADMIN ORDER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   DELETE ADMIN ORDER
-------------------------------- */

const deleteAdminOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const order = await AdminOrder.deleteAdminOrder(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Order deleted successfully",
      data: order,
    });
  } catch (error) {
    console.error("DELETE ADMIN ORDER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/* --------------------------------
   DELETE ALL ADMIN ORDERS
-------------------------------- */

const deleteAllAdminOrders = async (req, res) => {
  try {
    const deletedOrders = await AdminOrder.deleteAllAdminOrders();

    return res.status(200).json({
      success: true,
      message: "All admin orders deleted successfully",
      count: deletedOrders.length,
      data: deletedOrders,
    });
  } catch (error) {
    console.error("DELETE ALL ADMIN ORDERS ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

async function findActiveHubForPincode(pincode) {
  const normalizedPincode = String(pincode ?? "").trim();

  if (!/^\d{6}$/.test(normalizedPincode)) {
    throw new Error("Customer pincode must contain 6 digits.");
  }

  const numericPincode = Number(normalizedPincode);

  // First priority: match the hub's primary pincode.
  let result = await pool.query(
    `
      SELECT
        h.hubid AS id,
        h.hubpincode AS pincode
      FROM hubs h
      WHERE h.hubpincode = $1
        AND h.is_active = 1
      LIMIT 1
    `,
    [numericPincode],
  );

  if (result.rows.length > 0) {
    return result.rows[0];
  }

  // Second priority: match an active hub route.
  result = await pool.query(
    `
      SELECT
        h.hubid AS id,
        h.hubpincode AS pincode
      FROM hubroute hr
      INNER JOIN hubs h
        ON h.hubid = hr.hubid
      WHERE hr.hubroutepincode = $1
        AND hr.is_active = 1
        AND h.is_active = 1
      LIMIT 1
    `,
    [numericPincode],
  );

  if (result.rows.length > 0) {
    return result.rows[0];
  }

  return {
    id: "HUB001",
    pincode: "500018",
  };
}

// async function findActiveHubForPincode(pincode) {
//   const normalizedPincode = String(pincode || "").trim();

//   if (!normalizedPincode) {
//     throw new Error("Customer delivery pincode is missing.");
//   }

//   // First priority: match the hub's primary pincode.
//   let result = await pool.query(
//     `
//       SELECT
//         h.hubid AS id,
//         h.hubname AS name,
//         h.hubpincode AS pincode
//       FROM hubs h
//       WHERE h.hubpincode = $1
//         AND h.is_active = 1
//       LIMIT 1
//     `,
//     [normalizedPincode],
//   );

//   if (result.rows.length > 0) {
//     return result.rows[0];
//   }

//   // Second priority: match an additional pincode in hub routes.
//   result = await pool.query(
//     `
//       SELECT
//         h.hubid AS id,
//         h.hubname AS name,
//         h.hubpincode AS pincode
//       FROM hubroute hr
//       INNER JOIN hubs h
//         ON h.hubid = hr.hubid
//       WHERE hr.hubroutepincode = $1
//         AND hr.is_active = 1
//         AND h.is_active = 1
//       LIMIT 1
//     `,
//     [normalizedPincode],
//   );

//   if (result.rows.length > 0) {
//     return result.rows[0];
//   }

//   throw new Error(
//     `No active hub or hub route is configured for delivery pincode ${normalizedPincode}.`,
//   );
// }

/* --------------------------------
   VERIFY / ACCEPT ADMIN ORDER
-------------------------------- */

const verifyAdminOrder = async (req, res) => {
  try {
    const { id } = req.params;

    // Prevent req.body undefined error
    const { status, delivery_method } = req.body || {};

    // --------------------------------
    // VALIDATE DELIVERY METHOD
    // --------------------------------

    if (!delivery_method) {
      return res.status(400).json({
        success: false,
        message: "Delivery method is required",
      });
    }

    // --------------------------------
    // GET EXISTING ORDER
    // --------------------------------

    const existingOrder = await AdminOrder.getAdminOrderById(id);

    if (!existingOrder) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    console.log("ADMIN ORDER BEFORE VERIFY:", existingOrder);

    // --------------------------------
    // VERIFY / ACCEPT ORDER
    // --------------------------------

    const order = await AdminOrder.verifyAdminOrder(id, {
      status: status || "PROCESSING",
      delivery_method,
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }
    // try {
    //   const customerPhone = existingOrder.customer_phone;

    //   if (customerPhone) {
    //     const confirmationMessage = `ManaGanuga: Order ${order.id} confirmed successfully. Thank you for shopping with us.`;

    //     await sendSMS(
    //       String(customerPhone),
    //       confirmationMessage,
    //       process.env.SMS_ORDER_CONFIRMED_TEMPLATE_ID,
    //     );

    //     console.log(
    //       `ORDER CONFIRMATION SMS SENT: Order ${order.id} -> ${customerPhone}`,
    //     );
    //   } else {
    //     console.warn(
    //       `ORDER CONFIRMATION SMS SKIPPED: No mobile number for order ${order.id}`,
    //     );
    //   }
    // } catch (smsError) {
    //   console.error(
    //     `ORDER CONFIRMATION SMS FAILED FOR ORDER ${order.id}:`,
    //     smsError.message,
    //   );
    // }

    // --------------------------------
    // MANAGANUGA DELIVERY
    // --------------------------------

    if (String(delivery_method).toUpperCase() === "MANAGANUGA") {
      // console.log(`Creating Xpressbees shipment for order ${order.id}`);
      console.log(`Creating Shiprocket shipment for order ${order.id}`);

      if (!existingOrder.customer_name) {
        throw new Error("Customer name is missing");
      }

      if (!existingOrder.customer_phone) {
        throw new Error("Customer phone number is missing");
      }

      if (!existingOrder.address) {
        throw new Error("Customer address is missing");
      }

      if (!existingOrder.city) {
        throw new Error("Customer city is missing");
      }

      if (!existingOrder.state) {
        throw new Error("Customer state is missing");
      }

      if (!existingOrder.pincode) {
        throw new Error("Customer pincode is missing");
      }

      // if (!order.warehouse_id) {
      //   throw new Error("Warehouse is not assigned to this order");
      // }

      // const warehouse = await Warehouse.getWarehouseById(order.warehouse_id);

      // if (!warehouse) {
      //   throw new Error(`Warehouse with id ${order.warehouse_id} not found`);
      // }

      // if (!warehouse.name) {
      //   throw new Error("Warehouse name is missing");
      // }

      // const hub = await findActiveHubForPincode(existingOrder.pincode);

      // console.log("SELECTED HUB FOR MANAGANUGA SHIPMENT:", {
      //   hubId: hub.id,
      //   // hubName: hub.name,
      //   hubPincode: hub.pincode,
      //   customerPincode: existingOrder.pincode,
      // });

      // // Reuse the existing Shiprocket service interface.
      // // Shiprocket pickup_location must match a registered pickup location.
      // // const warehouse = {
      // //   name: String(hub.name),
      // // };

      // if (!warehouse.contact_name) {
      //   throw new Error("Warehouse contact name is missing");
      // }

      // if (!warehouse.address) {
      //   throw new Error("Warehouse address is missing");
      // }

      // if (!warehouse.city) {
      //   throw new Error("Warehouse city is missing");
      // }

      // if (!warehouse.state) {
      //   throw new Error("Warehouse state is missing");
      // }

      // if (!warehouse.pincode) {
      //   throw new Error("Warehouse pincode is missing");
      // }

      // if (!warehouse.phone) {
      //   throw new Error("Warehouse phone number is missing");
      // }
      //  if (!existingOrder.items || existingOrder.items.length === 0) {
      //   throw new Error("Order items are missing");
      // }

      const hub = await findActiveHubForPincode(existingOrder.pincode);

      const hubUpdateResult = await pool.query(
        `
  UPDATE public.orders
  SET hubcode = $1
  WHERE id = $2
  RETURNING hubcode
  `,
        [hub.id, order.id],
      );

      if (hubUpdateResult.rowCount === 0) {
        throw new Error(`Could not save hubcode for order ${order.id}`);
      }

      console.log("ORDER HUBCODE SAVED:", {
        orderId: order.id,
        hubcode: hubUpdateResult.rows[0].hubcode,
      });

      // Find the registered Shiprocket pickup location using
      // the selected hub's PRIMARY pincode.
      const pickupLocation = await shiprocketService.getPickupLocationByPincode(
        hub.pincode,
      );

      console.log("SELECTED HUB AND SHIPROCKET PICKUP LOCATION:", {
        hubId: hub.id,
        hubName: hub.name,
        hubPincode: hub.pincode,
        customerPincode: existingOrder.pincode,
        pickupLocation,
      });

      // Shiprocket requires the exact registered pickup-location name.
      const warehouse = {
        name: pickupLocation,
      };

      if (!existingOrder.items || existingOrder.items.length === 0) {
        throw new Error("Order items are missing");
      }

      //   const isPaid =
      //     String(order.payment_status || "").toUpperCase() === "PAID";

      //   const paymentType = isPaid ? "prepaid" : "cod";

      //   const collectableAmount = isPaid ? 0 : Number(order.total_amount);

      //   // CREATE XPRESSBEES PAYLOAD

      //   const shipmentPayload = {
      //     order_number: String(order.id),

      //     payment_type: paymentType,

      //     order_amount: Number(order.total_amount),

      //     package_weight: 500,

      //     package_length: 10,

      //     package_breadth: 10,

      //     package_height: 10,

      //     request_auto_pickup: "yes",

      //     consignee: {
      //       name: String(existingOrder.customer_name),

      //       address: String(existingOrder.address),

      //       address_2: "",

      //       city: String(existingOrder.city),

      //       state: String(existingOrder.state),

      //       pincode: String(existingOrder.pincode),

      //       phone: String(existingOrder.customer_phone),
      //     },

      //     pickup: {
      //       warehouse_name: String(warehouse.name),

      //       name: String(warehouse.contact_name),

      //       address: String(warehouse.address),

      //       address_2: "",

      //       city: String(warehouse.city),

      //       state: String(warehouse.state),

      //       pincode: String(warehouse.pincode),

      //       phone: String(warehouse.phone),
      //     },

      //     order_items: existingOrder.items.map((item) => ({
      //       name: String(item.product_name),

      //       qty: Number(item.quantity),

      //       price: Number(item.unit_price),

      //       sku: String(item.product_id),
      //     })),

      //     collectable_amount: collectableAmount,
      //   };

      //   console.log(
      //     "XPRESSBEES ADMIN SHIPMENT PAYLOAD:",
      //     JSON.stringify(shipmentPayload, null, 2),
      //   );

      //   // CREATE XPRESSBEES SHIPMENT

      //   let shipment;

      //   try {
      //     shipment = await xpressbeesService.createShipment(shipmentPayload);

      //     console.log(
      //       "XPRESSBEES ADMIN SHIPMENT RESPONSE:",
      //       JSON.stringify(shipment, null, 2),
      //     );
      //   } catch (shipmentError) {
      //     console.error(
      //       "XPRESSBEES ADMIN SHIPMENT ERROR:",
      //       shipmentError.response?.data || shipmentError.message,
      //     );

      //     throw new Error(
      //       shipmentError.response?.data?.message ||
      //         shipmentError.message ||
      //         "Xpressbees shipment creation failed",
      //     );
      //   }

      //   // GET AWB NUMBER

      //   const awbNumber =
      //     shipment?.awb_number ||
      //     shipment?.awb ||
      //     shipment?.tracking_number ||
      //     shipment?.awbNumber ||
      //     shipment?.data?.awb_number ||
      //     shipment?.data?.awb ||
      //     shipment?.data?.tracking_number;

      //   if (!awbNumber) {
      //     console.error("Xpressbees response did not contain AWB:", shipment);

      //     throw new Error(
      //       "Xpressbees shipment created but AWB number was not returned",
      //     );
      //   }

      //   // SAVE SHIPMENT DETAILS

      //   const updatedOrder = await AdminOrder.updateShipmentDetails(order.id, {
      //     tracking_number: String(awbNumber),
      //     courier_name: "Xpressbees",
      //   });

      //   return res.status(200).json({
      //     success: true,

      //     message:
      //       "Order verified, accepted and Xpressbees shipment created successfully",

      //     data: updatedOrder,

      //     shipment,
      //   });
      // }

      const isPaid =
        String(order.payment_status || "").toUpperCase() === "PAID";

      const shipmentPayload = {
        order: {
          id: order.id,
          total_amount: Number(order.actual_amount ?? order.total_amount),
          delivery_charge: Number(order.delivery_charge || 0),
          payment_status: order.payment_status,
          email: existingOrder.customer_email || existingOrder.email || "",
        },

        address: {
          full_name: String(existingOrder.customer_name),
          address_line1: String(existingOrder.address),
          address_line2: "",
          city: String(existingOrder.city),
          state: String(existingOrder.state),
          postal_code: String(existingOrder.pincode),
          phone: String(existingOrder.customer_phone),
          email: existingOrder.customer_email || existingOrder.email || "",
        },

        warehouse: {
          name: String(warehouse.name),
        },

        items: existingOrder.items.map((item) => ({
          name: String(item.product_name),
          qty: Number(item.quantity),
          price: Number(item.unit_price),
          sku: String(item.product_id),
        })),

        // Existing weight was 500 grams; Shiprocket expects kilograms.
        packageDetails: {
          weight: 0.5,
          length: 10,
          breadth: 10,
          height: 10,
        },
      };

      let shipment;

      try {
        shipment = await shiprocketService.createShipment(shipmentPayload);

        console.log(
          "SHIPROCKET ADMIN SHIPMENT RESPONSE:",
          JSON.stringify(shipment, null, 2),
        );
      } catch (shipmentError) {
        const shiprocketError = shipmentError.response?.data;
        console.error(
          "SHIPROCKET ADMIN SHIPMENT ERROR:",
          shiprocketError || shipmentError.message,
        );

        const shiprocketDetails =
          shiprocketError?.message ||
          (shiprocketError?.errors
            ? JSON.stringify(shiprocketError.errors)
            : shiprocketError
              ? JSON.stringify(shiprocketError)
              : shipmentError.message);

        throw new Error(
          `Shiprocket request failed${
            shipmentError.response?.status
              ? ` (${shipmentError.response.status})`
              : ""
          }: ${shiprocketDetails || "Unknown provider error"}`,
        );
      }

      const awbNumber =
        shipment?.awb_code ||
        shipment?.awb?.response?.data?.awb_code ||
        shipment?.awb?.awb_code ||
        shipment?.order?.awb_code;
      if (!awbNumber) {
        console.error(
          "Shiprocket order response did not contain an AWB:",
          shipment,
        );

        throw new Error(
          "Shiprocket order may have been created, but an AWB was not returned. Check Shiprocket before retrying.",
        );
      }

      console.log(
        `SHIPROCKET AWB VERIFIED: Order ${order.id}, AWB ${awbNumber}`,
      );

      // Save shipment details before sending the confirmation SMS.
      const updatedOrder = await AdminOrder.updateShipmentDetails(order.id, {
        tracking_number: String(awbNumber),
        courier_name: "Shiprocket",
      });

      // Send order-confirmation SMS only after AWB verification.
      try {
        const customerPhone = existingOrder.customer_phone;

        if (customerPhone) {
          const confirmationMessage =
            `ManaGanuga: Order ${order.id} confirmed successfully. ` +
            `AWB: ${awbNumber}. Thank you for shopping with us.`;

          await sendSMS(
            String(customerPhone),
            confirmationMessage,
            process.env.SMS_ORDER_CONFIRMED_TEMPLATE_ID,
          );

          console.log(
            `ORDER CONFIRMATION SMS SENT: Order ${order.id}, AWB ${awbNumber}`,
          );
        } else {
          console.warn(
            `ORDER CONFIRMATION SMS SKIPPED: No mobile number for order ${order.id}`,
          );
        }
      } catch (smsError) {
        console.error(
          `ORDER CONFIRMATION SMS FAILED FOR ORDER ${order.id}:`,
          smsError.message,
        );
      }

      // if (!awbNumber) {
      //   console.error(
      //     "Shiprocket order response did not contain an AWB:",
      //     shipment,
      //   );

      //   throw new Error(
      //     "Shiprocket order may have been created, but an AWB was not returned. Check Shiprocket before retrying.",
      //   );
      // }

      // const updatedOrder = await AdminOrder.updateShipmentDetails(order.id, {
      //   tracking_number: String(awbNumber),
      //   courier_name: "Shiprocket",
      // });

      return res.status(200).json({
        success: true,
        message:
          "Order verified, accepted and Shiprocket shipment created successfully",
        data: updatedOrder,
        shipment,
      });
    }

    // OTHER DELIVERY METHODS

    return res.status(200).json({
      success: true,
      message: "Order verified and accepted successfully",
      data: order,
    });
  } catch (error) {
    console.error("VERIFY ADMIN ORDER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  // createAdminOrder,
  getAdminOrders,
  getAdminOrderById,
  updateAdminOrder,
  // deleteAdminOrder,
  // deleteAllAdminOrders,
  verifyAdminOrder,
};
