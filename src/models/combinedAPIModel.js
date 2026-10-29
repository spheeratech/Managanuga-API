
const pool = require("../../db");

const getCombinedAPI = async (userId) => {
  const summaryQuery = `
    SELECT *
    FROM public.get_home_summary($1)
  `;

  const productsQuery = `
    SELECT *
    FROM public.get_homescreen_data()
  `;

  const [summaryResult, productsResult] = await Promise.all([
    pool.query(summaryQuery, [userId]),
    pool.query(productsQuery),
  ]);

  const summary = summaryResult.rows[0] || {
    cart_count: 0,
    notification_count: 0,
    membership: null,
  };

  const products = productsResult.rows.map((row) => {
    const value =
      row.get_homescreen_data ?? Object.values(row)[0];

    return typeof value === "string"
      ? JSON.parse(value)
      : value;
  });

  return {
    ...summary,
    products,
  };
};

module.exports = {
  getCombinedAPI,
};
