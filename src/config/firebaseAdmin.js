const {
  initializeApp,
  getApps,
  cert,
} = require("firebase-admin/app");

const path = require("path");
const fs = require("fs");

let firebaseApp;

if (getApps().length > 0) {
  firebaseApp = getApps()[0];
} else {
  const localServiceAccountPath = path.join(
    __dirname,
    "../../managanuga-2026-firebase-adminsdk-fbsvc-f104f22e18.json"
  );

  if (fs.existsSync(localServiceAccountPath)) {
    // Local development
    const serviceAccount = require(localServiceAccountPath);

    firebaseApp = initializeApp({
      credential: cert(serviceAccount),
    });

    console.log("🔥 Firebase Admin initialized using local service account");
  } else {
    // Railway / production
    if (
      !process.env.FIREBASE_PROJECT_ID ||
      !process.env.FIREBASE_CLIENT_EMAIL ||
      !process.env.FIREBASE_PRIVATE_KEY
    ) {
      throw new Error(
        "Firebase credentials are missing. Configure FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY."
      );
    }

    firebaseApp = initializeApp({
      credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
      }),
    });

    console.log("🔥 Firebase Admin initialized using environment variables");
  }
}

module.exports = firebaseApp;
