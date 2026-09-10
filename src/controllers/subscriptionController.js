const Subscription = require("../models/Subscription");
const Membership = require("../models/Membership");

const getSubscriptionPlans = async (req, res) => {
  try {
    const plans = await Subscription.getPlans();

    res.status(200).json({
      success: true,
      plans,
    });
  } catch (error) {
    console.error("Subscription Plans Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch subscription plans",
    });
  }
};

const getMyMembership = async (req, res) => {
  try {
    const { userId } = req.query;

    const membership =
      await Membership.getActiveMembership(userId);

    res.status(200).json({
      success: true,
      membership,
    });
  } catch (error) {
    console.error("Get Membership Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const acceptSubscriptionTerms = async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const membership =
      await Membership.acceptTerms(userId);

    res.status(200).json({
      success: true,
      message: "Subscription terms accepted",
      membership,
    });
  } catch (error) {
    console.error("Accept Subscription Terms Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getSubscriptionPlans,
  getMyMembership,
  acceptSubscriptionTerms,
};