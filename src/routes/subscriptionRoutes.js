const express = require("express");

const router = express.Router();

const {
  getSubscriptionPlans,
  getMyMembership,
  acceptSubscriptionTerms,
  createSubscriptionOrder,
  verifySubscriptionPayment,
  createSubscriptionPlan,
  toggleSubscriptionPlanStatus,
  deleteSubscriptionPlan,
  assignSubscriptionToCustomer,
  getAdminSubscriptionPlans,
} = require("../controllers/subscriptionController");

router.get("/plans", getSubscriptionPlans);
router.get("/my-membership", getMyMembership);
router.put("/accept-terms", acceptSubscriptionTerms);
router.post("/create-order", createSubscriptionOrder);
router.post("/verify-payment", verifySubscriptionPayment);
router.get("/admin/plans", getAdminSubscriptionPlans);
router.post("/admin/plans", createSubscriptionPlan);
router.patch("/admin/plans/:planId/status", toggleSubscriptionPlanStatus);
router.delete("/admin/plans/:planId", deleteSubscriptionPlan);
router.put(
  "/admin/customer/:userId/subscription",
  assignSubscriptionToCustomer,
);
module.exports = router;
