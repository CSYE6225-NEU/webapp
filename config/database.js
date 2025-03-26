const { Sequelize } = require("sequelize");
require("dotenv").config();

// Import the cloudwatchService in a way that won't cause circular dependencies
let cloudwatchService;
try {
  cloudwatchService = require("../services/cloudwatchService");
} catch (error) {
  // If the service isn't available yet, we'll use a temporary logger
  cloudwatchService = {
    log: (level, message, data) => {
      console[level === 'error' ? 'error' : 'log'](message, data || '');
    },
    recordDbTiming: () => {} // No-op function
  };
}

// Create Sequelize instance with query logging
const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD, 
  {
    host: process.env.DB_HOST,
    dialect: "mysql",
    logging: (sql, timing) => {
      // Extract the query type (SELECT, INSERT, etc.)
      const queryType = sql.trim().split(' ')[0].toLowerCase();
      
      // Log query execution
      cloudwatchService.log('info', 'Database query executed', {
        query: sql.substring(0, 100) + (sql.length > 100 ? '...' : ''),
        executionTime: timing ? `${timing}ms` : 'unknown'
      });
      
      // Record metrics if timing is available
      if (timing) {
        cloudwatchService.recordDbTiming(queryType, timing);
      }
    },
    benchmark: true, // Enable timing for query logging
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

module.exports = sequelize;