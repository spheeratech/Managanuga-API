const express = require("express");

const router = express.Router();

const {
  createUser,
  getAllUsers,
  getUsersByVendorId,
  getUserById,
  updateUserStatus,
  loginUser,
  updateUser,
  deleteUser,
} = require("../controllers/adminUserController");

router.post("/", createUser);
router.post("/login", loginUser);

router.get("/", getAllUsers);
router.get("/vendor-users", getUsersByVendorId);
// router.get("/:userId", getUserById);

router.put("/:userId", updateUser);
router.delete("/:userId", deleteUser);

router.patch("/:userId/status", updateUserStatus);

module.exports = router;
