const pool = require("../../db");
const AdminUser = require("../models/AdminUser");
const generateUserId = require("../utils/generatedUserId");

// --------------------------------------------------
// ROLE PERMISSIONS
// --------------------------------------------------
const ROLE_PERMISSIONS = {
  SUPER_ADMIN: ["SUPER_ADMIN", "ADMIN", "VENDOR", "RESELLER", "CUSTOMER"],
  ADMIN: ["ADMIN", "VENDOR", "RESELLER", "CUSTOMER"],
  VENDOR: ["VENDOR", "RESELLER", "CUSTOMER"],
  RESELLER: ["RESELLER", "CUSTOMER"],
  CUSTOMER: [],
};

// --------------------------------------------------
// CREATE USER
// --------------------------------------------------
const createUser = async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      firstName,
      lastName,
      username,
      mobileNo,
      role,
      email,
      address,
      city,
      state,
      pincode,
      subscription,

      // Creator information sent from frontend
      creatorRole,
      creatorUserId,
    } = req.body;

    // --------------------------------------------------
    // REQUIRED FIELDS
    // --------------------------------------------------
    if (!firstName || !username || !mobileNo || !role) {
      return res.status(400).json({
        success: false,
        message: "firstName, username, mobileNo and role are required",
      });
    }

    // --------------------------------------------------
    // CREATOR INFORMATION
    // No JWT is used.
    // Frontend sends creatorRole + creatorUserId.
    // --------------------------------------------------
    if (!creatorRole || !creatorUserId) {
      return res.status(400).json({
        success: false,
        message: "creatorRole and creatorUserId are required",
      });
    }

    const normalizedCreatorRole = String(creatorRole).trim().toUpperCase();

    const targetRole = String(role).trim().toUpperCase();

    const normalizedCreatorUserId = String(creatorUserId).trim();

    // --------------------------------------------------
    // VALIDATE TARGET ROLE
    // --------------------------------------------------
    if (!Object.prototype.hasOwnProperty.call(ROLE_PERMISSIONS, targetRole)) {
      return res.status(400).json({
        success: false,
        message: "Invalid role",
      });
    }

    // --------------------------------------------------
    // VALIDATE CREATOR ROLE
    // --------------------------------------------------
    if (
      !Object.prototype.hasOwnProperty.call(
        ROLE_PERMISSIONS,
        normalizedCreatorRole,
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid creator role",
      });
    }

    // --------------------------------------------------
    // CHECK CREATOR PERMISSION
    //
    // Example:
    // SUPER_ADMIN -> ADMIN       YES
    // ADMIN       -> VENDOR      YES
    // VENDOR      -> RESELLER    YES
    // RESELLER    -> CUSTOMER    YES
    // CUSTOMER    -> VENDOR      NO
    // --------------------------------------------------
    if (!ROLE_PERMISSIONS[normalizedCreatorRole].includes(targetRole)) {
      return res.status(403).json({
        success: false,
        message: `${normalizedCreatorRole} cannot create ${targetRole}`,
      });
    }

    // --------------------------------------------------
    // VERIFY CREATOR EXISTS
    // --------------------------------------------------
    const creatorResult = await client.query(
      `
      SELECT
        user_id,
        role,
        is_active
      FROM user_login
      WHERE user_id = $1
      LIMIT 1
      `,
      [normalizedCreatorUserId],
    );

    if (creatorResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Creator user not found",
      });
    }

    const creator = creatorResult.rows[0];

    // --------------------------------------------------
    // VERIFY CREATOR ROLE MATCHES DATABASE
    // --------------------------------------------------
    if (creator.role !== normalizedCreatorRole) {
      return res.status(403).json({
        success: false,
        message: "Creator role does not match the selected creator user",
      });
    }

    // --------------------------------------------------
    // CREATOR MUST BE ACTIVE
    // --------------------------------------------------
    if (!creator.is_active) {
      return res.status(403).json({
        success: false,
        message: "Creator account is inactive",
      });
    }

    // --------------------------------------------------
    // CHECK USERNAME
    // --------------------------------------------------
    const existingUsername = await AdminUser.findByUsername(username);

    if (existingUsername) {
      return res.status(409).json({
        success: false,
        message: "Username already exists",
      });
    }

    // --------------------------------------------------
    // CHECK MOBILE NUMBER
    // --------------------------------------------------
    const existingMobile = await AdminUser.findByMobile(mobileNo);

    if (existingMobile) {
      return res.status(409).json({
        success: false,
        message: "Mobile number already exists",
      });
    }

    // --------------------------------------------------
    // CHECK EMAIL
    // --------------------------------------------------
    if (email) {
      const existingEmail = await AdminUser.findByEmail(email);

      if (existingEmail) {
        return res.status(409).json({
          success: false,
          message: "Email already exists",
        });
      }
    }

    // --------------------------------------------------
    // GENERATE USER ID
    // --------------------------------------------------
    const userId = await generateUserId(targetRole);

    const generatedPassword = "123456";

    await client.query("BEGIN");

    // --------------------------------------------------
    // CREATE USER
    // --------------------------------------------------
    const user = await AdminUser.createUser(
      client,
      {
        userId,
        username,
        mobileNo,
        password: generatedPassword,
        role: targetRole,
        isActive: true,

        createdBy: normalizedCreatorRole,

        assignedBy: normalizedCreatorUserId,

        relationshipType: targetRole,
      },
      {
        userId,
        firstName,
        lastName: lastName || null,
        email: email || null,
        address: address || null,
        city: city || null,
        state: state || null,
        pincode: pincode || null,
        subscription: subscription || null,
      },
    );

    await client.query("COMMIT");

    return res.status(201).json({
      success: true,
      message: `${targetRole} created successfully`,

      data: {
        userId: user.login.user_id,
        username: user.login.username,
        role: user.login.role,

        firstName: user.info.first_name,
        lastName: user.info.last_name,
        email: user.info.email,

        mobileNo: user.login.mobile_no,

        address: user.info.address,
        city: user.info.city,
        state: user.info.state,
        pincode: user.info.pincode,

        subscription: user.info.subscription,

        isActive: user.login.is_active,

        // Creator relationship
        createdBy: user.login.created_by,
        assignedBy: user.login.assigned_by,
        relationshipType: user.login.relationship_type,

        createdAt: user.login.created_at,
      },
    });
  } catch (error) {
    // --------------------------------------------------
    // ROLLBACK
    // --------------------------------------------------
    await client.query("ROLLBACK");

    console.error("Create user error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create user",
      error: error.message,
    });
  } finally {
    client.release();
  }
};

// --------------------------------------------------
// GET ALL USERS
// --------------------------------------------------
const getAllUsers = async (req, res) => {
  try {
    const users = await AdminUser.getAllUsers();

    console.log("=================================");
    console.log("USERS FROM DATABASE:");
    console.log(JSON.stringify(users, null, 2));
    console.log("TOTAL USERS:", users.length);
    console.log("=================================");

    return res.status(200).json({
      success: true,
      count: users.length,
      data: users,
    });
  } catch (error) {
    console.error("Get all users error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch users",
      error: error.message,
    });
  }
};

// --------------------------------------------------
// GET USER BY ID
// --------------------------------------------------
const getUserById = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    const user = await AdminUser.getUserById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error("Get user by ID error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch user",
      error: error.message,
    });
  }
};

// --------------------------------------------------
// ACTIVATE / DEACTIVATE USER
// --------------------------------------------------
const updateUserStatus = async (req, res) => {
  try {
    const { userId } = req.params;
    const { isActive } = req.body;

    if (typeof isActive !== "boolean") {
      return res.status(400).json({
        success: false,
        message: "isActive must be true or false",
      });
    }

    const user = await AdminUser.updateStatus(userId, isActive);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: isActive
        ? "User activated successfully"
        : "User deactivated successfully",
      data: user,
    });
  } catch (error) {
    console.error("Update user status error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update user status",
      error: error.message,
    });
  }
};
// --------------------------------------------------
// LOGIN USER (Dashboard Admin / Staff / Reseller / Vendor)
// --------------------------------------------------
const loginUser = async (req, res) => {
  const client = await pool.connect();

  try {
    const { email, username, password } = req.body;
    const identifier = (email || username || "").trim();

    if (!identifier || !password) {
      return res.status(400).json({
        success: false,
        message: "Email/Username and password are required",
      });
    }

    // Lookup matching account in user_login joined with user_info
    const result = await client.query(
      `
      SELECT 
        l.user_id,
        l.username,
        l.mobile_no,
        l.password,
        l.role,
        l.is_active,
        i.first_name,
        i.last_name,
        i.email
      FROM user_login l
      LEFT JOIN user_info i ON l.user_id = i.user_id
      WHERE LOWER(i.email) = LOWER($1) 
         OR LOWER(l.username) = LOWER($1) 
         OR l.mobile_no = $1
      LIMIT 1
      `,
      [identifier],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const user = result.rows[0];

    if (!user.is_active) {
      return res.status(403).json({
        success: false,
        message: "Account is inactive. Please contact administrator.",
      });
    }

    // Direct password match (or hash check if hashed)
    if (user.password !== password) {
      return res.status(400).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    delete user.password;

    return res.status(200).json({
      success: true,
      message: "Login successful",
      data: user,
    });
  } catch (error) {
    console.error("Dashboard login error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to login",
      error: error.message,
    });
  } finally {
    client.release();
  }
};
// --------------------------------------------------
// UPDATE USER PROFILE
// --------------------------------------------------
const updateUser = async (req, res) => {
  const client = await pool.connect();
  try {
    const { userId } = req.params;
    const {
      firstName,
      lastName,
      email,
      mobileNo,
      role,
      address,
      city,
      state,
      pincode,
      subscription,
      isActive,
    } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    await client.query("BEGIN");

    const updatedUser = await AdminUser.updateUser(client, userId, {
      firstName,
      lastName,
      email,
      mobileNo,
      role,
      address,
      city,
      state,
      pincode,
      subscription,
      isActive,
    });

    if (!updatedUser) {
      await client.query("ROLLBACK");
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    await client.query("COMMIT");

    return res.status(200).json({
      success: true,
      message: "User profile updated successfully",
      data: updatedUser,
    });
  } catch (error) {
    await client.query("ROLLBACK");
    console.error("Update user error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to update user",
      error: error.message,
    });
  } finally {
    client.release();
  }
};

// --------------------------------------------------
// DELETE USER PROFILE
// --------------------------------------------------
const deleteUser = async (req, res) => {
  const client = await pool.connect();
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId is required",
      });
    }

    await client.query("BEGIN");

    const deletedUser = await AdminUser.deleteUser(client, userId);

    if (!deletedUser) {
      await client.query("ROLLBACK");
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    await client.query("COMMIT");

    return res.status(200).json({
      success: true,
      message: "User deleted successfully",
      data: deletedUser,
    });
  } catch (error) {
    await client.query("ROLLBACK");
    console.error("Delete user error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to delete user",
      error: error.message,
    });
  } finally {
    client.release();
  }
};

module.exports = {
  createUser,
  getAllUsers,
  // getUserById,
  updateUserStatus,
  loginUser,
  updateUser,
  deleteUser,
};
