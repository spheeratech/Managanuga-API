const express = require("express");

const {
  getActiveEventPoster,
  createEventPoster,
  getAllEventPosters,
  updateEventPoster,
  deleteEventPoster,
} = require("../controllers/eventPosterController");

const { upload } = require("../middleware/eventPosterUpload");
const router = express.Router();
router.get("/active", getActiveEventPoster);
router.post("/", upload.single("image"), createEventPoster);
router.get("/", getAllEventPosters);
router.put("/:id", upload.single("image"), updateEventPoster);
router.delete("/:id", deleteEventPoster);

module.exports = router;
