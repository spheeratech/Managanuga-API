const AppImage = require("../models/AppImage");

const getAppImages = async (req, res) => {
  try {
    const images = await AppImage.getAppImages();

    res.json({
      success: true,
      data: images,
    });
  } catch (error) {
    console.error("Error fetching app images:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch app images",
    });
  }
};

module.exports = {
  getAppImages,
};
