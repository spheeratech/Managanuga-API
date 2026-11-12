const pool = require("../../db");
const AdminOrder = require("../models/AdminOrder");
// const xpressbeesService = require("../services/xpressbeesService");
const shiprocketService = require("../services/shiprocketService");
// const Warehouse = require("../models/Warehouse");
const { sendSMS } = require("../services/smsService");
const Notification = require("../models/Notification");
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

/* --------------------------------
   VERIFY / ACCEPT ADMIN ORDER
-------------------------------- */

const verifyAdminOrder = async (req, res) => {
  try {
    const { id } = req.params;

    // Prevent req.body undefined error
    const { status, delivery_method } = req.body || {};
    console.log("========== VERIFY ADMIN ORDER API HIT ==========");
    console.log("ORDER ID:", req.params.id);
    console.log("DELIVERY METHOD:", delivery_method);

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
    // Prevent duplicate shipment creation.
    if (
      String(delivery_method).toUpperCase() === "MANAGANUGA" &&
      existingOrder.tracking_number
    ) {
      return res.status(409).json({
        success: false,
        message: "Shipment already exists for this order.",
        tracking_number: existingOrder.tracking_number,
      });
    }

    // Prevent re-verification of an already accepted order.
    if (
      existingOrder.admin_verified === true ||
      existingOrder.admin_accepted === true
    ) {
      return res.status(409).json({
        success: false,
        message: "This order has already been accepted.",
      });
    }
    // console.log("ADMIN ORDER BEFORE VERIFY:", existingOrder);
    console.log("ADMIN ORDER BEFORE VERIFY:", {
      id: existingOrder.id,
      order_id: existingOrder.order_id,
      status: existingOrder.status,
      delivery_method: existingOrder.delivery_method || null,
    });

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

    // --------------------------------
    // CREATE ORDER ACCEPTANCE NOTIFICATION FOR ADMIN
    // --------------------------------
    try {
      const acceptedByUserId = String(req.body?.acceptedByUserId || "").trim();

      if (!acceptedByUserId) {
        console.warn(
          `Admin acceptance notification skipped: acceptedByUserId missing for order ${order.id}`,
        );
      } else {
        // Resolve the customer ID for the notification message.
        const customerResult = await pool.query(
          `
          SELECT user_id
          FROM public.orders
          WHERE id = $1::integer
          LIMIT 1
          `,
          [Number(order.id)],
        );

        const customerUserId = customerResult.rows[0]?.user_id;

        await Notification.createNotification({
          userId: acceptedByUserId,
          title: "Order Accepted Successfully",
          message: `Order ${order.order_id || order.id} for customer ${customerUserId || "Unknown"} has been verified and accepted.`,
          type: "ORDER_ACCEPTED",
          referenceId: Number(order.id) || null,
        });

        console.log(
          `ORDER ACCEPTANCE NOTIFICATION CREATED: Order ${order.id}, Admin ${acceptedByUserId}`,
        );
      }
    } catch (notificationError) {
      console.error(
        `ORDER ACCEPTANCE NOTIFICATION FAILED FOR ORDER ${order.id}:`,
        notificationError.message,
      );
    }

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
      const pickupLocation = await shiprocketService.getPickupLocationByPincode(
        hub.pincode,
      );

      console.log("SELECTED HUB AND SHIPROCKET PICKUP LOCATION:", {
        hubId: hub.id,
        hubPincode: hub.pincode,
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

      // const isPaid =
      //   String(order.payment_status || "").toUpperCase() === "PAID";

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
        console.log("CALLING shiprocketService.createShipment()");

        shipment = await shiprocketService.createShipment(shipmentPayload);

        console.log("SHIPROCKET SHIPMENT RESPONSE SUMMARY:", {
          order_id: order.id,
          response_keys:
            shipment && typeof shipment === "object"
              ? Object.keys(shipment)
              : [],
          shipment_id:
            shipment?.shipment_id || shipment?.order?.shipment_id || null,
          awb_received: Boolean(
            shipment?.awb_code ||
            shipment?.awb?.response?.data?.awb_code ||
            shipment?.awb?.awb_code ||
            shipment?.order?.awb_code,
          ),
        });
      } catch (shipmentError) {
        const httpStatus = shipmentError.response?.status || null;

        console.error("========== SHIPMENT CREATION FAILED ==========");
        console.error("ORDER ID:", order.id);
        console.error("HTTP STATUS:", httpStatus);

        throw new Error(
          `Shiprocket shipment creation failed${
            httpStatus ? ` (${httpStatus})` : ""
          }. Check shiprocket_log for sanitized API details.`,
        );
      }

      // let shipment;

      // try {
      //   shipment = await shiprocketService.createShipment(shipmentPayload);

      //   console.log(
      //     "SHIPROCKET ADMIN SHIPMENT RESPONSE:",
      //     JSON.stringify(shipment, null, 2),
      //   );
      // } catch (shipmentError) {
      //   const shiprocketError = shipmentError.response?.data;
      //   console.error(
      //     "SHIPROCKET ADMIN SHIPMENT ERROR:",
      //     shiprocketError || shipmentError.message,
      //   );

      //   const shiprocketDetails =
      //     shiprocketError?.message ||
      //     (shiprocketError?.errors
      //       ? JSON.stringify(shiprocketError.errors)
      //       : shiprocketError
      //         ? JSON.stringify(shiprocketError)
      //         : shipmentError.message);

      //   throw new Error(
      //     `Shiprocket request failed${
      //       shipmentError.response?.status
      //         ? ` (${shipmentError.response.status})`
      //         : ""
      //     }: ${shiprocketDetails || "Unknown provider error"}`,
      //   );
      // }

      const awbNumber =
        shipment?.awb_code ||
        shipment?.awb?.response?.data?.awb_code ||
        shipment?.awb?.awb_code ||
        shipment?.order?.awb_code;
      if (!awbNumber) {
        console.error("SHIPROCKET AWB MISSING:", {
          order_id: order.id,
          shipment_id:
            shipment?.shipment_id || shipment?.order?.shipment_id || null,
          response_keys:
            shipment && typeof shipment === "object"
              ? Object.keys(shipment)
              : [],
        });

        throw new Error(
          "Shiprocket order may have been created, but an AWB was not returned. Check Shiprocket before retrying.",
        );
      }

      console.log(
        `SHIPROCKET AWB VERIFIED: Order ${order.id}, AWB ${awbNumber}`,
      );

      // const updatedOrder = await AdminOrder.updateShipmentDetails(order.id, {
      //   tracking_number: String(awbNumber),
      //   courier_name: "Shiprocket",
      // });
      const updatedOrder = await AdminOrder.updateShipmentDetails(order.id, {
        tracking_number: String(awbNumber),
        courier_name: "Shiprocket",
      });

      if (!updatedOrder) {
        throw new Error(
          "Order shipment details were not updated. No matching order found.",
        );
      }

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

    // --------------------------------
    // LOG ORDER VERIFICATION / SHIPMENT FAILURE
    // --------------------------------

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
/* --------------------------------
   GET LIVE SHIPROCKET TRACKING
-------------------------------- */

// const getShiprocketTracking = async (req, res) => {
//   try {
//     const { id } = req.params;

//     // Find the order using its internal database ID.
//     const order = await AdminOrder.getAdminOrderById(id);

//     if (!order) {
//       const deliveryMethod = String(order.delivery_method || "")
//         .trim()
//         .toUpperCase()
//         .replace(/[\s-]+/g, "_");

//       if (!["MANAGANUGA", "MANA_GANUGA"].includes(deliveryMethod)) {
//         return res.status(400).json({
//           success: false,
//           message:
//             "Shiprocket tracking is available only for ManaGanuga deliveries",
//         });
//       }
//       return res.status(404).json({
//         success: false,
//         message: "Order not found",
//       });
//     }

//     const awb = String(order.tracking_number || "").trim();

//     if (!awb) {
//       return res.status(404).json({
//         success: false,
//         message: "No Shiprocket AWB is assigned to this order",
//         data: {
//           order_id: order.id,
//           user_id: order.user_id,
//           tracking_number: null,
//           tracking_status: null,
//         },
//       });
//     }

//     // Fetch the latest status from Shiprocket.
//     const trackingResponse = await shiprocketService.trackShipment(
//       awb,
//       order.id,
//     );

//     const trackingData = trackingResponse?.tracking_data || {};
//     const shipmentTrack = Array.isArray(trackingData.shipment_track)
//       ? trackingData.shipment_track
//       : [];

//     const shipment = shipmentTrack[0] || {};

//     const activities = Array.isArray(trackingData.shipment_track_activities)
//       ? trackingData.shipment_track_activities
//       : [];

//     return res.status(200).json({
//       success: true,
//       message: "Live Shiprocket tracking fetched successfully",
//       data: {
//         order_id: order.id,
//         order_number: order.order_id,
//         user_id: order.user_id,
//         tracking_number: awb,
//         courier_name: shipment.courier_name || order.courier_name || null,

//         tracking_status:
//           shipment.current_status ||
//           trackingData.shipment_status ||
//           trackingData.track_status ||
//           "Tracking information unavailable",

//         shipment_status: trackingData.shipment_status || null,
//         track_status: trackingData.track_status || null,

//         estimated_delivery_date: shipment.edd || trackingData.edd || null,

//         delivered_date: shipment.delivered_date || null,

//         activities,
//         shipment_track: shipmentTrack,
//       },
//     });
//   } catch (error) {
//     console.error("GET SHIPROCKET TRACKING ERROR:", {
//       orderId: req.params.id,
//       httpStatus: error.response?.status || null,
//       message: error.message,
//     });

//     return res.status(502).json({
//       success: false,
//       message:
//         error.response?.data?.message ||
//         "Unable to fetch live tracking from Shiprocket",
//     });
//   }
// };
/* --------------------------------
   GET LIVE SHIPROCKET TRACKING
-------------------------------- */

const getShiprocketTracking = async (req, res) => {
  try {
    const { id } = req.params;

    // Find the order using its internal database ID.
    const order = await AdminOrder.getAdminOrderById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found",
      });
    }

    const deliveryMethod = String(order.delivery_method || "")
      .trim()
      .toUpperCase()
      .replace(/[\s-]+/g, "_");

    if (!["MANAGANUGA", "MANA_GANUGA"].includes(deliveryMethod)) {
      return res.status(400).json({
        success: false,
        message:
          "Shiprocket tracking is available only for ManaGanuga deliveries",
      });
    }

    const awb = String(order.tracking_number || "").trim();

    if (!awb) {
      return res.status(404).json({
        success: false,
        message: "No Shiprocket AWB is assigned to this order",
        data: {
          order_id: order.id,
          tracking_number: null,
          shiprocket_order_status: null,
          tracking_status: null,
        },
      });
    }

    // Retrieve the Shiprocket order ID saved during shipment creation.
    const shiprocketOrderResult = await pool.query(
      `
        SELECT response_payload->>'order_id' AS shiprocket_order_id
        FROM public.shiprocket_log
        WHERE order_id = $1
          AND operation = 'CREATE_SHIPMENT'
          AND is_success = TRUE
          AND response_payload->>'order_id' IS NOT NULL
        ORDER BY created_at DESC
        LIMIT 1
      `,
      [String(order.id)],
    );

    const shiprocketOrderId =
      shiprocketOrderResult.rows[0]?.shiprocket_order_id || null;

    // Fetch the exact Shiprocket dashboard order status.
    let shiprocketOrderStatus = null;

    if (shiprocketOrderId) {
      shiprocketOrderStatus = await shiprocketService.getOrderStatus(
        shiprocketOrderId,
        order.id,
      );
    }

    // Fetch courier/AWB tracking separately.
    const trackingResponse = await shiprocketService.trackShipment(
      awb,
      order.id,
    );

    const trackingData = trackingResponse?.tracking_data || {};

    const shipmentTrack = Array.isArray(trackingData.shipment_track)
      ? trackingData.shipment_track
      : [];

    const shipment = shipmentTrack[0] || {};

    const activities = Array.isArray(trackingData.shipment_track_activities)
      ? trackingData.shipment_track_activities
      : [];
    // --------------------------------
    // DETECT SHIPROCKET CANCELLATION
    // --------------------------------

    const shiprocketOrderStatusText = String(
      shiprocketOrderStatus?.status || "",
    )
      .trim()
      .toUpperCase();

    const trackingError = String(trackingData?.error || "")
      .trim()
      .toUpperCase();

    const isShiprocketCancelled =
      ["CANCELLED", "CANCELED"].includes(shiprocketOrderStatusText) ||
      trackingError.includes("AWB HAS BEEN CANCELLED") ||
      trackingError.includes("AWB HAS BEEN CANCELED") ||
      trackingError.includes("SHIPMENT HAS BEEN CANCELLED") ||
      trackingError.includes("SHIPMENT HAS BEEN CANCELED");

    // Update the ManaGanuga database order status.
    let updatedOrderStatus = order.status;

    if (isShiprocketCancelled) {
      const updatedOrder = await AdminOrder.updateShiprocketCancellation(
        order.id,
      );

      if (updatedOrder) {
        updatedOrderStatus = updatedOrder.status;

        console.log("SHIPROCKET CANCELLATION SYNCED TO DATABASE:", {
          orderId: updatedOrder.id,
          status: updatedOrder.status,
        });
      } else {
        console.warn(
          "SHIPROCKET CANCELLATION DETECTED, BUT DATABASE STATUS WAS NOT UPDATED:",
          {
            orderId: order.id,
            existingStatus: order.status,
          },
        );
      }
    }
    return res.status(200).json({
      success: true,
      message: "Live Shiprocket order status and tracking fetched successfully",
      data: {
        order_id: order.id,
        order_number: order.order_id,
        user_id: order.user_id,

        // Exact order-level status from Shiprocket dashboard.
        shiprocket_order_id: shiprocketOrderId,
        shiprocket_order_status: shiprocketOrderStatus?.status || null,
        shiprocket_order_status_code:
          shiprocketOrderStatus?.status_code ?? null,

        // Courier tracking details remain separate.
        tracking_number: awb,
        courier_name: shipment.courier_name || order.courier_name || null,

        tracking_status: isShiprocketCancelled
          ? "Cancelled"
          : shipment.current_status ||
            trackingData.shipment_status ||
            trackingData.track_status ||
            "Tracking information unavailable",

        tracking_error: trackingData.error || null,

        cancellation_detected: isShiprocketCancelled,

        order_status: updatedOrderStatus,

        shipment_status: trackingData.shipment_status || null,
        track_status: trackingData.track_status || null,

        estimated_delivery_date: shipment.edd || trackingData.edd || null,
        delivered_date: shipment.delivered_date || null,

        activities,
        shipment_track: shipmentTrack,
      },
    });
  } catch (error) {
    console.error("GET SHIPROCKET TRACKING ERROR:", {
      orderId: req.params.id,
      httpStatus: error.response?.status || null,
      message: error.message,
    });

    return res.status(502).json({
      success: false,
      message:
        error.response?.data?.message ||
        "Unable to fetch live Shiprocket order status and tracking",
    });
  }
};
module.exports = {
  // createAdminOrder,
  getAdminOrders,
  getAdminOrderById,
  updateAdminOrder,
  getShiprocketTracking,
  // deleteAdminOrder,
  // deleteAllAdminOrders,
  verifyAdminOrder,
};
