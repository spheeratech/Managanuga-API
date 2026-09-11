const express = require("express");
const router = express.Router();

const {
  getAppImages,
} = require("../controllers/appImageController");

router.get("/", getAppImages);

module.exports = router;
