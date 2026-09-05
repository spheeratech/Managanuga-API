const app = require("./src/app");

const PORT = 5001;

console.log("SERVER FILE LOADED");

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
// Add a clean root health check endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    status: "success",
    message: "MG Backend API is fully active and operational!",
    timestamp: new Date()
  });
});
console.log("LISTEN CALLED");
