const Wallet = require("../models/Wallet");
const Notification = require("../models/Notification");


/*
 * ============================================================
 * GET WALLET
 * GET /api/wallet/:userId
 * ============================================================
 */
const getWallet = async (req, res) => {
  try {
    const {userId} = req.params;

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
 *
 * Body:
 * {
 *   "userId": "MGV260803",
 *   "amount": 1500
 * }
 * ============================================================
 */
const createRedeemRequest = async (req, res) => {
  try {
    const {userId, amount} = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    if (
      amount === undefined ||
      amount === null ||
      String(amount).trim() === ""
    ) {
      return res.status(400).json({
        success: false,
        message: "Redeem amount is required",
      });
    }

    const result = await Wallet.createRedeemRequest(
      String(userId).trim(),
      amount
    );

    /*
     * ========================================================
     * CREATE IN-APP NOTIFICATION
     * ========================================================
     *
     * Every newly created redeem request starts as
     * IN_PROGRESS.
     */
    try {
      await Notification.createNotification({
        userId: result.redeem.user_id,
        title: "💰 Redemption Request",
        message:
          `Your redemption request of ₹${Number(
            result.redeem.wallet_amount
          ).toFixed(2)} is now in progress.`,
        type: "REDEEM_IN_PROGRESS",
        referenceId: result.redeem.id,
      });

      console.log(
        `REDEEM IN_PROGRESS NOTIFICATION CREATED FOR USER ${result.redeem.user_id}`
      );
    } catch (notificationError) {
      /*
       * Notification failure must NOT break the successful
       * redeem request.
       */
      console.error(
        "REDEEM IN_PROGRESS NOTIFICATION FAILED:",
        notificationError.message
      );
    }

    return res.status(201).json({
      success: true,
      message: "Redeem request created successfully",
      data: result,
    });

  } catch (error) {

    if (
      error.message === "Wallet not found" ||
      error.message ===
        "Redeem is available only for Vendor or Reseller wallets" ||
      error.message.includes("Minimum redeem amount") ||
      error.message.includes("Minimum wallet balance") ||
      error.message.includes("Redeem amount cannot exceed") ||
      error.message.includes("Redeem amount must be a valid number")
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
 * UPDATE REDEEM STATUS
 * PATCH /api/wallet/redeem/:redeemId/status
 *
 * Body:
 * {
 *   "status": "COMPLETED"
 * }
 * ============================================================
 */
const updateRedeemStatus = async (req, res) => {
  try {
    const {redeemId} = req.params;
    const {status} = req.body;

    if (!redeemId) {
      return res.status(400).json({
        success: false,
        message: "Redeem ID is required",
      });
    }

    if (!status) {
      return res.status(400).json({
        success: false,
        message: "Redeem status is required",
      });
    }

    const redeem =
      await Wallet.updateRedeemStatus(
        redeemId,
        status
      );

    /*
     * Only create the completion notification when the
     * status becomes COMPLETED.
     */
    if (
  redeem.redeem_status === "COMPLETED" ||
  redeem.redeem_status === "REJECTED"
) {
  try {
    let title;
    let message;
    let type;

    if (redeem.redeem_status === "COMPLETED") {
      title = "✅ Redemption Completed";
      message =
        `Your redemption of ₹${Number(
          redeem.wallet_amount
        ).toFixed(2)} has been completed successfully.`;
      type = "REDEEM_COMPLETED";
    } else {
      title = "❌ Redemption Rejected";
      message =
        `Your redemption request of ₹${Number(
          redeem.wallet_amount
        ).toFixed(2)} has been rejected.`;
      type = "REDEEM_REJECTED";
    }

    await Notification.createNotification({
      userId: redeem.user_id,
      title,
      message,
      type,
      referenceId: redeem.id,
    });

    console.log(
      `${type} NOTIFICATION CREATED FOR USER ${redeem.user_id}`
    );
  } catch (notificationError) {
    console.error(
      `${redeem.redeem_status} NOTIFICATION FAILED:`,
      notificationError.message
    );
  }
}

    return res.status(200).json({
      success: true,
      message: "Redeem status updated successfully",
      redeem,
    });

  } catch (error) {
    if (
      error.message === "Redeem request not found" ||
      error.message === "Invalid redeem status"
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    console.error(
      "Update Redeem Status Error:",
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
    const {userId} = req.params;

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
  updateRedeemStatus,
  getRedeemStatus,
  getRedeemTransactions,
};