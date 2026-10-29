
const pool = require("../../db");

const getCombinedAPI = async (userId = null) => {
  // Public Home Screen data: always fetch products.
  const productsQuery = `
    SELECT *
    FROM public.get_homescreen_data()
  `;

  const productsResult = await pool.query(productsQuery);

  const products = productsResult.rows.map((row) => {
    const value =
      row.get_homescreen_data ?? Object.values(row)[0];

    return typeof value === "string"
      ? JSON.parse(value)
      : value;
  });

  // Default personal data for guests.
  let summary = {
    cart_count: 0,
    notification_count: 0,
    membership: null,
  };

  // Fetch personal summary only when a user ID is provided.
  if (userId) {
    const summaryQuery = `
      SELECT *
      FROM public.get_home_summary($1)
    `;

    const summaryResult = await pool.query(summaryQuery, [userId]);

    summary = summaryResult.rows[0] ?? summary;
  }

  // Support app_images returned inside product JSON by the current function.
  const appImages =
    products.find((product) => Array.isArray(product?.app_images))
      ?.app_images ?? [];

  return {
    ...summary,
    app_images: appImages,
    products,
  };
};

module.exports = {
  getCombinedAPI,
};
