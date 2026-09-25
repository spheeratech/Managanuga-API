const express = require("express");

console.log("RESELLER ROUTE LOADED");

const router = express.Router();

const {
  getCustomers,
  getBenefits,
  getProfile,
} = require("../controllers/resellerController");


/*
 * ============================================================
 * RESELLER CUSTOMERS
 * ============================================================
 */
router.get("/customers", getCustomers);


/*
 * ============================================================
 * RESELLER BENEFITS
 * ============================================================
 */
router.get("/benefits", getBenefits);


/*
 * ============================================================
 * RESELLER PROFILE
 * ============================================================
 */
router.get("/profile", getProfile);


module.exports = router;