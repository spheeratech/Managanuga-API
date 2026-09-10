const app = require("./src/app");

const PORT = process.env.PORT || 5001;

console.log("SERVER FILE LOADED");

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

console.log("LISTEN CALLED");
