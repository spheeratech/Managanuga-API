const express = require("express");
const requireAuthenticatedRole = require("../middleware/requireAuthenticatedRole");

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
router.get(
  "/benefits",
  requireAuthenticatedRole("RESELLER", "resellerId"),
  getBenefits
);


/*
 * ============================================================
 * RESELLER PROFILE
 * ============================================================
 */
router.get("/profile", getProfile);


module.exports = router;