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
    const districtName = req.query.district_name || req.query.district_id || "";
    const data = await Hub.getCitiesByDistrict(districtName);
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getPincodes = async (req, res) => {
  try {
    const { city_id } = req.query;
    const data = await Hub.getPincodesByCity(city_id || "");
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getHubs = async (req, res) => {
  try {
    const data = await Hub.getHubs();
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
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
