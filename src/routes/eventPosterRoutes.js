const express = require("express");

const {
  getActiveEventPoster,
  createEventPoster,
} = require("../controllers/eventPosterController");

const router = express.Router();

router.get("/active", getActiveEventPoster);
router.post("/", createEventPoster);

module.exports = router;