const EventPoster = require("../models/eventPosterModel");
const fs = require("fs");
const path = require("path");
const { uploadDir } = require("../middleware/eventPosterUpload");
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

// const createEventPoster = async (req, res) => {
//   try {
//     const {image_url, ended_at} = req.body;

//     if (!image_url || !ended_at) {
//       return res.status(400).json({
//         success: false,
//         message: "image_url and ended_at are required",
//       });
//     }

//     const poster = await EventPoster.createEventPoster(
//       image_url,
//       ended_at,
//     );

//     return res.status(201).json({
//       success: true,
//       data: poster,
//     });
//   } catch (error) {
//     console.error("Error creating event poster:", error);

//     return res.status(500).json({
//       success: false,
//       message: "Failed to create event poster",
//     });
//   }
// };
const createEventPoster = async (req, res) => {
  try {
    const {
      image_url,
      ended_at,
      event_name,
      event_description,
      is_active,
      created_by,
    } = req.body;

    // Support both the existing image_url and new uploaded image.
    const imageUrl = req.file
      ? `https://managanuga.in/images/${req.file.filename}`
      : image_url;
    if (!imageUrl || !ended_at) {
      return res.status(400).json({
        success: false,
        message: "image_url and ended_at are required",
      });
    }

    const isActive = ["1", "true"].includes(
      String(is_active ?? "1").toLowerCase(),
    )
      ? 1
      : 0;

    const poster = await EventPoster.createEventPoster(
      imageUrl,
      ended_at,
      event_name || null,
      event_description || null,
      isActive,
      created_by || null,
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
const getAllEventPosters = async (req, res) => {
  try {
    const posters = await EventPoster.getAllEventPosters();

    return res.status(200).json({
      success: true,
      data: posters,
    });
  } catch (error) {
    console.error("Error fetching all event posters:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch event posters",
    });
  }
};

const updateEventPoster = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      event_name,
      event_description,
      ended_at,
      is_active,
      updated_by,
      image_url,
    } = req.body;

    if (!event_name?.trim() || !event_description?.trim() || !ended_at) {
      return res.status(400).json({
        success: false,
        message: "Event name, description and end date are required",
      });
    }

    const isActive = ["1", "true"].includes(String(is_active).toLowerCase())
      ? 1
      : 0;

    const imageUrl = req.file
      ? `https://managanuga.in/images/${req.file.filename}`
      : image_url || null;

    const poster = await EventPoster.updateEventPoster(
      id,
      event_name.trim(),
      event_description.trim(),
      imageUrl,
      ended_at,
      isActive,
      updated_by || null,
    );

    if (!poster) {
      return res.status(404).json({
        success: false,
        message: "Event poster not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: poster,
    });
  } catch (error) {
    console.error("Error updating event poster:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update event poster",
    });
  }
};

const deleteEventPoster = async (req, res) => {
  try {
    // Delete the database record and retrieve its image URL.
    const poster = await EventPoster.deleteEventPoster(req.params.id);

    if (!poster) {
      return res.status(404).json({
        success: false,
        message: "Event poster not found",
      });
    }

    let imageDeleted = false;

    if (poster.image_url) {
      try {
        // Extract the filename from the stored image URL.
        const imagePath = new URL(poster.image_url, "https://managanuga.in")
          .pathname;

        // Only allow images from the /images/ directory.
        if (imagePath.startsWith("/images/")) {
          const filename = path.basename(imagePath);
          const filePath = path.resolve(uploadDir, filename);

          // Ensure the resolved path stays inside uploadDir.
          if (path.dirname(filePath) !== path.resolve(uploadDir)) {
            throw new Error("Invalid image file path");
          }

          await fs.promises.unlink(filePath);
          imageDeleted = true;

          console.log("Event poster image deleted:", filePath);
        }
      } catch (fileError) {
        if (fileError.code === "ENOENT") {
          console.log("Event poster image already missing:", poster.image_url);
        } else {
          console.error("Error deleting event poster image:", fileError);
        }
      }
    }

    return res.status(200).json({
      success: true,
      message: "Event poster deleted successfully",
      data: {
        ...poster,
        image_deleted: imageDeleted,
      },
    });
  } catch (error) {
    console.error("Error deleting event poster:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to delete event poster",
    });
  }
};
module.exports = {
  getActiveEventPoster,
  createEventPoster,
  getAllEventPosters,
  updateEventPoster,
  deleteEventPoster,
};
