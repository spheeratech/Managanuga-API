const express = require("express");
const router = express.Router();

const {
  addAddress,
  getAddresses,
  updateAddress,
  deleteAddress,
   getPincodeDetails, 
} = require("../controllers/addressController");

router.post("/", addAddress);
router.get("/", getAddresses);
router.get(
  "/pincode/:pincode",
  getPincodeDetails
);
router.put("/:id", updateAddress);
router.delete("/:id", deleteAddress);

module.exports = router;
