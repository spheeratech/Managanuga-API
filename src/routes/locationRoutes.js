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

    const response = await axios.post(
      "https://places.googleapis.com/v1/places:autocomplete",
      {
        input,
        includedRegionCodes: ["IN"],
      },
      {
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": GOOGLE_API_KEY,
          "X-Goog-FieldMask":
            "suggestions.placePrediction.placeId," +
            "suggestions.placePrediction.text.text," +
            "suggestions.placePrediction.structuredFormat.mainText.text," +
            "suggestions.placePrediction.structuredFormat.secondaryText.text," +
            "suggestions.placePrediction.types",
        },
      },
    );

    const suggestions = response.data?.suggestions || [];

    const predictions = suggestions
      .filter((item) => item.placePrediction)
      .map(({ placePrediction }) => ({
        place_id: placePrediction.placeId,
        description: placePrediction.text?.text || "",
        structured_formatting: {
          main_text: placePrediction.structuredFormat?.mainText?.text || "",
          secondary_text:
            placePrediction.structuredFormat?.secondaryText?.text || "",
        },
        types: placePrediction.types || [],
      }));

    return res.json(predictions);
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
      `https://places.googleapis.com/v1/places/${encodeURIComponent(placeId)}`,
      {
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": GOOGLE_API_KEY,
          "X-Goog-FieldMask": "id,formattedAddress,addressComponents,location",
        },
      },
    );

    const place = response.data;

    return res.json({
      place_id: place.id || placeId,
      formatted_address: place.formattedAddress || "",
      address_components: (place.addressComponents || []).map((component) => ({
        long_name: component.longText || "",
        short_name: component.shortText || "",
        types: component.types || [],
      })),
      geometry: {
        location: {
          lat: place.location?.latitude ?? null,
          lng: place.location?.longitude ?? null,
        },
      },
    });
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
