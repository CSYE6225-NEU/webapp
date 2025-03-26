const cloudwatchService = require('../services/cloudwatchService');

/**
 * Middleware to track API usage and timing
 * This middleware records count and timing metrics for each API endpoint
 */
const trackApiMetrics = (req, res, next) => {
  // Skip options requests
  if (req.method === 'OPTIONS') {
    return next();
  }

  // Generate an API name from the route
  const baseUrl = req.baseUrl || '';
  const routePath = req.route ? req.route.path : '';
  const apiName = (baseUrl + routePath)
    .replace(/\//g, '.')                    // Replace slashes with dots
    .replace(/^\.+|\.+$/g, '')              // Remove leading/trailing dots
    .replace(/\.:([^\.]+)/g, '.by_$1')      // Convert :id to by_id
    .replace(/\./g, '_')                    // Replace remaining dots with underscores
    .toLowerCase();

  // Record API call count
  cloudwatchService.recordApiCall(`${req.method}_${apiName || 'root'}`);

  // Track request timing
  const startTime = Date.now();

  // Store original end method
  const originalEnd = res.end;

  // Override end method to calculate and record timing
  res.end = function(...args) {
    const endTime = Date.now();
    const executionTime = endTime - startTime;

    // Record API timing
    cloudwatchService.recordApiTiming(`${req.method}_${apiName || 'root'}`, executionTime);

    // Log API call completion with timing and status code
    cloudwatchService.log('info', `API Request`, {
      method: req.method,
      path: req.originalUrl,
      statusCode: res.statusCode,
      executionTime: `${executionTime}ms`,
      userAgent: req.headers['user-agent'] || 'Unknown'
    });

    // Call the original end method
    return originalEnd.apply(this, args);
  };

  // Continue the request chain
  next();
};

module.exports = {
  trackApiMetrics
};