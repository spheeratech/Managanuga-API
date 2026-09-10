const axios = require("axios");

const BASE_URL = "https://shipment.xpressbees.com/api";

let token = null;
let tokenExpiry = null;

const login = async () => {
  if (token && tokenExpiry && Date.now() < tokenExpiry) {
    return token;
  }

  const response = await axios.post(
    `${BASE_URL}/users/login`,
    {
      email: process.env.XPRESSBEES_EMAIL,
      password: process.env.XPRESSBEES_PASSWORD,
    },
    {
      headers: {
        "Content-Type": "application/json",
      },
    }
  );

  if (!response.data.status) {
    throw new Error("Xpressbees login failed");
  }

  token = response.data.data;

  // Token cache for 2 hours
  tokenExpiry = Date.now() + 2 * 60 * 60 * 1000;

  console.log("✅ XPRESSBEES LOGIN SUCCESS");

  return token;
};
const createShipment = async ({ order, address, warehouse }) => {
  const jwt = await login();

  const payload = {
    order_number: String(order.id),
    payment_type: "prepaid",
    order_amount: Number(order.total_amount),
    collectable_amount: 0,

    consignee: {
      name: address.full_name,
      address: address.address_line1,
      address_2: address.address_line2 || "",
      city: address.city,
      state: address.state,
      pincode: address.postal_code,
      phone: address.phone,
    },

    pickup: {
      warehouse_name: warehouse.name,
      name: warehouse.contact_name,
      address: warehouse.address,
      address_2: "",
      city: warehouse.city,
      state: warehouse.state,
      pincode: warehouse.pincode,
      phone: warehouse.phone,
    },

    order_items: [
      {
        name: "Order #" + order.id,
        qty: 1,
        price: Number(order.total_amount),
        sku: "ORDER-" + order.id,
      },
    ],
  };

  console.log("========== XPRESSBEES REQUEST ==========");
  console.log(JSON.stringify(payload, null, 2));

  const response = await axios.post(
    `${BASE_URL}/shipments2`,
    payload,
    {
      headers: {
        Authorization: `Bearer ${jwt}`,
        "Content-Type": "application/json",
      },
    }
  );

  console.log("========== XPRESSBEES RESPONSE ==========");
  console.log(JSON.stringify(response.data, null, 2));

  return response.data;
};
const trackShipment = async (awb) => {
  const token = await login();

  const response = await axios.get(
    `${BASE_URL}/shipments2/track/${awb}`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
    }
  );

  return response.data;
};
module.exports = {
  login,
  createShipment,
  trackShipment,
};

