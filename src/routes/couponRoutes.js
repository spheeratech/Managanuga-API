
const express = require("express");
const requireAuthenticatedRole = require("../middleware/requireAuthenticatedRole");
const router = express.Router();

const {
  validateCoupon,
} = require("../controllers/couponController");

router.post(
  "/validate",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id"),
  validateCoupon
);

module.exports = router;
