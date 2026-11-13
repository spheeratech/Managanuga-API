const { AsyncLocalStorage } = require("node:async_hooks");
const os = require("node:os");
const pool = require("../../db");

const requestContext = new AsyncLocalStorage();

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

const runWithRequestContext = (req, next) => {
  requestContext.run({ req, loggedExceptions: new WeakMap() }, next);
};

const logException = (error, req = requestContext.getStore()?.req) => {
  const exception = error instanceof Error ? error : new Error(String(error));
  const context = requestContext.getStore();
  const existingLog = context?.loggedExceptions.get(exception);

  if (existingLog) {
    return existingLog;
  }

  const route =
    typeof req?.route?.path === "string"
      ? `${req.baseUrl || ""}${req.route.path}`.slice(0, 512)
      : null;

  const loggingPromise = (async () => {
    try {
      await pool.query(
        `INSERT INTO api_exception_logs
          (request_id, method, route, error_type, error_message, error_code,
           machine_hostname, node_version, process_id, environment)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [
          req?.requestId || null,
          req?.method ? req.method.slice(0, 16) : null,
          route,
          typeof exception.name === "string"
            ? exception.name.slice(0, 100)
            : "Error",
          sanitizeErrorMessage(exception.message),
          getErrorCode(exception),
          machineInfo.hostname,
          machineInfo.nodeVersion,
          machineInfo.processId,
          machineInfo.environment,
        ],
      );
    } catch (loggingError) {
      console.error("Failed to write API exception log:", {
        requestId: req?.requestId || null,
        message: loggingError.message,
      });
    }
  })();

  context?.loggedExceptions.set(exception, loggingPromise);
  return loggingPromise;
};

module.exports = {
  getErrorCode,
  logException,
  machineInfo,
  runWithRequestContext,
  sanitizeErrorMessage,
};
