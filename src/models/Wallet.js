const pool = require("../../db");

const Wallet = {
  async getByUserId(userId) {
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
      [userId]
    );

    return result.rows[0];
  },

  async createRedeemRequest(userId) {
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      const walletResult = await client.query(
        `
        SELECT
          id,
          user_id,
          wallet_type,
          balance
        FROM wallets
        WHERE user_id = $1
          AND wallet_type = 'RESELLER'
        FOR UPDATE
        LIMIT 1
        `,
        [userId]
      );

      const wallet = walletResult.rows[0];

      if (!wallet) {
        throw new Error("Reseller wallet not found");
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
          userId,
          "RESELLER",
          walletAmount,
          "IN_PROGRESS",
          userId,
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
};

module.exports = Wallet;