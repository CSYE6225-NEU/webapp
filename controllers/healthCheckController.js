const HealthCheck = require("../models/HealthCheck");

const handleHealthCheck = async (req, res) => {
  try {
    await HealthCheck.create({
      datetime: new Date(),
    });
    res.status(200).end();
  } catch (error) {
    console.error("Health check failed:", error);
    res.status(503).end();
  }
};

module.exports = {
  handleHealthCheck,
};
