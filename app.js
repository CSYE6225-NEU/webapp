const express = require("express");
const healthCheckRoutes = require("./routes/healthCheckRoutes");
const fileRoutes = require("./routes/fileRoutes");
const sequelize = require("./config/database");
const healthCheck = require("./models/HealthCheck");
const File = require("./models/File");
const { initializeDatabase } = require("./utils/dbInitializer");
const { trackApiMetrics } = require("./middleware/metricsMiddleware");
const cloudwatchService = require("./services/cloudwatchService");

const app = express();

// Start tracking application metrics
cloudwatchService.log('info', 'Application starting up');

// Middleware
app.use(express.json());

// Apply metrics tracking middleware to all routes
app.use(trackApiMetrics);

// Routes
app.use("/healthz", healthCheckRoutes);
app.use("/v1/file", fileRoutes);

// Global error handler
app.use((err, req, res, next) => {
  // Log the error
  cloudwatchService.log('error', 'Unhandled exception', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method
  });
  
  // Send an appropriate response to the client
  res.status(500).json({ error: "Internal server error" });
});

// Initialize database
(async () => {
  try {
    await initializeDatabase(sequelize, healthCheck, File);
    cloudwatchService.log('info', 'Database initialization complete');
  } catch (error) {
    cloudwatchService.log('error', 'Database initialization failed', { error: error.message });
  }
})();

module.exports = app;