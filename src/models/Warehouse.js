const pool = require("../../db");

const getWarehouses = async () => {
  const result = await pool.query("SELECT * FROM warehouses");
  return result.rows;
};

const getWarehouseById = async (id) => {
  const result = await pool.query("SELECT * FROM warehouses WHERE id = $1", [
    id,
  ]);

  return result.rows[0];
};

module.exports = {
  getWarehouses,
  getWarehouseById,
};
