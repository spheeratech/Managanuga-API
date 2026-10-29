
const pool = require("../../db");

const getCombinedAPI = async (userId) => {
  const query = `
    SELECT *
    FROM public.get_home_summary($1)
  `;

  const result = await pool.query(query, [userId]);

  return result.rows[0] || {
    cart_count: 0,
    notification_count: 0,
    membership: null,
  };
};

module.exports = {
  getCombinedAPI,
};
