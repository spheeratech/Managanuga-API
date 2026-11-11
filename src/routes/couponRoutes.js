
const express = require("express");
const requireAuthenticatedRole = require("../middleware/requireAuthenticatedRole");
const router = express.Router();

const {
  validateCoupon,
  getAvailableCoupons,
} = require("../controllers/couponController");

router.get(
  "/available",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id"),
  getAvailableCoupons
);

router.post(
  "/validate",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id"),
  validateCoupon
);

module.exports = router;
