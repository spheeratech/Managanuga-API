const jwt = require("jsonwebtoken");
const pool = require("../../db");

const requireAuthenticatedRole = (
  requiredRole,
  identityQueryParam,
  identityRequired = false
) =>
  async (req, res, next) => {
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

    if (!authenticatedUserId) {
      return res.status(401).json({
        success: false,
        message: "Authentication token does not identify a user",
      });
    }

    const requestedUserId = String(
      req.query[identityQueryParam] ||
        req.body?.[identityQueryParam] ||
        ""
    ).trim();

    if (identityRequired && !requestedUserId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    if (requestedUserId && requestedUserId !== authenticatedUserId) {
      return res.status(403).json({
        success: false,
        message: "You can only access your own account",
      });
    }

    try {
      const requiredRoles = (
        Array.isArray(requiredRole) ? requiredRole : [requiredRole]
      ).map((role) => String(role).trim().toUpperCase());
      const result = await pool.query(
        `
        SELECT 1
        FROM user_login ul
        INNER JOIN lkp_user_roles ur
          ON ur.id = ul.role
        WHERE ul.user_id = $1
          AND ul.is_active = 1
          AND UPPER(TRIM(ur.role_name)) = ANY($2::text[])
        LIMIT 1
        `,
        [authenticatedUserId, requiredRoles]
      );

      if (!result.rows[0]) {
        return res.status(403).json({
          success: false,
          message: `Active ${requiredRoles.join(" or ")} account required`,
        });
      }

      req.authenticatedUser = authenticatedUser;
      return next();
    } catch (error) {
      return next(error);
    }
  };

module.exports = requireAuthenticatedRole;
