
const express = require("express");
const router = express.Router();

const requireAuthenticatedRole = require("../middleware/requireAuthenticatedRole");

const {
  addAddress,
  getAddresses,
  updateAddress,
  deleteAddress,
  getPincodeDetails,
} = require("../controllers/addressController");

router.post(
  "/",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", true),
  addAddress
);

router.get(
  "/",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", true),
  getAddresses
);

// Pincode lookup does not expose customer data.
router.get("/pincode/:pincode", getPincodeDetails);

router.put(
  "/:id",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", false),
  updateAddress
);

router.delete(
  "/:id",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", false),
  deleteAddress
);

module.exports = router;
