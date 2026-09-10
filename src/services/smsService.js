const axios = require("axios");

const sendSMS = async (mobile, message, templateId) => {
  try {
    console.log("========== SMS REQUEST ==========");
    console.log("Mobile:", mobile);
    console.log("Template ID:", templateId);
    console.log("Message:", message);
    console.log("=================================");

    const response = await axios.get(process.env.SMS_BASE_URL, {
      params: {
        username: process.env.SMS_USERNAME,
        apikey: process.env.SMS_API_KEY,
        senderid: process.env.SMS_SENDER_ID,
        mobile,
        message,
        templateid: templateId,
      },
    });

    console.log("========== SMS RESPONSE ==========");
    console.log("Status:", response.status);
    console.log("Data:", response.data);
    console.log("==================================");

    return response.data;

  } catch (error) {
    console.log("========== SMS ERROR ==========");
    console.log("Status:", error.response?.status);
    console.log("Data:", error.response?.data);
    console.log("Message:", error.message);
    console.log("===============================");

    throw new Error("SMS sending failed");
  }
};

module.exports = { sendSMS };