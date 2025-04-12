const express = require("express");
const router = express.Router();
const { handleHealthCheck } = require("../controllers/healthCheckController");
const {
  validateHealthCheckRequest,
} = require("../middleware/healthCheckMiddleware");

// Original health check endpoint
router.get("/", validateHealthCheckRequest, handleHealthCheck);

// New CICD endpoint for testing deployments
router.get("/cicd", validateHealthCheckRequest, handleHealthCheck);

// Block all other methods on the root path
router.all("/", validateHealthCheckRequest, (req, res) =>
  res.status(405).end()
);

// Block all other methods on the cicd path
router.all("/cicd", validateHealthCheckRequest, (req, res) =>
  res.status(405).end()
);

module.exports = router;