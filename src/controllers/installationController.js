
const { logException } = require("../utils/exceptionLogger.js");
const Installation = require("../models/Installation");
const pool = require("../../db");

const getAuthenticatedMobile = async (authenticatedUser) => {
  const userId = String(authenticatedUser?.id || "").trim();

  if (!userId) return null;

  const result = await pool.query(
    `
    SELECT mobile_no
    FROM user_login
    WHERE user_id = $1
      AND is_active = 1
    LIMIT 1
    `,
    [userId],
  );

  return result.rows[0]?.mobile_no || null;
};

const registerInstallation = async (req, res, next) => {
  try {
    const mobileNumber = await getAuthenticatedMobile(
      req.authenticatedUser,
    );

    if (!mobileNumber) {
      return res.status(404).json({
        success: false,
        message: "Registered mobile number not found.",
      });
    }

    const {
      device_id,
      device_name,
      os_type,
      os_version,
      app_version,
      build_number,
      fcm_token,
    } = req.body;

    const deviceId = String(device_id || "").trim();
    const osType = String(os_type || "").trim().toUpperCase();

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: "device_id is required.",
      });
    }

    if (!["ANDROID", "IOS"].includes(osType)) {
      return res.status(400).json({
        success: false,
        message: "os_type must be ANDROID or IOS.",
      });
    }

    const installation = await Installation.registerInstallation({
      mobile_number: mobileNumber,
      device_id: deviceId,
      device_name: device_name || null,
      os_type: osType,
      os_version: os_version || null,
      app_version: app_version || null,
      build_number: build_number || null,
      fcm_token: fcm_token || null,
    });

    return res.status(200).json({
      success: true,
      message: "Installation registered successfully.",
      data: installation,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

const updateMyInstallation = async (req, res, next) => {
  try {
    const mobileNumber = await getAuthenticatedMobile(
      req.authenticatedUser,
    );

    if (!mobileNumber) {
      return res.status(404).json({
        success: false,
        message: "Registered mobile number not found.",
      });
    }

    const deviceId = String(req.params.deviceId || "").trim();

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: "Valid device ID is required.",
      });
    }

    if (
      req.body.os_type &&
      !["ANDROID", "IOS"].includes(
        String(req.body.os_type).trim().toUpperCase(),
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "os_type must be ANDROID or IOS.",
      });
    }

    const installation = await Installation.updateInstallation(
      deviceId,
      mobileNumber,
      {
        device_name: req.body.device_name,
        os_type: req.body.os_type
          ? String(req.body.os_type).trim().toUpperCase()
          : undefined,
        os_version: req.body.os_version,
        app_version: req.body.app_version,
        build_number: req.body.build_number,
        fcm_token: req.body.fcm_token,
      },
    );

    if (!installation) {
      return res.status(404).json({
        success: false,
        message: "Active installation not found for this account.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Installation updated successfully.",
      data: installation,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

const getMyInstallations = async (req, res, next) => {
  try {
    const mobileNumber = await getAuthenticatedMobile(
      req.authenticatedUser,
    );

    if (!mobileNumber) {
      return res.status(404).json({
        success: false,
        message: "Registered mobile number not found.",
      });
    }

    const installations =
      await Installation.getInstallationsByMobile(mobileNumber);

    return res.status(200).json({
      success: true,
      count: installations.length,
      data: installations,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

const getAllInstallations = async (req, res, next) => {
  try {
    const parsedLimit = Number.parseInt(req.query.limit, 10);
    const parsedOffset = Number.parseInt(req.query.offset, 10);

    const limit = Number.isInteger(parsedLimit)
      ? Math.min(Math.max(parsedLimit, 1), 500)
      : 100;

    const offset = Number.isInteger(parsedOffset)
      ? Math.max(parsedOffset, 0)
      : 0;

    const installations = await Installation.getAllInstallations(
      limit,
      offset,
    );

    return res.status(200).json({
      success: true,
      count: installations.length,
      limit,
      offset,
      data: installations,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

const getInstallationById = async (req, res, next) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isSafeInteger(id) || id <= 0) {
      return res.status(400).json({
        success: false,
        message: "Valid installation ID is required.",
      });
    }

    const installation = await Installation.getInstallationById(id);

    if (!installation) {
      return res.status(404).json({
        success: false,
        message: "Installation not found.",
      });
    }

    return res.status(200).json({
      success: true,
      data: installation,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

const getInstallationsByMobile = async (req, res, next) => {
  try {
    const mobileNumber = String(req.params.mobileNumber || "").trim();

    if (!/^[0-9]{10,20}$/.test(mobileNumber)) {
      return res.status(400).json({
        success: false,
        message: "Valid mobile number is required.",
      });
    }

    const installations =
      await Installation.getInstallationsByMobile(mobileNumber);

    return res.status(200).json({
      success: true,
      count: installations.length,
      data: installations,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

const updateInstallationStatus = async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const status = String(req.body.status || "")
      .trim()
      .toUpperCase();

    if (!Number.isSafeInteger(id) || id <= 0) {
      return res.status(400).json({
        success: false,
        message: "Valid installation ID is required.",
      });
    }

    if (!["INSTALLED", "UNINSTALLED", "INACTIVE"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid installation status.",
      });
    }

    const installation = await Installation.updateInstallationStatus(
      id,
      status,
    );

    if (!installation) {
      return res.status(404).json({
        success: false,
        message: "Installation not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Installation status updated successfully.",
      data: installation,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

module.exports = {
  registerInstallation,
  updateMyInstallation,
  getMyInstallations,
  getAllInstallations,
  getInstallationById,
  getInstallationsByMobile,
  updateInstallationStatus,
};
