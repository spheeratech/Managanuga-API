const app = require("./src/app");

const PORT = process.env.PORT || 5001;

console.log("SERVER FILE LOADED");

// TEMPORARY REQUEST LOGGER
app.use((req, res, next) => {
  console.log("📥 BACKEND REQUEST:", req.method, req.originalUrl);
  console.log("📦 REQUEST BODY:", req.body);
  next();
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

console.log("LISTEN CALLED");