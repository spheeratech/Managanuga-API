
const combinedAPIModel = require("../models/combinedAPIModel");

const getCombinedAPI = async (req, res) => {
  try {
    const userId = req.query.userId;

    if (!userId || !String(userId).trim()) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    

    const data = await combinedAPIModel.getCombinedAPI(
      String(userId).trim()
    );

    return res.status(200).json({
      success: true,
      data,
    });
  } catch (error) {
    console.error("Combined API Error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch combined home data",
    });
  }
};

module.exports = {
  getCombinedAPI,
};
