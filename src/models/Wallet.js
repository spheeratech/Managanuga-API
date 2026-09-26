const pool = require("../../db");

const Wallet = {
  /**
   * ============================================================
   * RESOLVE WALLET USER
   * ============================================================
   */
  async resolveWalletUserId(identifier) {
    const cleanIdentifier = String(identifier || "").trim();

    if (!cleanIdentifier) {
      return cleanIdentifier;
    }

    // First try public user_id.
    const publicResult = await pool.query(
      `
      SELECT user_id
      FROM user_login
      WHERE user_id = $1
        AND is_active = true
      LIMIT 1
      `,
      [cleanIdentifier]
    );

    if (publicResult.rows.length > 0) {
      return String(publicResult.rows[0].user_id).trim();
    }

    // Backward compatibility for numeric internal ID.
    if (/^\d+$/.test(cleanIdentifier)) {
      const numericResult = await pool.query(
        `
        SELECT user_id
        FROM user_login
        WHERE id = $1
          AND is_active = true
        LIMIT 1
        `,
        [Number(cleanIdentifier)]
      );

      if (numericResult.rows.length > 0) {
        return String(numericResult.rows[0].user_id).trim();
      }
    }

    return cleanIdentifier;
  },

  /**
   * ============================================================
   * GET WALLET
   * ============================================================
   */
  async getByUserId(userId) {
    const walletUserId = await this.resolveWalletUserId(userId);

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
        AND ul.is_active = true
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
       * Resolve public wallet user ID.
       */
      const walletUserId =
        await this.resolveWalletUserId(userId);

      /*
       * Validate requested amount.
       */
      const redeemAmount = Number(requestedAmount);

      if (!Number.isFinite(redeemAmount)) {
        throw new Error("Redeem amount must be a valid number");
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
          AND ul.is_active = true
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
   * GET LATEST REDEEM
   * ============================================================
   */
  async getLatestRedeem(userId) {
    const walletUserId =
      await this.resolveWalletUserId(userId);

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
      await this.resolveWalletUserId(userId);

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