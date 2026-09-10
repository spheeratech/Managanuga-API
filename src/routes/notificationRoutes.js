const express = require("express");

const router = express.Router();

const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  createTestNotification,
    sendTestPushNotification,
} = require("../controllers/notificationController");

router.get("/", getNotifications);

router.get("/unread-count", getUnreadCount);

router.put("/read-all", markAllAsRead);

router.put("/:id/read", markAsRead);

// TEST ONLY
router.post("/test", createTestNotification);
router.post("/push-test", sendTestPushNotification);

module.exports = router;