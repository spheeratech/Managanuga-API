const { logException } = require("../utils/exceptionLogger.js");
const Package = require("../models/Package");

const numericFields = [
  "capacity_value",
  "pck_weight",
  "pck_length",
  "pck_breadth",
  "pck_height",
  "max_weight",
  "gross_pckg_wt",
];

const positiveFields = [
  "capacity_value",
  "pck_length",
  "pck_breadth",
  "pck_height",
  "max_weight",
  "gross_pckg_wt",
];

const getPackageData = (body) => {
  const data = {};

  for (const field of numericFields) {
    const value = body[field];

    if (value === undefined || value === null || value === "") {
      data[field] = null;
      continue;
    }

    const number = Number(value);

    if (!Number.isFinite(number)) {
      return {
        error: `${field} must be a valid number`,
      };
    }

    if (positiveFields.includes(field) && number <= 0) {
      return {
        error: `${field} must be greater than zero`,
      };
    }

    if (field === "pck_weight" && number < 0) {
      return {
        error: "pck_weight cannot be negative",
      };
    }

    data[field] = number;
  }

  data.pckg_name = String(body.pckg_name || "").trim();
  data.pckg_type = String(body.pckg_type || "BOX")
    .trim()
    .toUpperCase();

  data.capacity_unit = String(body.capacity_unit || "").trim();

  if (!data.pckg_name) {
    return { error: "pckg_name is required" };
  }

  if (!data.pckg_type) {
    return { error: "pckg_type is required" };
  }

  if (data.capacity_value === null) {
    return { error: "capacity_value is required" };
  }

  if (!data.capacity_unit) {
    return { error: "capacity_unit is required" };
  }

  if (data.gross_pckg_wt === null) {
    return { error: "gross_pckg_wt is required" };
  }

  return { data };
};

const getPackages = async (req, res) => {
  try {
    const packages = await Package.getAll();

    return res.status(200).json({
      success: true,
      count: packages.length,
      data: packages,
    });
  } catch (error) {
    void logException(error);
    console.error("Get packages error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch packages",
    });
  }
};

const createPackage = async (req, res) => {
  try {
    const { data, error } = getPackageData(req.body);

    if (error) {
      return res.status(400).json({
        success: false,
        message: error,
      });
    }

    const created = await Package.create({
      ...data,
      created_by: req.authenticatedUser.id,
    });

    return res.status(201).json({
      success: true,
      message: "Package created successfully",
      data: created,
    });
  } catch (error) {
    void logException(error);
    console.error("Create package error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create package",
    });
  }
};

const updatePackage = async (req, res) => {
  try {
    const pckgId = Number(req.params.pckgId);

    if (!Number.isSafeInteger(pckgId) || pckgId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid package ID",
      });
    }

    const { data, error } = getPackageData(req.body);

    if (error) {
      return res.status(400).json({
        success: false,
        message: error,
      });
    }

    const updated = await Package.update(
      pckgId,
      data,
      req.authenticatedUser.id,
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Package not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Package updated successfully",
      data: updated,
    });
  } catch (error) {
    void logException(error);
    console.error("Update package error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update package",
    });
  }
};

const updatePackageStatus = async (req, res) => {
  try {
    const pckgId = Number(req.params.pckgId);
    const { isActive } = req.body;

    if (!Number.isSafeInteger(pckgId) || pckgId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid package ID",
      });
    }

    if (isActive !== 0 && isActive !== 1) {
      return res.status(400).json({
        success: false,
        message: "isActive must be 0 or 1",
      });
    }

    const updated = await Package.updateStatus(
      pckgId,
      isActive,
      req.authenticatedUser.id,
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Package not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: isActive
        ? "Package activated successfully"
        : "Package deactivated successfully",
      data: updated,
    });
  } catch (error) {
    void logException(error);
    console.error("Update package status error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update package status",
    });
  }
};

module.exports = {
  getPackages,
  createPackage,
  updatePackage,
  updatePackageStatus,
};
