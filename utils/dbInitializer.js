const mysql = require("mysql2/promise");
require("dotenv").config();

async function createDatabase() {
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
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

async function initializeDatabase(sequelize, ...models) {
  try {
    // We may still want to create the database if it doesn't exist
    // though this might not be necessary with RDS
    await createDatabase();
    
    // Authenticate with the database
    await sequelize.authenticate();
    
    // Sync all provided models
    for (const model of models) {
      await model.sync();
    }
    
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