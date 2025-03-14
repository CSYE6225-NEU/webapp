#!/bin/bash
# WebApp Deployment and Configuration Script
#
# This script performs a comprehensive setup of a Node.js web application with MySQL:
# - Creates dedicated system account with appropriate security restrictions
# - Installs and hardens MySQL database server
# - Configures application environment and permissions
# - Establishes systemd service for application management

# Database authentication credentials
MYSQL_ROOT_PASSWORD="Dark0vader#Mysql"

# Phase 1: System Account Configuration
echo "Configuring application service account..."
sudo groupadd -f csye6225
sudo useradd -r -M -g csye6225 -s /usr/sbin/nologin csye6225

# Phase 2: System Dependencies
echo "Updating package repositories and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y mysql-server

# Phase 3: Database Configuration
echo "Initializing MySQL database service..."
sudo systemctl enable mysql
sudo systemctl start mysql

# MySQL security hardening function
secure_mysql() {
  echo "Applying database security hardening measures..."
  sudo mysql <<EOF
 ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_ROOT_PASSWORD';
 DELETE FROM mysql.user WHERE User='';
 DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
 FLUSH PRIVILEGES;
EOF
}

# Execute database security configuration
secure_mysql

# Phase 4: Application Deployment
echo "Preparing application runtime environment..."
sudo mkdir -p /opt/myapp
sudo mv /tmp/webapp /opt/myapp/webapp
sudo chmod +x /opt/myapp/webapp

# Create application configuration with database connection parameters
echo "Generating application configuration..."
cat <<EOF | sudo tee /opt/myapp/.env > /dev/null
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
MYSQL_ROOT_PASSWORD='Dark0vader#Mysql'
DB_NAME=health_check
PORT=8080
EOF

# Secure configuration file with restricted permissions
sudo chmod 600 /opt/myapp/.env

# Set appropriate ownership and access permissions
echo "Configuring application file permissions..."
sudo chown -R csye6225:csye6225 /opt/myapp
sudo chmod -R 750 /opt/myapp

# Phase 5: Service Configuration
echo "Establishing application service..."
sudo mv /tmp/webapp.service /etc/systemd/system/webapp.service
sudo chmod 644 /etc/systemd/system/webapp.service

# Initialize service management
echo "Activating application service..."
sudo systemctl daemon-reload
sudo systemctl enable webapp
sudo systemctl start webapp

echo "Deployment completed successfully. Application is now running."