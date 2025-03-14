#!/bin/bash

# Purpose: Setup script for webapp deployment with MySQL database
# This script creates a system user, installs MySQL, configures the application,
# and sets up a systemd service to run the webapp

# Define MySQL root password
MYSQL_ROOT_PASSWORD="Dark0vader#Mysql"

# Create a non-login system user for running the application
# Using a dedicated user with no login shell improves security
echo "Creating non-login user csye6225..."
sudo groupadd -f csye6225
sudo useradd -r -M -g csye6225 -s /usr/sbin/nologin csye6225

# Update package lists and install MySQL server
echo "Updating system and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y mysql-server

# Configure MySQL to start on boot and start it now
echo "Setting up MySQL..."
sudo systemctl enable mysql
sudo systemctl start mysql

# Function to secure the MySQL installation
# - Sets root password
# - Removes anonymous users
# - Removes test database
secure_mysql() {
  echo "Securing MySQL installation..."
  sudo mysql <<EOF
  ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_ROOT_PASSWORD';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
EOF
}

# Call the secure_mysql function
secure_mysql

# Create application directory and move the webapp binary into place
echo "Creating application directory..."
sudo mkdir -p /opt/myapp
sudo mv /tmp/webapp /opt/myapp/webapp
sudo chmod +x /opt/myapp/webapp

# Create environment file with database connection details
# This keeps sensitive information out of the application code
echo "Creating .env file..."
cat <<EOF | sudo tee /opt/myapp/.env > /dev/null
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
MYSQL_ROOT_PASSWORD='Dark0vader#Mysql'
DB_NAME=health_check
PORT=8080
EOF

# Secure the environment file to prevent unauthorized access
sudo chmod 600 /opt/myapp/.env

# Set proper ownership and permissions for application files
# This ensures the application can be executed by the csye6225 user
echo "Setting ownership of application files..."
sudo chown -R csye6225:csye6225 /opt/myapp
sudo chmod -R 750 /opt/myapp

# Set up systemd service for the application
# This allows the app to run as a service and start on boot
echo "Setting up systemd service..."
sudo mv /tmp/webapp.service /etc/systemd/system/webapp.service
sudo chmod 644 /etc/systemd/system/webapp.service

# Reload systemd, enable and start the webapp service
echo "Reloading systemd and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable webapp
sudo systemctl start webapp

echo "Setup complete!"
