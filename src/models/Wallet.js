const pool = require("../../db");

const Wallet = {
  async resolveWalletUserId(identifier) {
  const result = await pool.query(
    `
    SELECT ui.user_id
    FROM user_login ul
    INNER JOIN user_info ui
      ON TRIM(ui.mobile) = TRIM(ul.mobile_no)
    WHERE (
      ul.user_id = $1
      OR ul.id::text = $1
    )
    AND ul.is_active = true
    LIMIT 1
    `,
    [String(identifier).trim()]
  );

  if (result.rows.length > 0 && result.rows[0].user_id) {
    return String(result.rows[0].user_id).trim();
  }

  return String(identifier).trim();
},

  async getByUserId(userId) {
    const walletUserId = await this.resolveWalletUserId(userId);

    const result = await pool.query(
      `
      SELECT
        id,
        user_id,
        wallet_type,
        balance,
        created_at,
        updated_at
      FROM wallets
      WHERE user_id = $1
      LIMIT 1
      `,
      [walletUserId]
    );

    return result.rows[0];
  },

  async createRedeemRequest(userId) {
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      const walletUserId = await this.resolveWalletUserId(userId);

      const walletResult = await client.query(
        `
        SELECT
          id,
          user_id,
          wallet_type,
          balance
        FROM wallets
        WHERE user_id = $1
        FOR UPDATE
        `,
        [walletUserId]
      );

      const wallet = walletResult.rows[0];

      if (!wallet) {
        throw new Error("Wallet not found");
      }

      if (!["VENDOR", "RESELLER"].includes(wallet.wallet_type)) {
        throw new Error(
          "Redeem is available only for Vendor or Reseller wallets"
        );
      }

      const walletAmount = Number(wallet.balance);

      if (walletAmount < 1000) {
        throw new Error(
          "Minimum wallet balance of ₹1,000 is required for redemption"
        );
      }

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
        VALUES ($1, $2, $3, $4, NOW(), $5)
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
          walletAmount,
          "IN_PROGRESS",
          String(userId).trim(),
        ]
      );

      await client.query(
        `
        UPDATE wallets
        SET
          balance = 0,
          updated_at = NOW()
        WHERE id = $1
        `,
        [wallet.id]
      );

      await client.query("COMMIT");

      return {
        redeem: redeemResult.rows[0],
        walletBalance: 0,
      };
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  },

  async getLatestRedeem(userId) {
    const walletUserId = await this.resolveWalletUserId(userId);

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

  async getRedeemTransactions(userId) {
    const walletUserId = await this.resolveWalletUserId(userId);

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