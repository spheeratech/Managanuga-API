const Vendor = require("../models/Vendor");

const getCustomers = async (req, res) => {

  try {

    // Temporary Vendor ID
    // Later this will come from JWT token
    const vendorId = "100";

    const customers =
      await Vendor.getCustomers(vendorId);

    res.json(customers);

  } catch (err) {

    console.log(err);

    res.status(500).json({
      message: err.message,
    });

  }

};
const getOrders = async (req, res) => {

  try {

    // Temporary vendor ID
    // Later this will come from JWT
    const vendorId = "100";

    const orders = await Vendor.getOrders(vendorId);

    res.json(orders);

  } catch (err) {

    console.log(err);

    res.status(500).json({
      message: err.message,
    });

  }

};
const getBenefits = async (req, res) => {

  try {

    // Temporary vendor ID
    // Later this will come from JWT
    const vendorId = "MGV260803";

    const benefits = await Vendor.getBenefits(vendorId);

    res.json({
      success: true,
      data: benefits,
    });

  } catch (err) {

    console.log(err);

    res.status(500).json({
      success: false,
      message: err.message,
    });

  }

};
const getProfile = async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const profile = await Vendor.getProfile(userId);

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
    console.log(err);

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