const Wallet = require("../models/Wallet");

const getWallet = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const wallet = await Wallet.getByUserId(userId);

    if (!wallet) {
      return res.status(404).json({
        success: false,
        message: "Wallet not found",
      });
    }

    res.status(200).json({
      success: true,
      wallet,
    });

  } catch (error) {
    console.error("Get Wallet Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const createRedeemRequest = async (req, res) => {
  try {
    const {userId} = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const result = await Wallet.createRedeemRequest(
      String(userId).trim()
    );

    res.status(201).json({
      success: true,
      message: "Redeem request created successfully",
      data: result,
    });
  } catch (error) {
    if (
      error.message === "Reseller wallet not found" ||
      error.message.includes("Minimum wallet balance")
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    console.error("Create Redeem Request Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getRedeemStatus = async (req, res) => {
  try {
    const {userId} = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const redeem = await Wallet.getLatestRedeem(
      String(userId).trim()
    );

    if (!redeem) {
      return res.status(200).json({
        success: true,
        redeem: null,
      });
    }

    res.status(200).json({
      success: true,
      redeem,
    });
  } catch (error) {
    console.error("Get Redeem Status Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getRedeemTransactions = async (req, res) => {
  try {
    const {userId} = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const transactions = await Wallet.getRedeemTransactions(
      String(userId).trim()
    );

    res.status(200).json({
      success: true,
      transactions,
    });
  } catch (error) {
    console.error("Get Redeem Transactions Error:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getWallet,
  createRedeemRequest,
  getRedeemStatus,
  getRedeemTransactions
};