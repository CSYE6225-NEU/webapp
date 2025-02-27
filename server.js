require("dotenv").config();
const app = require("./app");
const sequelize = require("./config/database");
const healthCheck = require("./models/HealthCheck");
const { initializeDatabase } = require("./utils/dbInitializer");

const PORT = process.env.PORT;

async function startServer() {
  try {
    // initialize database
    await initializeDatabase(sequelize, healthCheck);

    // start server
    app.listen(PORT, () => {
      console.log(`Server running on port: ${PORT}`);
    });
  } catch (error) {
    console.error("Server startup failed:", error);
    process.exit(1);
  }
}

startServer();
