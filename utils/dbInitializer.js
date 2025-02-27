const mysql = require("mysql2/promise");
require("dotenv").config();

async function createDatabase() {
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.MYSQL_ROOT_PASSWORD,
    });

    await connection.query(
      `CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME}`
    );

    await connection.end();
    console.log("Database checked/created successfully");
    return true;
  } catch (error) {
    console.error("Database creation failed:", error);
    throw error;
  }
}

async function initializeDatabase(sequelize, healthCheck) {
  try {
    await createDatabase();
    await sequelize.authenticate();
    await healthCheck.sync();
    console.log("Database initialized successfully");
    return true;
  } catch (error) {
    console.error("Database initialization failed:", error);
    throw error;
  }
}

module.exports = {
  createDatabase,
  initializeDatabase,
};
