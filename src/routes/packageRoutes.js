const express = require("express");
const router = express.Router();

const requireAuthenticatedRole = require("../middleware/requireAuthenticatedRole");

const {
  getPackages,
  createPackage,
  updatePackage,
  updatePackageStatus,
} = require("../controllers/packageController");

// Super Admin and Vendor can view packages.
router.get(
  "/",
  requireAuthenticatedRole("SUPER_ADMIN", "userId", false),
  getPackages,
);

// Super Admin only.
router.post(
  "/",
  requireAuthenticatedRole("SUPER_ADMIN", "userId", false),
  createPackage,
);

router.put(
  "/:pckgId",
  requireAuthenticatedRole("SUPER_ADMIN", "userId", false),
  updatePackage,
);

router.patch(
  "/:pckgId/status",
  requireAuthenticatedRole("SUPER_ADMIN", "userId", false),
  updatePackageStatus,
);

module.exports = router;

