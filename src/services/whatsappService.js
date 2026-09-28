const PINBOT_PHONE_NUMBER_ID =
  process.env.PINBOT_PHONE_NUMBER_ID;

const PINBOT_API_URL =
  `https://partnersv1.pinbot.ai/v3/${PINBOT_PHONE_NUMBER_ID}/messages`;


/* =========================================================
   SEND ORDER CONFIRMATION WHATSAPP
========================================================= */

const sendOrderConfirmation = async ({
  mobile,
  customerName,
  orderId,
  amount,
  orderSummary,
}) => {
  if (!process.env.PINBOT_API_KEY) {
    throw new Error("PINBOT_API_KEY is not configured");
  }

  /* --------------------------------
     NORMALIZE PHONE NUMBER
  -------------------------------- */

  let phone = String(mobile).replace(/\D/g, "");

  // Indian 10 digit number
  if (phone.length === 10) {
    phone = `91${phone}`;
  }


  /* --------------------------------
     WHATSAPP TEMPLATE PAYLOAD
  -------------------------------- */

  const payload = {
    messaging_product: "whatsapp",

    recipient_type: "individual",

    to: phone,

    type: "template",

    template: {
      name: "order_placed",

      language: {
        code:
          process.env.PINBOT_TEMPLATE_LANGUAGE ||
          "en",
      },

      components: [
        {
          type: "body",

          parameters: [
            {
              type: "text",
              text: String(customerName),
            },

            {
              type: "text",
              text: String(orderId),
            },

            {
              type: "text",
              text: String(amount),
            },

            {
              type: "text",
              text: String(orderSummary),
            },
          ],
        },
      ],
    },
  };


  /* --------------------------------
     SEND REQUEST
  -------------------------------- */

  const response = await fetch(
    PINBOT_API_URL,
    {
      method: "POST",

      headers: {
        apikey: process.env.PINBOT_API_KEY,
        "Content-Type": "application/json",
      },

      body: JSON.stringify(payload),
    }
  );


  /* --------------------------------
     READ RESPONSE
  -------------------------------- */

  const responseText =
    await response.text();

  let data;

  try {
    data = JSON.parse(responseText);
  } catch {
    data = {
      raw: responseText,
    };
  }


  /* --------------------------------
     HANDLE ERROR
  -------------------------------- */

  if (!response.ok) {
    console.error(
      "PINBOT WHATSAPP ERROR:",
      response.status,
      data
    );

    throw new Error(
      data?.message ||
        data?.error ||
        `WhatsApp API failed (${response.status})`
    );
  }


  /* --------------------------------
     SUCCESS
  -------------------------------- */

  console.log(
    "WHATSAPP ORDER Placed SENT:",
    data
  );

  return data;
};

/* =========================================================
   SEND SUBSCRIPTION WHATSAPP
========================================================= */

const sendSubscriptionWhatsApp = async ({
  mobile,
  customerName,
  planName,
  walletAmount,
  validity,
}) => {
  if (!process.env.PINBOT_API_KEY) {
    throw new Error("PINBOT_API_KEY is not configured");
  }

  /* --------------------------------
     NORMALIZE PHONE NUMBER
  -------------------------------- */

  let phone = String(mobile).replace(/\D/g, "");

  // Indian 10 digit number
  if (phone.length === 10) {
    phone = `91${phone}`;
  }

  /* --------------------------------
     WHATSAPP TEMPLATE PAYLOAD
  -------------------------------- */

  const payload = {
    messaging_product: "whatsapp",

    recipient_type: "individual",

    to: phone,

    type: "template",

    template: {
      name: "subscription",

      language: {
        code:
          process.env.PINBOT_TEMPLATE_LANGUAGE ||
          "en",
      },

      components: [
        {
          type: "body",

          parameters: [
            {
              type: "text",
              text: String(customerName),
            },

            {
              type: "text",
              text: String(planName),
            },

            {
              type: "text",
              text: String(walletAmount),
            },

            {
              type: "text",
              text: String(validity),
            },
          ],
        },
      ],
    },
  };

  /* --------------------------------
     SEND REQUEST
  -------------------------------- */

  const response = await fetch(
    PINBOT_API_URL,
    {
      method: "POST",

      headers: {
        apikey: process.env.PINBOT_API_KEY,
        "Content-Type": "application/json",
      },

      body: JSON.stringify(payload),
    }
  );

  /* --------------------------------
     READ RESPONSE
  -------------------------------- */

  const responseText =
    await response.text();

  let data;

  try {
    data = JSON.parse(responseText);
  } catch {
    data = {
      raw: responseText,
    };
  }

  /* --------------------------------
     HANDLE ERROR
  -------------------------------- */

  if (!response.ok) {
    console.error(
      "PINBOT SUBSCRIPTION WHATSAPP ERROR:",
      response.status,
      data
    );

    throw new Error(
      data?.message ||
        data?.error ||
        `WhatsApp API failed (${response.status})`
    );
  }

  /* --------------------------------
     SUCCESS
  -------------------------------- */

  console.log(
    "WHATSAPP SUBSCRIPTION SENT:",
    data
  );

  return data;
};
/* =========================================================
   SEND USER REGISTRATION WHATSAPP
========================================================= */

const sendUserRegistrationWhatsApp = async ({
  mobile,
  password,
}) => {
  if (!process.env.PINBOT_API_KEY) {
    throw new Error("PINBOT_API_KEY is not configured");
  }

  /* --------------------------------
     NORMALIZE PHONE NUMBER
  -------------------------------- */

  let phone = String(mobile).replace(/\D/g, "");

  // Indian 10 digit number
  if (phone.length === 10) {
    phone = `91${phone}`;
  }

  /* --------------------------------
     WHATSAPP TEMPLATE PAYLOAD
  -------------------------------- */

  const payload = {
    messaging_product: "whatsapp",

    recipient_type: "individual",

    to: phone,

    type: "template",

    template: {
      name: "User-register",

      language: {
        code:
          process.env.PINBOT_TEMPLATE_LANGUAGE ||
          "en",
      },

      components: [
        {
          type: "body",

          parameters: [
            {
              type: "text",
              text: String(mobile),
            },

            {
              type: "text",
              text: String(password),
            },
          ],
        },
      ],
    },
  };

  /* --------------------------------
     SEND REQUEST
  -------------------------------- */

  const response = await fetch(
    PINBOT_API_URL,
    {
      method: "POST",

      headers: {
        apikey: process.env.PINBOT_API_KEY,
        "Content-Type": "application/json",
      },

      body: JSON.stringify(payload),
    }
  );

  /* --------------------------------
     READ RESPONSE
  -------------------------------- */

  const responseText =
    await response.text();

  let data;

  try {
    data = JSON.parse(responseText);
  } catch {
    data = {
      raw: responseText,
    };
  }

  /* --------------------------------
     HANDLE ERROR
  -------------------------------- */

  if (!response.ok) {
    console.error(
      "PINBOT USER REGISTRATION WHATSAPP ERROR:",
      response.status,
      data
    );

    throw new Error(
      data?.message ||
        data?.error ||
        `WhatsApp API failed (${response.status})`
    );
  }

  /* --------------------------------
     SUCCESS
  -------------------------------- */

  console.log(
    "WHATSAPP USER REGISTRATION SENT:",
    data
  );

  return data;
};

module.exports = {
  sendOrderConfirmation,
  sendSubscriptionWhatsApp,
  sendUserRegistrationWhatsApp
};