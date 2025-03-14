#!/bin/bash
# Web Application Deployment Script
#
# This script automates the setup and deployment of a web application with MySQL:
# - Prepares system environment and dependencies
# - Configures MySQL database and service
# - Establishes security context (user/group)
# - Deploys application files with proper permissions

# Application configuration parameters
DATABASE_NAME="local"         # Database instance name for application data
GROUP_NAME="csye6225"         # System security group
USER_NAME="csye6225"          # Application service account
APP_ZIP="./webapp.zip"        # Source application package
APP_DIRECTORY="/opt/csye6225" # Target deployment location

# Utility function for dependency validation
validate_unzip_package() {
  if ! command -v unzip &> /dev/null; then
    echo "Installing required dependency: unzip"
    sudo apt update -y
    sudo apt install unzip -y
  else
    echo "Dependency validation successful: unzip is available"
  fi
}

# Phase 1: System Preparation
echo "Initiating system environment preparation..."
sudo apt update && sudo apt upgrade -y

echo "Validating system dependencies..."
validate_unzip_package

# Phase 2: Database Setup
echo "Installing MySQL database server..."
sudo apt install mysql-server -y

echo "Configuring database service persistence..."
sudo systemctl enable --now mysql

echo "Creating application database: $DATABASE_NAME"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"

# Phase 3: Security Context Configuration
echo "Establishing application security group: $GROUP_NAME"
sudo groupadd -f $GROUP_NAME

echo "Configuring application service account: $USER_NAME"
sudo useradd -m -g $GROUP_NAME -s /bin/bash $USER_NAME || echo "Service account already exists, using existing account"

# Phase 4: Application Deployment
echo "Preparing deployment workspace..."
sudo mkdir -p /tmp/app && sudo chmod 755 /tmp/app
cp "$APP_ZIP" /tmp/app/webapp.zip

echo "Deploying application artifacts to $APP_DIRECTORY..."
sudo mkdir -p $APP_DIRECTORY
sudo unzip -o /tmp/app/webapp.zip -d $APP_DIRECTORY

echo "Configuring application file ownership and permissions..."
sudo chown -R $USER_NAME:$GROUP_NAME $APP_DIRECTORY
sudo chmod -R 750 $APP_DIRECTORY

echo "Deployment completed successfully."
echo "Application location: $APP_DIRECTORY"
echo "Database: $DATABASE_NAME"
echo "Service account: $USER_NAME"