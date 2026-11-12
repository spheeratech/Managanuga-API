const axios = require("axios");
const pool = require("../../db");

const BASE_URL = "https://apiv2.shiprocket.in/v1/external";

// =====================================================
// SHIPROCKET LOG HELPER
// =====================================================

const saveShiprocketLog = async ({
  order_id = null,
  operation,
  awb_code = null,
  request_payload = null,
  response_payload = null,
  http_status = null,
  is_success = false,
  error_message = null,
}) => {
  try {
    await pool.query(
      `
        INSERT INTO public.shiprocket_log (
          order_id,
          operation,
          awb_code,
          request_payload,
          response_payload,
          http_status,
          is_success,
          error_message
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      `,
      [
        order_id,
        operation,
        awb_code,
        request_payload == null ? null : JSON.stringify(request_payload),
        response_payload == null ? null : JSON.stringify(response_payload),
        http_status,
        is_success,
        error_message,
      ],
    );

    console.log(`SHIPROCKET LOG SAVED: ${operation}`);
  } catch (error) {
    // Logging failures must never interrupt the existing shipment flow.
    console.error("SHIPROCKET DB LOG ERROR:", error.message);
  }
};

// =====================================================
// AUTHENTICATION
// =====================================================

let token = null;
let tokenExpiry = null;
let loginPromise = null;

const login = async () => {
  // Reuse an existing valid token.
  if (token && tokenExpiry && Date.now() < tokenExpiry) {
    return token;
  }

  if (!loginPromise) {
    loginPromise = (async () => {
      let response = null;
      let logSaved = false;

      try {
        response = await axios.post(
          `${BASE_URL}/auth/login`,
          {
            email: process.env.SHIPROCKET_EMAIL,
            password: process.env.SHIPROCKET_PASSWORD,
          },
          {
            headers: {
              "Content-Type": "application/json",
            },
          },
        );

        if (!response.data?.token) {
          await saveShiprocketLog({
            operation: "LOGIN",
            request_payload: {
              credentials_masked: true,
            },
            response_payload: {
              token_received: false,
              response_keys:
                response.data && typeof response.data === "object"
                  ? Object.keys(response.data).filter((key) => key !== "token")
                  : [],
            },
            http_status: response.status,
            is_success: false,
            error_message: "Shiprocket login token missing",
          });

          logSaved = true;

          throw new Error("Shiprocket login failed: token missing");
        }

        token = response.data.token;
        tokenExpiry = Date.now() + 9 * 24 * 60 * 60 * 1000;

        await saveShiprocketLog({
          operation: "LOGIN",
          request_payload: {
            credentials_masked: true,
          },
          response_payload: {
            token_received: true,
            response_keys:
              response.data && typeof response.data === "object"
                ? Object.keys(response.data).filter((key) => key !== "token")
                : [],
          },
          http_status: response.status,
          is_success: true,
        });

        logSaved = true;

        console.log("SHIPROCKET LOGIN SUCCESS");

        return token;
      } catch (error) {
        if (!logSaved) {
          await saveShiprocketLog({
            operation: "LOGIN",
            request_payload: {
              credentials_masked: true,
            },
            response_payload: {
              response_received: Boolean(
                response?.data || error.response?.data,
              ),
              response_keys:
                (response?.data || error.response?.data) &&
                typeof (response?.data || error.response?.data) === "object"
                  ? Object.keys(response?.data || error.response?.data).filter(
                      (key) => key !== "token",
                    )
                  : [],
            },
            http_status: response?.status || error.response?.status || null,
            is_success: false,
            error_message: "Shiprocket login request failed",
          });
        }

        console.error("SHIPROCKET LOGIN FAILED:", error.message);

        throw error;
      }
    })().finally(() => {
      loginPromise = null;
    });
  }

  return loginPromise;
};

const getHeaders = async () => ({
  Authorization: `Bearer ${await login()}`,
  "Content-Type": "application/json",
});

// =====================================================
// PICKUP LOCATION
// =====================================================

const getPickupLocationByPincode = async (pincode) => {
  const normalizedPincode = String(pincode ?? "").trim();

  if (!/^\d{6}$/.test(normalizedPincode)) {
    throw new Error("Invalid pickup pincode.");
  }

  const headers = await getHeaders();

  let response;

  // Fetch registered Shiprocket pickup locations.
  try {
    response = await axios.get(`${BASE_URL}/settings/company/pickup`, {
      headers,
    });

    await saveShiprocketLog({
      operation: "PICKUP_LOCATION",
      request_payload: {
        pincode: normalizedPincode,
      },
      response_payload: {
        locations_received: Array.isArray(
          response.data?.data?.shipping_address,
        ),
        location_count: Array.isArray(response.data?.data?.shipping_address)
          ? response.data.data.shipping_address.length
          : 0,
      },
      http_status: response.status,
      is_success: true,
    });
  } catch (error) {
    await saveShiprocketLog({
      operation: "PICKUP_LOCATION",
      request_payload: {
        pincode: normalizedPincode,
      },
      response_payload: {
        response_received: Boolean(error.response?.data),
        response_keys:
          error.response?.data && typeof error.response.data === "object"
            ? Object.keys(error.response.data)
            : [],
      },
      http_status: error.response?.status || null,
      is_success: false,
      error_message: "Shiprocket pickup location request failed",
    });

    throw error;
  }

  // Match the registered pickup location.
  try {
    const locations = response.data?.data?.shipping_address;

    if (!Array.isArray(locations)) {
      throw new Error(
        "Unable to retrieve registered Shiprocket pickup locations.",
      );
    }

    const matches = locations.filter(
      (location) =>
        String(location.pin_code ?? "").trim() === normalizedPincode,
    );

    if (matches.length === 0) {
      throw new Error(
        `No registered Shiprocket pickup location found for pincode ${normalizedPincode}.`,
      );
    }

    if (matches.length > 1) {
      throw new Error(
        `Multiple Shiprocket pickup locations use pincode ${normalizedPincode}. Please resolve the ambiguity before creating the shipment.`,
      );
    }

    const pickupLocation = matches[0].pickup_location;

    if (!pickupLocation) {
      throw new Error(
        `Shiprocket pickup location name is missing for pincode ${normalizedPincode}.`,
      );
    }

    await saveShiprocketLog({
      operation: "PICKUP_LOCATION_MATCH",
      request_payload: {
        pincode: normalizedPincode,
      },
      response_payload: {
        match_found: true,
      },
      http_status: response.status,
      is_success: true,
    });

    return String(pickupLocation);
  } catch (error) {
    await saveShiprocketLog({
      operation: "PICKUP_LOCATION_MATCH",
      request_payload: {
        pincode: normalizedPincode,
      },
      response_payload: {
        match_found: false,
      },
      http_status: response.status,
      is_success: false,
      error_message: "No valid Shiprocket pickup location match found",
    });

    throw error;
  }
};

// =====================================================
// CREATE SHIPMENT
// =====================================================

const createShipment = async ({
  order,
  address,
  warehouse,
  items,
  packageDetails,
}) => {
  const headers = await getHeaders();

  // Preserve existing validation behavior without creating
  // SHIPMENT_VALIDATION log entries.
  const logShipmentValidationFailure = async (message) => {
    throw new Error(message);
  };

  const fullName = String(address.full_name || "Customer").trim();

  const nameParts = fullName.split(/\s+/);
  const firstName = nameParts.shift() || "Customer";
  const lastName = nameParts.join(" ");

  const amount = Number(order.total_amount);
  const deliveryCharge = Number(order.delivery_charge || 0);

  const weight = Number(packageDetails?.weight ?? 0.5);
  const length = Number(packageDetails?.length ?? 10);
  const breadth = Number(packageDetails?.breadth ?? 10);
  const height = Number(packageDetails?.height ?? 10);

  if (
    !Number.isFinite(weight) ||
    weight <= 0 ||
    !Number.isFinite(length) ||
    length <= 0 ||
    !Number.isFinite(breadth) ||
    breadth <= 0 ||
    !Number.isFinite(height) ||
    height <= 0
  ) {
    await logShipmentValidationFailure(
      "Invalid shipment package dimensions or weight",
    );
  }

  if (!Number.isFinite(amount) || amount <= 0) {
    await logShipmentValidationFailure("Invalid order total amount");
  }

  if (
    !Number.isFinite(deliveryCharge) ||
    deliveryCharge < 0 ||
    deliveryCharge > amount
  ) {
    await logShipmentValidationFailure("Invalid delivery charge");
  }

  const isPaid = String(order.payment_status || "").toUpperCase() === "PAID";

  if (!Array.isArray(items) || items.length === 0) {
    await logShipmentValidationFailure("No valid order items provided");
  }

  const orderItems = [];

  for (const item of items) {
    const qty = Number(item?.qty);
    const price = Number(item?.price);

    if (!Number.isFinite(qty) || qty <= 0) {
      await logShipmentValidationFailure("Invalid order item quantity");
    }

    if (!Number.isFinite(price) || price < 0) {
      await logShipmentValidationFailure("Invalid order item price");
    }

    orderItems.push({
      name: String(item.name),
      sku: String(item.sku),
      units: qty,
      selling_price: price,
    });
  }

  // Existing Shiprocket payload is preserved.
  const payload = {
    order_id: String(order.id),
    order_date: new Date().toISOString().slice(0, 10),

    pickup_location: warehouse.name,

    billing_customer_name: firstName,
    billing_last_name: lastName,
    billing_address: address.address_line1,
    billing_address_2: address.address_line2 || "",
    billing_city: address.city,
    billing_state: address.state,
    billing_country: "India",
    billing_pincode: String(address.postal_code),
    billing_email: order.email || address.email || "",
    billing_phone: String(address.phone),

    shipping_is_billing: true,
    order_items: orderItems,

    payment_method: isPaid ? "Prepaid" : "COD",
    shipping_charges: deliveryCharge,
    sub_total: amount,

    weight,
    length,
    breadth,
    height,
  };

  console.log("SHIPROCKET ORDER REQUEST SUMMARY:", {
    order_id: order?.id,
    order_items_count: payload.order_items?.length || 0,
    payment_method: payload.payment_method,
    sub_total: payload.sub_total,
    pickup_location: payload.pickup_location,
    billing_details_masked: true,
    shipping_details_masked: true,
  });

  // Safe request summary: never store customer information.
  const safeRequestPayload = {
    order_id: payload.order_id,
    order_date: payload.order_date,
    pickup_location: payload.pickup_location,
    billing_details_masked: true,
    shipping_is_billing: payload.shipping_is_billing,
    item_count: Array.isArray(payload.order_items)
      ? payload.order_items.length
      : 0,
    payment_method: payload.payment_method,
    shipping_charges: payload.shipping_charges,
    sub_total: payload.sub_total,
    weight: payload.weight,
    length: payload.length,
    breadth: payload.breadth,
    height: payload.height,
  };

  // 1. Create the Shiprocket order.
  let orderResponse;

  try {
    orderResponse = await axios.post(
      `${BASE_URL}/orders/create/adhoc`,
      payload,
      { headers },
    );

    await saveShiprocketLog({
      order_id: String(order.id),
      operation: "CREATE_SHIPMENT",
      request_payload: safeRequestPayload,
      response_payload: {
        order_id: orderResponse.data?.order_id || null,
        shipment_id: orderResponse.data?.shipment_id || null,
        status: orderResponse.data?.status || null,
        status_code: orderResponse.data?.status_code || null,
        awb_code: orderResponse.data?.awb_code || null,
        response_keys:
          orderResponse.data && typeof orderResponse.data === "object"
            ? Object.keys(orderResponse.data)
            : [],
      },
      http_status: orderResponse.status,
      is_success: true,
    });

    console.log("SHIPROCKET ORDER CREATED SUCCESSFULLY");
  } catch (error) {
    await saveShiprocketLog({
      order_id: String(order.id),
      operation: "CREATE_SHIPMENT",
      request_payload: safeRequestPayload,
      response_payload: {
        response_received: Boolean(error.response?.data),
        response_keys:
          error.response?.data && typeof error.response.data === "object"
            ? Object.keys(error.response.data)
            : [],
      },
      http_status: error.response?.status || null,
      is_success: false,
      error_message: "Shiprocket shipment creation request failed",
    });

    console.error("SHIPROCKET ORDER CREATION FAILED:", error.message);

    throw error;
  }

  // 2. Check whether Shiprocket returned a shipment ID.
  const shipmentId = orderResponse.data?.shipment_id;

  if (!shipmentId) {
    await saveShiprocketLog({
      order_id: String(order.id),
      operation: "CREATE_SHIPMENT_RESULT",
      request_payload: {
        shiprocket_order_id: orderResponse.data?.order_id || null,
      },
      response_payload: {
        shipment_id_returned: false,
        shipment_id: null,
      },
      http_status: orderResponse.status,
      is_success: false,
      error_message: "Shiprocket order response did not contain a shipment ID",
    });

    return {
      order: orderResponse.data,
      shipment_id: null,
      awb_code: null,
      message:
        "Order created or accepted; shipment ID not returned. Check Shiprocket order details.",
    };
  }

  await saveShiprocketLog({
    order_id: String(order.id),
    operation: "CREATE_SHIPMENT_RESULT",
    request_payload: {
      shiprocket_order_id: orderResponse.data?.order_id || null,
    },
    response_payload: {
      shipment_id_returned: true,
      shipment_id: shipmentId,
    },
    http_status: orderResponse.status,
    is_success: true,
  });

  // 3. Request courier/AWB assignment.
  const awbPayload = {
    shipment_id: shipmentId,
  };

  let awbResponse;

  // 1. Call the AWB assignment API.
  try {
    awbResponse = await axios.post(
      `${BASE_URL}/courier/assign/awb`,
      awbPayload,
      { headers },
    );
  } catch (error) {
    // API request failed.
    await saveShiprocketLog({
      order_id: String(order.id),
      operation: "AWB_ASSIGNMENT",
      request_payload: {
        shipment_id: shipmentId,
      },
      response_payload: {
        response_received: Boolean(error.response?.data),
        response_keys:
          error.response?.data && typeof error.response.data === "object"
            ? Object.keys(error.response.data)
            : [],
      },
      http_status: error.response?.status || null,
      is_success: false,
      error_message: "Shiprocket AWB assignment request failed",
    });

    // AWB result also failed.
    await saveShiprocketLog({
      order_id: String(order.id),
      operation: "AWB_ASSIGNMENT_RESULT",
      request_payload: {
        shipment_id: shipmentId,
      },
      response_payload: {
        awb_returned: false,
      },
      http_status: error.response?.status || null,
      is_success: false,
      error_message: "AWB assignment request failed",
    });

    console.error("SHIPROCKET AWB ASSIGNMENT FAILED:", error.message);

    throw error;
  }

  // 2. Extract AWB and courier details.
  const awbCode =
    awbResponse.data?.response?.data?.awb_code ||
    awbResponse.data?.awb_code ||
    null;

  const courierName =
    awbResponse.data?.response?.data?.courier_name ||
    awbResponse.data?.courier_name ||
    null;

  // 3. API request succeeded.
  await saveShiprocketLog({
    order_id: String(order.id),
    operation: "AWB_ASSIGNMENT",
    request_payload: {
      shipment_id: shipmentId,
    },
    response_payload: {
      response_received: true,
      awb_returned: Boolean(awbCode),
      courier_returned: Boolean(courierName),
    },
    http_status: awbResponse.status,
    is_success: true,
  });

  // 4. Record whether an AWB was actually returned.
  await saveShiprocketLog({
    order_id: String(order.id),
    operation: "AWB_ASSIGNMENT_RESULT",
    awb_code: awbCode,
    request_payload: {
      shipment_id: shipmentId,
    },
    response_payload: {
      awb_returned: Boolean(awbCode),
      awb_code: awbCode,
      courier_returned: Boolean(courierName),
      courier_name: courierName,
    },
    http_status: awbResponse.status,
    is_success: Boolean(awbCode),
    error_message: awbCode ? null : "Shiprocket did not return an AWB code",
  });

  // 5. Stop if AWB is missing.
  // This is outside the API catch block to avoid duplicate logs.
  if (!awbCode) {
    throw new Error(
      "Shiprocket AWB assignment completed without returning an AWB code",
    );
  }

  // 6. Preserve the original return structure.
  return {
    order: orderResponse.data,
    awb: awbResponse.data,
    shipment_id: shipmentId,
    awb_code: awbCode,
    courier_name: courierName,
  };
};

// =====================================================
// TRACK SHIPMENT
// =====================================================

const trackShipment = async (awb, orderId = null) => {
  if (!awb) {
    throw new Error("AWB number is required for tracking");
  }

  const headers = await getHeaders();
  const normalizedAwb = String(awb).trim();

  try {
    const response = await axios.get(
      `${BASE_URL}/courier/track/awb/${encodeURIComponent(normalizedAwb)}`,
      { headers },
    );

    await saveShiprocketLog({
      order_id: orderId ? String(orderId) : null,

      operation: "TRACK_SHIPMENT",
      awb_code: normalizedAwb,
      request_payload: {
        awb: normalizedAwb,
      },
      response_payload: {
        track_status: response.data?.tracking_data?.track_status ?? null,
        shipment_status: response.data?.tracking_data?.shipment_status ?? null,
        current_status:
          response.data?.tracking_data?.shipment_track?.[0]?.current_status ??
          null,
        tracked_awb:
          response.data?.tracking_data?.shipment_track?.[0]?.awb_code ?? null,
        courier_name:
          response.data?.tracking_data?.shipment_track?.[0]?.courier_name ??
          null,
      },
      http_status: response.status,
      is_success: true,
    });

    console.log("SHIPROCKET TRACKING RESPONSE LOGGED");

    // Preserve the original Shiprocket response for existing callers.
    return response.data;
  } catch (error) {
    await saveShiprocketLog({
      order_id: orderId ? String(orderId) : null,

      operation: "TRACK_SHIPMENT",
      awb_code: normalizedAwb,
      request_payload: {
        awb: normalizedAwb,
      },
      response_payload: {
        response_received: Boolean(error.response?.data),
        response_keys:
          error.response?.data && typeof error.response.data === "object"
            ? Object.keys(error.response.data)
            : [],
      },
      http_status: error.response?.status || null,
      is_success: false,
      error_message: "Shiprocket tracking request failed",
    });

    console.error("SHIPROCKET TRACKING FAILED:", error.message);

    throw error;
  }
};
// =====================================================
// GET SHIPROCKET ORDER STATUS
// =====================================================

const getOrderStatus = async (shiprocketOrderId, orderId = null) => {
  if (!shiprocketOrderId) {
    throw new Error("Shiprocket order ID is required");
  }

  const headers = await getHeaders();
  const normalizedOrderId = String(shiprocketOrderId).trim();

  try {
    const response = await axios.get(
      `${BASE_URL}/orders/show/${encodeURIComponent(normalizedOrderId)}`,
      { headers },
    );

    const shiprocketOrder = response.data?.data || response.data || {};

    await saveShiprocketLog({
      order_id: orderId ? String(orderId) : null,
      operation: "GET_ORDER_STATUS",
      request_payload: {
        shiprocket_order_id: normalizedOrderId,
      },
      response_payload: {
        shiprocket_order_id: shiprocketOrder.order_id || normalizedOrderId,
        status: shiprocketOrder.status || null,
        status_code: shiprocketOrder.status_code ?? null,
      },
      http_status: response.status,
      is_success: true,
    });

    return {
      shiprocket_order_id: shiprocketOrder.order_id || normalizedOrderId,
      status: shiprocketOrder.status || null,
      status_code: shiprocketOrder.status_code ?? null,
    };
  } catch (error) {
    await saveShiprocketLog({
      order_id: orderId ? String(orderId) : null,
      operation: "GET_ORDER_STATUS",
      request_payload: {
        shiprocket_order_id: normalizedOrderId,
      },
      response_payload: {
        response_received: Boolean(error.response?.data),
      },
      http_status: error.response?.status || null,
      is_success: false,
      error_message: "Shiprocket order status request failed",
    });

    console.error("SHIPROCKET ORDER STATUS FAILED:", error.message);
    throw error;
  }
};
// =====================================================
// EXPORTS
// =====================================================

module.exports = {
  login,
  createShipment,
  trackShipment,
  getPickupLocationByPincode,
  saveShiprocketLog,
  getOrderStatus,
};
