const { randomUUID } = require("node:crypto");
const pool = require("../../db");

const requestLogger = (req, res, next) => {
  const startedAt = process.hrtime.bigint();
  req.requestId = randomUUID();
  res.setHeader("X-Request-ID", req.requestId);

  res.once("finish", () => {
    const durationMs = Math.min(
      Math.round(Number(process.hrtime.bigint() - startedAt) / 1e6),
      2147483647,
    );
    const statusCode = res.statusCode;
    const outcome = statusCode < 400 ? "success" : "failure";
    const route =
      typeof req.route?.path === "string"
        ? `${req.baseUrl}${req.route.path}`.slice(0, 512)
        : "<unmatched>";
    const errorType =
      req.errorType ||
      (statusCode >= 500
        ? "server_error"
        : statusCode >= 400
          ? "http_error"
          : null);

    pool
      .query(
        `INSERT INTO api_request_logs
          (request_id, method, route, status_code, outcome, duration_ms, error_type)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          req.requestId,
          req.method.slice(0, 16),
          route,
          statusCode,
          outcome,
          durationMs,
          errorType,
        ],
      )
      .catch((error) => {
        console.error("Failed to write API request log:", {
          requestId: req.requestId,
          message: error.message,
        });
      });
  });

  next();
};

const errorHandler = (error, req, res, next) => {
  const statusCode =
    Number.isInteger(error.status) && error.status >= 400 && error.status <= 599
      ? error.status
      : Number.isInteger(error.statusCode) &&
          error.statusCode >= 400 &&
          error.statusCode <= 599
        ? error.statusCode
        : 500;

  req.errorType =
    typeof error.name === "string" && /^[A-Za-z][A-Za-z0-9_]{0,99}$/.test(error.name)
      ? error.name
      : "Error";

  console.error("Unhandled request exception:", {
    requestId: req.requestId,
    method: req.method,
    route:
      typeof req.route?.path === "string"
        ? `${req.baseUrl}${req.route.path}`
        : "<unmatched>",
    errorType: req.errorType,
  });

  if (res.headersSent) {
    return next(error);
  }

  return res.status(statusCode).json({
    error: statusCode >= 500 ? "Internal server error" : "Invalid request",
    requestId: req.requestId,
  });
};

module.exports = { requestLogger, errorHandler };
