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
};

module.exports = Wallet;