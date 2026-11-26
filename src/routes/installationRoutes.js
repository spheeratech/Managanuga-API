
const express = require("express");
const router = express.Router();

const requireAuthenticatedRole = require(
  "../middleware/requireAuthenticatedRole",
);

const installationController = require(
  "../controllers/installationController",
);

// Customer APIs
router.post(
  "/register",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", false),
  installationController.registerInstallation,
);

router.put(
  "/:deviceId",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", false),
  installationController.updateMyInstallation,
);

router.get(
  "/mine",
  requireAuthenticatedRole(["CUSTOMER", "USER"], "user_id", false),
  installationController.getMyInstallations,
);

// Admin APIs
router.get(
  "/",
  requireAuthenticatedRole(["ADMIN", "SUPER_ADMIN"], "user_id", false),
  installationController.getAllInstallations,
);

router.get(
  "/mobile/:mobileNumber",
  requireAuthenticatedRole(["ADMIN", "SUPER_ADMIN"], "user_id", false),
  installationController.getInstallationsByMobile,
);

router.get(
  "/:id",
  requireAuthenticatedRole(["ADMIN", "SUPER_ADMIN"], "user_id", false),
  installationController.getInstallationById,
);

router.patch(
  "/:id/status",
  requireAuthenticatedRole(["ADMIN", "SUPER_ADMIN"], "user_id", false),
  installationController.updateInstallationStatus,
);

module.exports = router;
