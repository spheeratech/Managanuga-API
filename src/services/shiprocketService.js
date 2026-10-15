const axios = require("axios");

const BASE_URL = "https://apiv2.shiprocket.in/v1/external";

let token = null;
let tokenExpiry = null;

const login = async () => {
  // Refresh before the documented 10-day expiry.
  if (token && tokenExpiry && Date.now() < tokenExpiry) {
    return token;
  }

  const response = await axios.post(
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

  if (!response.data.token) {
    throw new Error("Shiprocket login failed");
  }

  token = response.data.token;
  tokenExpiry = Date.now() + 9 * 24 * 60 * 60 * 1000;

  console.log("SHIPROCKET LOGIN SUCCESS");

  return token;
};

const getHeaders = async () => ({
  Authorization: `Bearer ${await login()}`,
  "Content-Type": "application/json",
});

const getPickupLocationByPincode = async (pincode) => {
  const normalizedPincode = String(pincode ?? "").trim();

  if (!/^\d{6}$/.test(normalizedPincode)) {
    throw new Error("Invalid pickup pincode.");
  }

  const headers = await getHeaders();

  const response = await axios.get(`${BASE_URL}/settings/company/pickup`, {
    headers,
  });

  const locations = response.data?.data?.shipping_address;

  if (!Array.isArray(locations)) {
    throw new Error(
      "Unable to retrieve registered Shiprocket pickup locations.",
    );
  }

  const matches = locations.filter(
    (location) => String(location.pin_code ?? "").trim() === normalizedPincode,
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

  return String(pickupLocation);
};

const createShipment = async ({
  order,
  address,
  warehouse,
  items,
  packageDetails,
}) => {
  const headers = await getHeaders();

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
    throw new Error("Invalid shipment package dimensions or weight");
  }

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Invalid order total amount");
  }

  if (
    !Number.isFinite(deliveryCharge) ||
    deliveryCharge < 0 ||
    deliveryCharge > amount
  ) {
    throw new Error("Invalid delivery charge");
  }

  const isPaid = String(order.payment_status || "").toUpperCase() === "PAID";

  const orderItems = items.map((item) => {
    const qty = Number(item.qty);
    const price = Number(item.price);

    if (!Number.isFinite(qty) || qty <= 0) {
      throw new Error("Invalid order item quantity");
    }

    if (!Number.isFinite(price) || price < 0) {
      throw new Error("Invalid order item price");
    }

    return {
      name: String(item.name),
      sku: String(item.sku),
      units: qty,
      selling_price: price,
    };
  });

  const payload = {
    order_id: String(order.id),
    order_date: new Date().toISOString().slice(0, 10),

    // Must exactly match a pickup location configured in Shiprocket.
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

    // Preserve the order's total instead of adding delivery twice.
    payment_method: isPaid ? "Prepaid" : "COD",
    shipping_charges: deliveryCharge,
    sub_total: amount - deliveryCharge,

    weight,
    length,
    breadth,
    height,
  };

  console.log("SHIPROCKET ORDER REQUEST", {
    ...payload,
    billing_phone: "***",
    billing_email: "***",
  });

  // 1. Create the Shiprocket order.
  const orderResponse = await axios.post(
    `${BASE_URL}/orders/create/adhoc`,
    payload,
    { headers },
  );

  const shipmentId = orderResponse.data.shipment_id;

  if (!shipmentId) {
    return {
      order: orderResponse.data,
      shipment_id: null,
      awb_code: null,
      message:
        "Order created or accepted; shipment ID not returned. Check Shiprocket order details.",
    };
  }

  // 2. Request courier/AWB assignment.
  // This can fail if the shipment is not eligible yet.
  const awbResponse = await axios.post(
    `${BASE_URL}/courier/assign/awb`,
    { shipment_id: shipmentId },
    { headers },
  );

  const awbCode =
    awbResponse.data?.response?.data?.awb_code ||
    awbResponse.data?.awb_code ||
    null;

  return {
    order: orderResponse.data,
    awb: awbResponse.data,
    shipment_id: shipmentId,
    awb_code: awbCode,
  };
};

const trackShipment = async (awb) => {
  if (!awb) {
    throw new Error("AWB number is required for tracking");
  }

  const headers = await getHeaders();

  const response = await axios.get(
    `${BASE_URL}/courier/track/awb/${encodeURIComponent(awb)}`,
    { headers },
  );

  return response.data;
};

module.exports = {
  login,
  createShipment,
  trackShipment,
  getPickupLocationByPincode,
};
