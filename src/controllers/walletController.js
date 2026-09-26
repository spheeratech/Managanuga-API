const Wallet = require("../models/Wallet");


/*
 * ============================================================
 * GET WALLET
 * GET /api/wallet/:userId
 * ============================================================
 */
const getWallet = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const wallet = await Wallet.getByUserId(
      String(userId).trim()
    );

    if (!wallet) {
      return res.status(404).json({
        success: false,
        message: "Wallet not found",
      });
    }

    return res.status(200).json({
      success: true,
      wallet,
    });

  } catch (error) {
    console.error("Get Wallet Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


/*
 * ============================================================
 * CREATE REDEEM REQUEST
 * POST /api/wallet/redeem
 * ============================================================
 */
const createRedeemRequest = async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const result = await Wallet.createRedeemRequest(
      String(userId).trim()
    );

    return res.status(201).json({
      success: true,
      message: "Redeem request created successfully",
      data: result,
    });

  } catch (error) {

    /*
     * Expected business validation errors.
     */
    if (
      error.message === "Wallet not found" ||
      error.message ===
        "Redeem is available only for Vendor or Reseller wallets" ||
      error.message.includes("Minimum wallet balance")
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    console.error(
      "Create Redeem Request Error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


/*
 * ============================================================
 * GET LATEST REDEEM STATUS
 * GET /api/wallet/redeem/:userId
 * ============================================================
 */
const getRedeemStatus = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const redeem = await Wallet.getLatestRedeem(
      String(userId).trim()
    );

    return res.status(200).json({
      success: true,
      redeem: redeem || null,
    });

  } catch (error) {
    console.error(
      "Get Redeem Status Error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


/*
 * ============================================================
 * GET ALL REDEEM TRANSACTIONS
 * GET /api/wallet/redeem/transactions/:userId
 * ============================================================
 */
const getRedeemTransactions = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const transactions =
      await Wallet.getRedeemTransactions(
        String(userId).trim()
      );

    return res.status(200).json({
      success: true,
      transactions,
    });

  } catch (error) {
    console.error(
      "Get Redeem Transactions Error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


module.exports = {
  getWallet,
  createRedeemRequest,
  getRedeemStatus,
  getRedeemTransactions,
};