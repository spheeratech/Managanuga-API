const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");
router.get("/test", (req, res) => {
  console.log("TEST ROUTE HIT");
  res.json({ message: "Backend working" });
});

router.post("/send-otp", authController.sendOtp);
router.post("/verify-otp", authController.verifyOtp);

router.post(
  "/forgot-password/send-otp",
  authController.sendForgotPasswordOtp
);

router.post(
  "/forgot-password/reset",
  authController.resetPasswordWithOtp
);
router.post(
  "/forgot-password/verify-otp",
  authController.verifyForgotPasswordOtp
);
router.post(
  "/change-password",
  authController.changePassword
);

router.post("/login-password", authController.loginWithPassword);
router.post("/fcm-token", authController.updateFcmToken);
router.post("/update-name", authController.updateUsername);
router.post("/delete-account", authController.deleteAccount);
module.exports = router;
