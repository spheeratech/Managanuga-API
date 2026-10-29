
const combinedAPIModel = require("../models/combinedAPIModel");

const getCombinedAPI = async (req, res) => {
  try {
    // userId is optional for guest users.
    const userId = String(req.query.userId ?? "").trim() || null;

    const data = await combinedAPIModel.getCombinedAPI(userId);

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
