const jwt = require("jsonwebtoken");
const pool = require("../../db");

const requireWalletOwner = async (req, res, next) => {
  const authorization = req.get("authorization") || "";
  const [scheme, token] = authorization.split(" ");

  if (scheme !== "Bearer" || !token) {
    return res.status(401).json({
      success: false,
      message: "Authentication token is required",
    });
  }

  if (!process.env.JWT_SECRET) {
    console.error("JWT_SECRET is not configured");
    return res.status(500).json({
      success: false,
      message: "Authentication is unavailable",
    });
  }

  let authenticatedUser;

  try {
    authenticatedUser = jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired authentication token",
    });
  }

  const authenticatedUserId = String(authenticatedUser.id || "").trim();
  const requestedUserId = String(
    req.params.userId ||
      req.body?.userId ||
      req.body?.user_id ||
      ""
  ).trim();

  if (!authenticatedUserId) {
    return res.status(401).json({
      success: false,
      message: "Authentication token does not identify a user",
    });
  }

  if (!requestedUserId || requestedUserId !== authenticatedUserId) {
    return res.status(403).json({
      success: false,
      message: "You can only access your own wallet",
    });
  }

  try {
    const result = await pool.query(
      `
      SELECT 1
      FROM user_login
      WHERE user_id = $1
        AND is_active = 1
      LIMIT 1
      `,
      [authenticatedUserId]
    );

    if (!result.rows[0]) {
      return res.status(403).json({
        success: false,
        message: "Active account required",
      });
    }

    req.authenticatedUser = authenticatedUser;
    return next();
  } catch (error) {
    return next(error);
  }
};

module.exports = requireWalletOwner;
