const Hub = require("../models/Hub");

const getStates = async (req, res) => {
  try {
    const data = await Hub.getStates();
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getDistricts = async (req, res) => {
  try {
    const { state_id } = req.query;
    const data = await Hub.getDistrictsByState(state_id || "");
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getCities = async (req, res) => {
  try {
    const state_id = String(req.query.state_id || "").trim();
    const dist_id = String(req.query.dist_id || "").trim();

    console.log("GET CITIES");
    console.log("State ID:", state_id);
    console.log("District ID:", dist_id);

    if (!state_id || !dist_id) {
      return res.json({ success: true, data: [] });
    }

    // IMPORTANT: state_id first, dist_id second
    const data = await Hub.getCitiesByDistrict(state_id, dist_id);

    console.log("Cities returned:", data.length);

    return res.json({ success: true, data });
  } catch (error) {
    console.error("GET CITIES ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch cities",
    });
  }
};

const getPincodes = async (req, res) => {
  try {
    const { state_id, dist_id, city_id } = req.query;
    const data = await Hub.getPincodesByCity(
      state_id || "",
      dist_id || "",
      city_id || "",
    );
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// const getHubs = async (req, res) => {
//   try {
//     const data = await Hub.getHubs();
//     res.json({ success: true, data });
//   } catch (error) {
//     res.status(500).json({ success: false, message: error.message });
//   }
// };
const getHubs = async (req, res) => {
  try {
    const data = await Hub.getHubs();
    // Always return an explicit object containing the array under 'data'
    return res.status(200).json({ success: true, data });
  } catch (error) {
    console.error("GET HUBS CONTROLLER ERROR:", error.message);
    return res.status(500).json({ success: false, message: error.message });
  }
};
const getHubById = async (req, res) => {
  try {
    const data = await Hub.getHubById(req.params.id);
    if (!data)
      return res.status(404).json({ success: false, message: "Hub not found" });
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const createHub = async (req, res) => {
  try {
    const data = await Hub.createHub(req.body);
    res
      .status(201)
      .json({ success: true, message: "Hub created successfully", data });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

const updateHub = async (req, res) => {
  try {
    const data = await Hub.updateHub(req.params.id, req.body);
    if (!data)
      return res.status(404).json({ success: false, message: "Hub not found" });
    res.json({ success: true, message: "Hub updated successfully", data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const deleteHub = async (req, res) => {
  try {
    const data = await Hub.deleteHub(req.params.id);
    if (!data)
      return res.status(404).json({ success: false, message: "Hub not found" });
    res.json({ success: true, message: "Hub deleted successfully", data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getStates,
  getDistricts,
  getCities,
  getPincodes,
  getHubs,
  getHubById,
  createHub,
  updateHub,
  deleteHub,
};
