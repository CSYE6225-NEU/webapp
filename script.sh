#!/bin/bash

# The name of the database to be created and used by the application
DATABASE_NAME="local"
# The Linux group for managing application resources and permissions
GROUP_NAME="csye6225"
# The user that will run the application and belong to the application group
USER_NAME="csye6225"
# Path to the application archive on the local machine
APP_ZIP="./webapp.zip"
# Directory on the local server where the application will be deployed
APP_DIRECTORY="/opt/csye6225"

# Function to check if 'unzip' is installed and install it if necessary
validate_unzip_package() {
    if ! command -v unzip &> /dev/null; then
        echo "Installing unzip package..."
        sudo apt update -y
        sudo apt install unzip -y
    else
        echo "Unzip package already installed"
    fi
}

# Update and upgrade packages to ensure the system is up-to-date
echo "Starting system update..."
sudo apt update && sudo apt upgrade -y

# Check if 'unzip' is installed and install it if needed
echo "Validating unzip installation..."
validate_unzip_package

# Install MySQL server
echo "Beginning MySQL installation..."
sudo apt install mysql-server -y

# Start and enable the MySQL service to run on boot
echo "Configuring MySQL service..."
sudo systemctl enable --now mysql

# Create the specified database
echo "Initializing database: $DATABASE_NAME..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"

# Create a Linux group for managing application permissions
echo "Setting up group: $GROUP_NAME..."
sudo groupadd -f $GROUP_NAME

# Create a user for the application and add it to the application group
echo "Creating system user: $USER_NAME..."
sudo useradd -m -g $GROUP_NAME -s /bin/bash $USER_NAME || echo "User $USER_NAME exists"

# Copy the application archive to the local server's directory
echo "Preparing application files..."
sudo mkdir -p /tmp/app && sudo chmod 755 /tmp/app
cp "$APP_ZIP" /tmp/app/webapp.zip

# Set up the application
echo "Deploying application..."
sudo mkdir -p $APP_DIRECTORY
sudo unzip -o /tmp/app/webapp.zip -d $APP_DIRECTORY
sudo chown -R $USER_NAME:$GROUP_NAME $APP_DIRECTORY
sudo chmod -R 750 $APP_DIRECTORY

# Indicate that the setup process has completed successfully
echo "Deployment completed successfully!"