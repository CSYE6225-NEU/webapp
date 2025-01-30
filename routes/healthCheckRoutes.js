const express = require("express");
const router = express.Router();
const { performHealthCheck } = require("../controllers/healthCheckController");
const {
  validateHealthCheckRequest,
} = require("../middleware/healthCheckMiddleware");

router.get("/", validateHealthCheckRequest, performHealthCheck);
router.all("/", validateHealthCheckRequest, (req, res) =>
  res.status(405).end()
);

module.exports = router;
