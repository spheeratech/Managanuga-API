const express = require("express");
const router = express.Router();
const hubController = require("../controllers/hubController");

// Metadata routes
router.get("/states", hubController.getStates);
router.get("/districts", hubController.getDistricts);
router.get("/cities", hubController.getCities);
router.get("/pincodes", hubController.getPincodes);

// Hub CRUD routes
router.get("/", hubController.getHubs);
// router.get("/:id", hubController.getHubById);
router.post("/", hubController.createHub);
router.put("/:id", hubController.updateHub);
router.delete("/:id", hubController.deleteHub);

module.exports = router;
