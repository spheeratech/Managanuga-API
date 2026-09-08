const EventPoster = require("../models/eventPosterModel");

const getActiveEventPoster = async (req, res) => {
  try {
    const poster = await EventPoster.getActiveEventPoster();

    return res.status(200).json({
      success: true,
      data: poster,
    });
  } catch (error) {
    console.error("Error fetching event poster:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch event poster",
    });
  }
};

const createEventPoster = async (req, res) => {
  try {
    const {image_url, ended_at} = req.body;

    if (!image_url || !ended_at) {
      return res.status(400).json({
        success: false,
        message: "image_url and ended_at are required",
      });
    }

    const poster = await EventPoster.createEventPoster(
      image_url,
      ended_at,
    );

    return res.status(201).json({
      success: true,
      data: poster,
    });
  } catch (error) {
    console.error("Error creating event poster:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create event poster",
    });
  }
};

module.exports = {
  getActiveEventPoster,
  createEventPoster,
};