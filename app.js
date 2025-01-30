// app.js
const express = require("express");
const {
  validateHealthCheckRequest,
} = require("./middleware/healthCheckMiddleware");
const { handleHealthCheck } = require("./controllers/healthCheckController");

const app = express();

// Health check endpoint with proper callback function
app.get("/healthz", validateHealthCheckRequest, handleHealthCheck);

// Handle unsupported methods for /healthz
app.all("/healthz", (req, res) => {
  res.set({
    "Cache-Control": "no-cache, no-store, must-revalidate",
    Pragma: "no-cache",
    "X-Content-Type-Options": "nosniff",
  });
  res.status(405).end();
});

// Handle unsupported routes
app.use((req, res) => {
  res.status(404).end();
});

module.exports = app;
