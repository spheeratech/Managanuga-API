const Vendor = require("../models/Vendor");

const getVendorId = (req) => {
  return String(req.query.vendorId || "").trim();
};

// ======================================================
// GET VENDOR CUSTOMERS
// GET /api/vendor/customers?vendorId=MGV260803
// ======================================================
const getCustomers = async (req, res) => {
  try {
    const vendorId = getVendorId(req);

    if (!vendorId) {
      return res.status(400).json({
        success: false,
        message: "vendorId is required",
      });
    }

    const vendor = await Vendor.getProfile(vendorId);

    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: "Vendor not found",
      });
    }

    const customers = await Vendor.getCustomers(vendorId);

    res.json({
      success: true,
      data: customers,
    });
  } catch (err) {
    console.log("Vendor getCustomers error:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// ======================================================
// GET VENDOR ORDERS
// GET /api/vendor/orders?vendorId=MGV260803
// ======================================================
const getOrders = async (req, res) => {
  try {
    const vendorId = getVendorId(req);

    if (!vendorId) {
      return res.status(400).json({
        success: false,
        message: "vendorId is required",
      });
    }

    const vendor = await Vendor.getProfile(vendorId);

    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: "Vendor not found",
      });
    }

    const orders = await Vendor.getOrders(vendorId);

    res.json({
      success: true,
      data: orders,
    });
  } catch (err) {
    console.log("Vendor getOrders error:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// ======================================================
// GET VENDOR BENEFITS
// GET /api/vendor/benefits?vendorId=MGV260803
// ======================================================
const getBenefits = async (req, res) => {
  try {
    const vendorId = getVendorId(req);

    if (!vendorId) {
      return res.status(400).json({
        success: false,
        message: "vendorId is required",
      });
    }

    const vendor = await Vendor.getProfile(vendorId);

    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: "Vendor not found",
      });
    }

    const benefits = await Vendor.getBenefits(vendorId);

    res.json({
      success: true,
      data: benefits,
    });
  } catch (err) {
    console.log("Vendor getBenefits error:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


// ======================================================
// GET VENDOR PROFILE
// GET /api/vendor/profile?userId=MGV260803
// ======================================================
const getProfile = async (req, res) => {
  try {
    const { userId } = req.query;

    const vendorId = String(userId || "").trim();

    if (!vendorId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const profile = await Vendor.getProfile(vendorId);

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: "Vendor profile not found",
      });
    }

    res.json({
      success: true,
      data: profile,
    });
  } catch (err) {
    console.log("Vendor getProfile error:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


module.exports = {
  getCustomers,
  getOrders,
  getBenefits,
  getProfile,
};