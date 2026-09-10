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
module.exports = {
  getCustomers,
    getOrders,
  getBenefits,
};