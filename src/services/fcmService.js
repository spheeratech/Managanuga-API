const { getMessaging } = require("firebase-admin/messaging");
const firebaseApp = require("../config/firebaseAdmin");

const sendPushNotification = async ({ fcmToken, title, body, data = {} }) => {
  if (!fcmToken) {
    throw new Error("FCM token is missing");
  }

  if (!firebaseApp) {
    throw new Error(
      "Firebase Admin is not configured. Configure FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY.",
    );
  }

  const message = {
    token: fcmToken,
    notification: {
      title,
      body,
    },
    data: Object.fromEntries(
      Object.entries(data).map(([key, value]) => [key, String(value)]),
    ),
  };

  const response = await getMessaging(firebaseApp).send(message);

  console.log("🔥 FCM notification sent:", response);

  return response;
};

module.exports = {
  sendPushNotification,
};
