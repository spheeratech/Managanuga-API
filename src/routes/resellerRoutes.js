const express = require("express");
console.log("RESELLER ROUTE LOADED");
const router = express.Router();

const {
  getCustomers,
  getBenefits,
} = require("../controllers/resellerController");

router.get(
  "/customers",
  getCustomers
);

router.get(
  "/benefits",
  getBenefits
);

module.exports = router;
// const express = require("express");

// const router = express.Router();

// console.log("RESELLER ROUTE LOADED");

// router.get("/test", (req, res) => {
//   res.json({
//     message: "Reseller route working"
//   });
// });

// module.exports = router;