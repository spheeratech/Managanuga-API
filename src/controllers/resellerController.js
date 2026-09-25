const Reseller = require("../models/Reseller");


/*
 * ============================================================
 * GET RESELLER CUSTOMERS
 * ============================================================
 */
const getCustomers = async (req, res) => {
  try {
    const { resellerId } = req.query;

    if (!resellerId) {
      return res.status(400).json({
        success: false,
        message: "resellerId is required",
      });
    }

    const customers = await Reseller.getCustomers(
      String(resellerId).trim()
    );

    return res.status(200).json({
      success: true,
      count: customers.length,
      data: customers,
    });

  } catch (err) {
    console.error("GET RESELLER CUSTOMERS ERROR:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


/*
 * ============================================================
 * GET RESELLER BENEFITS
 * ============================================================
 */
const getBenefits = async (req, res) => {
  try {
    const { resellerId } = req.query;

    if (!resellerId) {
      return res.status(400).json({
        success: false,
        message: "resellerId is required",
      });
    }

    const benefits = await Reseller.getBenefits(
      String(resellerId).trim()
    );

    return res.status(200).json({
      success: true,
      count: benefits.length,
      data: benefits,
    });

  } catch (err) {
    console.error("GET RESELLER BENEFITS ERROR:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


/*
 * ============================================================
 * GET RESELLER PROFILE
 * ============================================================
 */
const getProfile = async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const profile = await Reseller.getProfile(
      String(userId).trim()
    );

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: "Reseller profile not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: profile,
    });

  } catch (err) {
    console.error("GET RESELLER PROFILE ERROR:", err);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};


module.exports = {
  getCustomers,
  getBenefits,
  getProfile,
};