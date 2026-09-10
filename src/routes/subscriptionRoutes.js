const express = require("express");

const router = express.Router();

const {
  getSubscriptionPlans,
  getMyMembership,
  acceptSubscriptionTerms,
} = require("../controllers/subscriptionController");

router.get("/plans", getSubscriptionPlans);

router.get("/my-membership", getMyMembership);

router.put("/accept-terms", acceptSubscriptionTerms);

module.exports = router;