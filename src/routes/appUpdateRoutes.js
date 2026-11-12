
const express = require("express");
const router = express.Router();

const { checkAppUpdate } = require("../controllers/appUpdateController");

router.get("/check", checkAppUpdate);

module.exports = router;
