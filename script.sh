#!/bin/bash

# Configuration Variables
# ====================================================
DATABASE_NAME="local"           # The name of the database to be created and used by the application
GROUP_NAME="csye6225"           # The Linux group for managing application resources and permissions
USER_NAME="csye6225"            # The user that will run the application and belong to the application group
APP_ZIP="./webapp.zip"          # Path to the application archive on the local machine
APP_DIRECTORY="/opt/csye6225"   # Directory on the local server where the application will be deployed

# Core Functions
# ====================================================

# Update system packages to ensure we have the latest versions
update_system_packages() {
  echo "Starting system update..."
  sudo apt update && sudo apt upgrade -y
}

# Check if 'unzip' is installed and install it if necessary
validate_unzip_package() {
  echo "Validating unzip installation..."
  if ! command -v unzip &> /dev/null; then
    echo "Installing unzip package..."
    sudo apt update -y
    sudo apt install unzip -y
  else
    echo "Unzip package already installed"
  fi
}

# Install and configure the MySQL database server
setup_database() {
  echo "Beginning MySQL installation..."
  sudo apt install mysql-server -y
  
  echo "Configuring MySQL service..."
  sudo systemctl enable --now mysql
  
  echo "Initializing database: $DATABASE_NAME..."
  sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
}

# Create the necessary user and group for the application
configure_system_users() {
  echo "Setting up group: $GROUP_NAME..."
  sudo groupadd -f $GROUP_NAME
  
  echo "Creating system user: $USER_NAME..."
  sudo useradd -m -g $GROUP_NAME -s /bin/bash $USER_NAME || echo "User $USER_NAME exists"
}

# Deploy the application files to the server
deploy_application() {
  echo "Preparing application files..."
  sudo mkdir -p /tmp/app && sudo chmod 755 /tmp/app
  cp "$APP_ZIP" /tmp/app/webapp.zip
  
  echo "Deploying application..."
  sudo mkdir -p $APP_DIRECTORY
  sudo unzip -o /tmp/app/webapp.zip -d $APP_DIRECTORY
  
  echo "Setting permissions..."
  sudo chown -R $USER_NAME:$GROUP_NAME $APP_DIRECTORY
  sudo chmod -R 750 $APP_DIRECTORY
}

# Main Execution
# ====================================================
main() {
  update_system_packages
  validate_unzip_package
  setup_database
  configure_system_users
  deploy_application
  
  echo "Deployment completed successfully!"
}

# Execute the main function
main