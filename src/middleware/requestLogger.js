const { randomUUID } = require("node:crypto");
const os = require("node:os");
const pool = require("../../db");

const machineInfo = {
  hostname: os.hostname().slice(0, 255),
  nodeVersion: process.version.slice(0, 32),
  processId: process.pid,
  environment: (process.env.NODE_ENV || "development").slice(0, 50),
};

const sanitizeErrorMessage = (message) =>
  String(message || "Request failed")
    .replace(/Bearer\s+[A-Za-z0-9._~+/=-]+/gi, "Bearer [REDACTED]")
    .replace(
      /\b(password|passwd|secret|token|api[_-]?key|authorization|credential)\b(\s*[:=]\s*)("[^"]*"|'[^']*'|[^\s,;]+)/gi,
      "$1$2[REDACTED]",
    )
    .replace(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/gi, "[REDACTED_EMAIL]")
    .replace(/\b(?:\+?\d[\s().-]*){10,}\b/g, "[REDACTED_PHONE]")
    .slice(0, 2000);

const getErrorCode = (error) =>
  typeof error?.code === "string" && /^[A-Za-z0-9_-]{1,100}$/.test(error.code)
    ? error.code
    : null;

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
          (request_id, method, route, status_code, outcome, duration_ms,
           error_type, error_message, error_code, machine_hostname,
           node_version, process_id, environment)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
        [
          req.requestId,
          req.method.slice(0, 16),
          route,
          statusCode,
          outcome,
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
  sanitizeErrorMessage,
};
