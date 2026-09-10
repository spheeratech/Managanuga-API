const pool = require("./db");

async function testConnection() {
  try {
    const result = await pool.query("SELECT current_database()");

    console.log(result.rows);
  } catch (error) {
    console.error(error);
  }
}

testConnection();
