const HealthCheck = require("../models/HealthCheck");
const cloudwatchService = require("../services/cloudwatchService");

const handleHealthCheck = async (req, res) => {
  try {
    cloudwatchService.log('info', 'Health check initiated');
    
    await HealthCheck.create({
      datetime: new Date(),
    });
    
    cloudwatchService.log('info', 'Health check completed successfully');
    res.status(200).end();
  } catch (error) {
    cloudwatchService.log('error', 'Health check failed', {
      error: error.message,
      stack: error.stack
    });
    res.status(503).end();
  }
};

module.exports = {
  handleHealthCheck,
};