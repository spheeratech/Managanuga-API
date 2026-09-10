const UserDocument = require("../models/UserDocument");

const uploadProfileImage = async (req, res) => {
  try {
    const {userId} = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Profile image is required",
      });
    }

    const document =
      await UserDocument.createOrUpdateProfileImage(
        userId,
        req.file.buffer,
        userId,
        userId
      );

    return res.status(200).json({
      success: true,
      message: "Profile image uploaded successfully",
      data: document,
    });
  } catch (error) {
    console.error(
      "UPLOAD PROFILE IMAGE ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

const getProfileImage = async (req, res) => {
  try {
    const {userId} = req.params;

    const result =
      await UserDocument.getProfileImage(userId);

    if (!result?.profile_image) {
      return res.status(404).json({
        success: false,
        message: "Profile image not found",
      });
    }

    res.set("Content-Type", "image/jpeg");

    return res.send(result.profile_image);
  } catch (error) {
    console.error(
      "GET PROFILE IMAGE ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};
const deleteProfileImage = async (req, res) => {
  try {
    const {userId} = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const document =
      await UserDocument.deleteProfileImage(userId);

    if (!document) {
      return res.status(404).json({
        success: false,
        message: "Profile image not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Profile image deleted successfully",
      data: document,
    });
  } catch (error) {
    console.error(
      "DELETE PROFILE IMAGE ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

module.exports = {
  uploadProfileImage,
  getProfileImage,
    deleteProfileImage,
};