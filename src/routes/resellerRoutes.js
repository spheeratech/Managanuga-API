const express = require("express");

console.log("RESELLER ROUTE LOADED");

const router = express.Router();

const {
  getCustomers,
  getOrders,
  getBenefits,
  getProfile,
} = require("../controllers/resellerController");


router.get("/customers", getCustomers);

router.get("/orders", getOrders);

router.get("/benefits", getBenefits);

router.get("/profile", getProfile);


module.exports = router;