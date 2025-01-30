const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const healthCheck = sequelize.define(
  "healthCheck",
  {
    checkId: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      field: "check_id",
    },
    datetime: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
      field: "datetime",
    },
  },
  {
    tableName: "health_check",
    timestamps: false,
  }
);

module.exports = healthCheck;
