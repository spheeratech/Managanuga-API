const app = require("./src/app");
const pool = require("./db");
const firebaseApp = require("./src/config/firebaseAdmin");

const PORT = process.env.PORT || 5001;
const SHUTDOWN_TIMEOUT_MS = 30000;

const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

let shutdownStarted = false;

const shutdown = (signal) => {
  if (shutdownStarted) {
    return;
  }

  shutdownStarted = true;
  console.log(`${signal} received; shutting down gracefully.`);

  const forceShutdownTimer = setTimeout(() => {
    console.error(
      `Graceful shutdown exceeded ${SHUTDOWN_TIMEOUT_MS}ms; forcing exit.`,
    );
    process.exit(1);
  }, SHUTDOWN_TIMEOUT_MS);

  server.close(async (serverError) => {
    let shutdownFailed = false;

    if (serverError) {
      shutdownFailed = true;
      console.error("Error closing HTTP server:", serverError);
    }

    const cleanupTasks = [
      { name: "PostgreSQL pool", close: () => pool.end() },
    ];

    if (firebaseApp) {
      cleanupTasks.push({
        name: "Firebase Admin",
        close: () => firebaseApp.delete(),
      });
    }

    const cleanupResults = await Promise.allSettled(
      cleanupTasks.map(({ close }) => Promise.resolve().then(close)),
    );

    cleanupResults.forEach((result, index) => {
      if (result.status === "rejected") {
        shutdownFailed = true;
        console.error(
          `Error closing ${cleanupTasks[index].name}:`,
          result.reason,
        );
      }
    });

    clearTimeout(forceShutdownTimer);
    process.exitCode = shutdownFailed ? 1 : 0;
  });

  if (typeof server.closeIdleConnections === "function") {
    server.closeIdleConnections();
  }
};

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

server.on("error", (error) => {
  console.error("HTTP server error:", error);
  if (shutdownStarted) {
    process.exitCode = 1;
    return;
  }

  shutdown("HTTP server error");
});
