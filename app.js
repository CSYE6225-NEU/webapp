const express = require("express");
const healthCheckRoutes = require("./routes/healthCheckRoutes");
const fileRoutes = require("./routes/fileRoutes");
const sequelize = require("./config/database");
const healthCheck = require("./models/HealthCheck");
const File = require("./models/File");
const { initializeDatabase } = require("./utils/dbInitializer");

const app = express();

// Middleware
app.use(express.json());

// Routes
app.use("/healthz", healthCheckRoutes);
app.use("/v1/file", fileRoutes);

// Initialize database
(async () => {
  try {
    await initializeDatabase(sequelize, healthCheck, File);
    console.log("Database sync complete");
  } catch (error) {
    console.error("Unable to sync database:", error);
  }
})();

module.exports = app;