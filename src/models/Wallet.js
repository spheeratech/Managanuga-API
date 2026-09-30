const pool = require("../../db");

const Wallet = {
  /**
   * ============================================================
   * GET WALLET
   * ============================================================
   */
  async getByUserId(userId) {
    const walletUserId = String(userId || "").trim();

    if (!walletUserId) {
      return null;
    }

    const result = await pool.query(
      `
      SELECT
        w.id,
        w.user_id,
        w.wallet_type,
        w.balance,
        w.created_at,
        w.updated_at
      FROM wallets w
      INNER JOIN user_login ul
        ON ul.user_id = w.user_id
      WHERE
        w.user_id = $1
        AND ul.is_active = 1
        AND ul.role = w.wallet_type
      LIMIT 1
      `,
      [walletUserId]
    );

    return result.rows[0] || null;
  },

  /**
   * ============================================================
   * CREATE REDEEM REQUEST
   * ============================================================
   *
   * Rules:
   *
   * - Vendor / Reseller only
   * - Minimum redeem amount = ₹1,000
   * - Requested amount cannot exceed wallet balance
   * - Wallet row is locked using FOR UPDATE
   * - Only requested amount is deducted
   * - Remaining wallet balance stays available
   * - Entire operation is transactional
   */
  async createRedeemRequest(userId, requestedAmount) {
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      /*
       * Public MGU user_id is used directly.
       */
      const walletUserId =
        String(userId || "").trim();

      if (!walletUserId) {
        throw new Error("User ID is required");
      }

      /*
       * Validate requested amount.
       */
      const redeemAmount = Number(requestedAmount);

      if (!Number.isFinite(redeemAmount)) {
        throw new Error(
          "Redeem amount must be a valid number"
        );
      }

      if (redeemAmount < 1000) {
        throw new Error(
          "Minimum redeem amount is ₹1,000"
        );
      }

      /*
       * We work with 2 decimal places for currency.
       */
      const normalizedRedeemAmount =
        Math.round(redeemAmount * 100) / 100;

      /*
       * Lock wallet row.
       */
      const walletResult = await client.query(
        `
        SELECT
          w.id,
          w.user_id,
          w.wallet_type,
          w.balance
        FROM wallets w
        INNER JOIN user_login ul
          ON ul.user_id = w.user_id
        WHERE
          w.user_id = $1
          AND ul.is_active = 1
          AND ul.role = w.wallet_type
        FOR UPDATE
        `,
        [walletUserId]
      );

      const wallet = walletResult.rows[0];

      if (!wallet) {
        throw new Error("Wallet not found");
      }

      /*
       * Only Vendor and Reseller wallets can redeem.
       */
      if (
        !["VENDOR", "RESELLER"].includes(
          String(wallet.wallet_type).toUpperCase()
        )
      ) {
        throw new Error(
          "Redeem is available only for Vendor or Reseller wallets"
        );
      }

      const walletAmount =
        Math.round(Number(wallet.balance) * 100) / 100;

      /*
       * Minimum wallet balance.
       */
      if (walletAmount < 1000) {
        throw new Error(
          "Minimum wallet balance of ₹1,000 is required for redemption"
        );
      }

      /*
       * Requested amount cannot exceed wallet balance.
       */
      if (normalizedRedeemAmount > walletAmount) {
        throw new Error(
          `Redeem amount cannot exceed your wallet balance of ₹${walletAmount.toFixed(
            2
          )}`
        );
      }

      /*
       * Create redeem request.
       */
      const redeemResult = await client.query(
        `
        INSERT INTO redeem (
          user_id,
          user_type,
          wallet_amount,
          redeem_status,
          redeem_created_date,
          created_by
        )
        VALUES (
          $1,
          $2,
          $3,
          $4,
          NOW(),
          $5
        )
        RETURNING
          id,
          user_id,
          user_type,
          wallet_amount,
          redeem_status,
          redeem_created_date,
          created_by
        `,
        [
          wallet.user_id,
          wallet.wallet_type,
          normalizedRedeemAmount,
          "IN_PROGRESS",
          wallet.user_id,
        ]
      );

      /*
       * Deduct ONLY the requested redeem amount.
       */
      const newBalance =
        Math.round(
          (walletAmount - normalizedRedeemAmount) * 100
        ) / 100;

      await client.query(
        `
        UPDATE wallets
        SET
          balance = $1,
          updated_at = NOW()
        WHERE id = $2
        `,
        [newBalance, wallet.id]
      );

      await client.query("COMMIT");

      return {
        redeem: redeemResult.rows[0],
        walletBalance: newBalance,
      };

    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  },

  /**
   * ============================================================
   * UPDATE REDEEM STATUS
   * ============================================================
   */
  async updateRedeemStatus(redeemId, redeemStatus) {
    const cleanStatus =
      String(redeemStatus || "").trim().toUpperCase();

    if (
  !["IN_PROGRESS", "COMPLETED", "REJECTED"].includes(
    cleanStatus
  )
) {
      throw new Error(
        "Invalid redeem status"
      );
    }

    const result = await pool.query(
      `
      UPDATE redeem
      SET
        redeem_status = $1,
        updated_at = NOW()
      WHERE id = $2
        AND is_active = 1
      RETURNING
        id,
        user_id,
        user_type,
        wallet_amount,
        redeem_status,
        redeem_created_date,
        created_by,
        updated_at
      `,
      [cleanStatus, redeemId]
    );

    if (!result.rows[0]) {
      throw new Error("Redeem request not found");
    }

    return result.rows[0];
  },

  /**
   * ============================================================
   * GET LATEST REDEEM
   * ============================================================
   */
  async getLatestRedeem(userId) {
    const walletUserId =
      String(userId || "").trim();

    const result = await pool.query(
      `
      SELECT
        id,
        user_id,
        user_type,
        wallet_amount,
        redeem_status,
        redeem_created_date,
        created_by
      FROM redeem
      WHERE user_id = $1
      ORDER BY redeem_created_date DESC
      LIMIT 1
      `,
      [walletUserId]
    );

    return result.rows[0] || null;
  },

  /**
   * ============================================================
   * GET REDEEM TRANSACTIONS
   * ============================================================
   */
  async getRedeemTransactions(userId) {
    const walletUserId =
      String(userId || "").trim();

    const result = await pool.query(
      `
      SELECT
        id,
        user_id,
        user_type,
        wallet_amount,
        redeem_status,
        redeem_created_date,
        created_by
      FROM redeem
      WHERE user_id = $1
      ORDER BY redeem_created_date DESC
      `,
      [walletUserId]
    );

    return result.rows;
  },
};

module.exports = Wallet;