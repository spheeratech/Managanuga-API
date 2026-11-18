const { randomUUID } = require("node:crypto");
const pool = require("../../db");
const {
  getErrorCode,
  logException,
  machineInfo,
  runWithRequestContext,
  sanitizeErrorMessage,
} = require("../utils/exceptionLogger");

const requestLogger = (req, res, next) => {
  const startedAt = process.hrtime.bigint();
  req.requestId = randomUUID();
  res.setHeader("X-Request-ID", req.requestId);

  const originalJson = res.json.bind(res);
  res.json = (body) => {
    if (res.statusCode >= 400 && body && typeof body === "object") {
      const responseMessage =
        typeof body.message === "string"
          ? body.message
          : typeof body.error === "string"
            ? body.error
            : null;

      if (responseMessage && !req.errorMessage) {
        req.errorMessage = sanitizeErrorMessage(responseMessage);
      }
    }

    return originalJson(body);
  };

  res.once("finish", () => {
    const statusCode = res.statusCode;
    if (statusCode < 400) {
      return;
    }

    const durationMs = Math.min(
      Math.round(Number(process.hrtime.bigint() - startedAt) / 1e6),
      2147483647,
    );
    const route =
      typeof req.route?.path === "string"
        ? `${req.baseUrl}${req.route.path}`.slice(0, 512)
        : "<unmatched>";
    const errorType = req.errorType || (statusCode >= 500 ? "server_error" : "http_error");

    pool
      .query(
        `INSERT INTO api_request_logs
          (request_id, method, route, status_code, outcome, duration_ms,
           error_type, error_message, error_code, machine_hostname,
           node_version, process_id, environment)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
        [
          req.requestId,
          req.method.slice(0, 16),
          route,
          statusCode,
          "failure",
          durationMs,
          errorType,
          req.errorMessage || null,
          req.errorCode || null,
          machineInfo.hostname,
          machineInfo.nodeVersion,
          machineInfo.processId,
          machineInfo.environment,
        ],
      )
      .catch((error) => {
        console.error("Failed to write API request log:", {
          requestId: req.requestId,
          message: error.message,
        });
      });
  });

  runWithRequestContext(req, next);
};

const errorHandler = async (error, req, res, next) => {
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
  req.errorMessage = sanitizeErrorMessage(error.message);
  req.errorCode = getErrorCode(error);

  console.error("Unhandled request exception:", {
    requestId: req.requestId,
    method: req.method,
    route:
      typeof req.route?.path === "string"
        ? `${req.baseUrl}${req.route.path}`
        : "<unmatched>",
    errorType: req.errorType,
    errorMessage: req.errorMessage,
    errorCode: req.errorCode,
  });

  await logException(error, req);

  if (res.headersSent) {
    return next(error);
  }

  return res.status(statusCode).json({
    error: statusCode >= 500 ? "Internal server error" : "Invalid request",
    requestId: req.requestId,
  });
};

module.exports = {
  requestLogger,
  errorHandler,
};
