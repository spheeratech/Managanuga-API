const express = require("express");
const axios = require("axios");

const router = express.Router();

const GOOGLE_API_KEY = process.env.GOOGLE_PLACES_API_KEY;

// Search locations
router.get("/search", async (req, res) => {
  try {
    const input = String(req.query.input || "").trim();

    if (!input) {
      return res.json([]);
    }

    if (!GOOGLE_API_KEY) {
      return res.status(500).json({
        message: "Google Places API key is not configured on backend.",
      });
    }

    const response = await axios.get(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      {
        params: {
          input,
          components: "country:in",
          key: GOOGLE_API_KEY,
        },
      },
    );

    const data = response.data;

    if (data.status !== "OK" && data.status !== "ZERO_RESULTS") {
      return res.status(400).json({
        message: data.error_message || `Google Places error: ${data.status}`,
      });
    }

    return res.json(data.predictions || []);
  } catch (error) {
    console.error(
      "Google Places search error:",
      error.response?.data || error.message,
    );

    return res.status(500).json({
      message: "Unable to search locations.",
    });
  }
});

// Get selected location details
router.get("/details", async (req, res) => {
  try {
    const placeId = String(req.query.place_id || "").trim();

    if (!placeId) {
      return res.status(400).json({
        message: "place_id is required.",
      });
    }

    if (!GOOGLE_API_KEY) {
      return res.status(500).json({
        message: "Google Places API key is not configured on backend.",
      });
    }

    const response = await axios.get(
      "https://maps.googleapis.com/maps/api/place/details/json",
      {
        params: {
          place_id: placeId,
          fields: "formatted_address,address_components,geometry",
          key: GOOGLE_API_KEY,
        },
      },
    );

    const data = response.data;

    if (data.status !== "OK") {
      return res.status(400).json({
        message: data.error_message || `Google Places error: ${data.status}`,
      });
    }

    return res.json(data.result);
  } catch (error) {
    console.error(
      "Google Place details error:",
      error.response?.data || error.message,
    );

    return res.status(500).json({
      message: "Unable to get location details.",
    });
  }
});

module.exports = router;
