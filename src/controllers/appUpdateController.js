
const { logException } = require("../utils/exceptionLogger.js");
const AppUpdate = require("../models/AppUpdate");

const parseVersion = (value) => {
  const version = String(value || "").trim();

  if (!/^\d+(?:\.\d+)*$/.test(version)) {
    return null;
  }

  const parts = version.split(".").map(Number);

  if (parts.some((part) => !Number.isSafeInteger(part))) {
    return null;
  }

  return parts;
};

const compareVersions = (version1, version2) => {
  const length = Math.max(version1.length, version2.length);

  for (let i = 0; i < length; i++) {
    const a = version1[i] ?? 0;
    const b = version2[i] ?? 0;

    if (a > b) return 1;
    if (a < b) return -1;
  }

  return 0;
};

const checkAppUpdate = async (req, res, next) => {
  try {
    const platform = String(req.query.platform || "").toUpperCase();
    const currentVersion = String(req.query.currentVersion || "").trim();

    if (!["IOS", "ANDROID"].includes(platform)) {
      return res.status(400).json({
        success: false,
        message: "Invalid platform. Use IOS or ANDROID.",
      });
    }

    const parsedCurrent = parseVersion(currentVersion);

    if (!parsedCurrent) {
      return res.status(400).json({
        success: false,
        message: "A valid currentVersion is required.",
      });
    }

    const config = await AppUpdate.getActiveAppUpdate(platform);

    if (!config) {
      return res.status(404).json({
        success: false,
        message: "No active update configuration found.",
      });
    }

    const parsedLatest = parseVersion(config.latest_version);
    const parsedMinimum = parseVersion(config.minimum_version);

    if (
      !parsedLatest ||
      !parsedMinimum ||
      compareVersions(parsedMinimum, parsedLatest) > 0 ||
      !config.store_url
    ) {
      console.error("Invalid app update configuration:", platform);

      return res.status(500).json({
        success: false,
        message: "App update configuration is invalid.",
      });
    }

    const updateAvailable =
      compareVersions(parsedCurrent, parsedLatest) < 0;

    const forceUpdate =
      compareVersions(parsedCurrent, parsedMinimum) < 0;

    return res.status(200).json({
      success: true,
      platform,
      currentVersion,
      latestVersion: config.latest_version,
      minimumVersion: config.minimum_version,
      updateAvailable: updateAvailable || forceUpdate,
      forceUpdate,
      updateMessage: config.update_message,
      storeUrl: config.store_url,
    });
  } catch (error) {
    void logException(error);
    next(error);
  }
};

module.exports = {
  checkAppUpdate,
};
