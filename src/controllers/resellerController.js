const Reseller = require("../models/Reseller");

const getCustomers = async (req, res) => {
  try {

    // Temporary reseller ID
    // Later this will come from JWT
    const resellerId = "001";

    const customers = await Reseller.getCustomers(resellerId);

    res.json(customers);

  } catch (err) {

    console.log(err);

    res.status(500).json({
      message: err.message,
    });

  }
};
const getBenefits = async (req, res) => {
  try {

    // Temporary reseller ID
    // Later this will come from JWT
    const resellerId = "001";

    const benefits = await Reseller.getBenefits(resellerId);

    res.status(200).json({
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
  getBenefits,
};