const { getMessaging } = require("firebase-admin/messaging");
require("../config/firebaseAdmin");

const sendPushNotification = async ({
  fcmToken,
  title,
  body,
  data = {},
}) => {
  if (!fcmToken) {
    throw new Error("FCM token is missing");
  }

  const message = {
    token: fcmToken,
    notification: {
      title,
      body,
    },
    data: Object.fromEntries(
      Object.entries(data).map(([key, value]) => [
        key,
        String(value),
      ])
    ),
  };

  const response = await getMessaging().send(message);

  console.log("🔥 FCM notification sent:", response);

  return response;
};

module.exports = {
  sendPushNotification,
};
