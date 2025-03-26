const AWS = require('aws-sdk');
const fs = require('fs');
const path = require('path');
const StatsD = require('hot-shots');

// Create a client for using CloudWatch Logs directly if needed
const cloudWatchLogs = new AWS.CloudWatchLogs();

// Create a StatsD client that will send metrics to CloudWatch Agent
const statsd = new StatsD({
  host: 'localhost', 
  port: 8125,
  prefix: 'webapp_',
  errorHandler: (error) => {
    console.error(`StatsD error: ${error}`);
  }
});

// Setup logger that writes to both console and file
const logFilePath = path.join('/opt/csye6225', 'webapp.log');

/**
 * Write a log message to both console and log file
 * @param {string} level - Log level (info, warn, error)
 * @param {string} message - Log message
 * @param {object} [data] - Optional additional data
 */
const log = (level, message, data = null) => {
  const timestamp = new Date().toISOString();
  const formattedLog = data 
    ? `${timestamp} [${level.toUpperCase()}] ${message} ${JSON.stringify(data)}`
    : `${timestamp} [${level.toUpperCase()}] ${message}`;
  
  // Log to console
  if (level === 'error') {
    console.error(formattedLog);
  } else if (level === 'warn') {
    console.warn(formattedLog);
  } else {
    console.log(formattedLog);
  }
  
  // Log to file (append)
  try {
    fs.appendFileSync(logFilePath, formattedLog + '\n');
  } catch (err) {
    console.error(`Failed to write to log file: ${err.message}`);
  }
};

/**
 * Record API call count metric
 * @param {string} apiName - Name of the API
 */
const recordApiCall = (apiName) => {
  try {
    statsd.increment(`api.${apiName}.count`);
  } catch (error) {
    log('error', `Failed to record API metric: ${error.message}`);
  }
};

/**
 * Record timing for an API call
 * @param {string} apiName - Name of the API
 * @param {number} timeInMs - Time in milliseconds
 */
const recordApiTiming = (apiName, timeInMs) => {
  try {
    statsd.timing(`api.${apiName}.time`, timeInMs);
  } catch (error) {
    log('error', `Failed to record API timing metric: ${error.message}`);
  }
};

/**
 * Record timing for a database query
 * @param {string} queryName - Name of the query
 * @param {number} timeInMs - Time in milliseconds
 */
const recordDbTiming = (queryName, timeInMs) => {
  try {
    statsd.timing(`db.${queryName}.time`, timeInMs);
  } catch (error) {
    log('error', `Failed to record DB timing metric: ${error.message}`);
  }
};

/**
 * Record timing for an S3 operation
 * @param {string} operation - Name of the S3 operation
 * @param {number} timeInMs - Time in milliseconds
 */
const recordS3Timing = (operation, timeInMs) => {
  try {
    statsd.timing(`s3.${operation}.time`, timeInMs);
  } catch (error) {
    log('error', `Failed to record S3 timing metric: ${error.message}`);
  }
};

module.exports = {
  log,
  recordApiCall,
  recordApiTiming, 
  recordDbTiming,
  recordS3Timing
};