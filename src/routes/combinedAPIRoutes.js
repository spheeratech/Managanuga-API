
const express = require("express");
const router = express.Router();

const {
  getCombinedAPI,
} = require("../controllers/combinedAPIController");

// GET /api/combined?userId=MGU26101701
router.get("/", getCombinedAPI);

module.exports = router;
