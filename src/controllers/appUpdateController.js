
const AppUpdate = require("../models/AppUpdate");

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

    if (!currentVersion) {
      return res.status(400).json({
        success: false,
        message: "currentVersion is required.",
      });
    }

    const config = await AppUpdate.getActiveAppUpdate(platform);

    if (!config) {
      return res.status(404).json({
        success: false,
        message: "No active update configuration found.",
      });
    }

    const versionParts = (version) =>
      version.split(".").map((part) => Number(part));

    const compareVersions = (version1, version2) => {
      const v1 = versionParts(version1);
      const v2 = versionParts(version2);
      const length = Math.max(v1.length, v2.length);

      for (let i = 0; i < length; i++) {
        const a = v1[i] || 0;
        const b = v2[i] || 0;

        if (a > b) return 1;
        if (a < b) return -1;
      }

      return 0;
    };

    const updateAvailable =
      compareVersions(currentVersion, config.latest_version) < 0;

    const forceUpdate =
      compareVersions(currentVersion, config.minimum_version) < 0;

    return res.status(200).json({
      success: true,
      platform,
      currentVersion,
      latestVersion: config.latest_version,
      minimumVersion: config.minimum_version,
      updateAvailable,
      forceUpdate,
      updateMessage: config.update_message,
      storeUrl: config.store_url,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  checkAppUpdate,
};
