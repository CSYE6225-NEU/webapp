#!/bin/bash

# Setup automation for web application deployment
# Handles user creation, app configuration,
# and service initialization for continuous operation

# Creates dedicated application user account
create_system_user() {
    echo "Setting up system user for application..."
    sudo groupadd -f csye6225
    sudo useradd -r -M -g csye6225 -s /usr/sbin/nologin csye6225
}

# Prepares system with required packages
install_dependencies() {
    echo "Refreshing package lists and installing required software..."
    sudo apt-get update -y
    # No longer installing MySQL as we're using RDS
    # Install any other dependencies needed
    sudo apt-get install -y awscli
}

# Deploys application components
setup_application() {
    echo "Preparing application environment..."
    sudo mkdir -p /opt/csye6225
    sudo mv /tmp/webapp /opt/csye6225/webapp
    sudo chmod +x /opt/csye6225/webapp
}

# Creates systemd service file
create_systemd_service() {
    echo "Creating systemd service file..."
    cat <<EOF | sudo tee /etc/systemd/system/webapp.service > /dev/null
[Unit]
Description=CSYE6225 Web Application
After=network.target

[Service]
Type=simple
User=csye6225
Group=csye6225
WorkingDirectory=/opt/csye6225
EnvironmentFile=/opt/csye6225/.env
ExecStart=/opt/csye6225/webapp
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# Sets runtime configuration parameters
create_placeholder_env_file() {
    echo "Generating placeholder configuration parameters..."
    # This will be replaced with actual values by user data on instance boot
    cat <<EOF | sudo tee /opt/csye6225/.env > /dev/null
DB_HOST=placeholder_db_host
DB_PORT=3306
DB_USER=placeholder_db_user
DB_PASSWORD=placeholder_db_password
DB_NAME=placeholder_db_name
S3_BUCKET_NAME=placeholder_bucket_name
PORT=8080
EOF

    # Restrict access to sensitive configuration data
    sudo chmod 600 /opt/csye6225/.env
}

# Establishes security controls
set_permissions() {
    echo "Applying security permissions..."
    sudo chown -R csye6225:csye6225 /opt/csye6225
    sudo chmod -R 750 /opt/csye6225
}

# Configures application for automatic operation
setup_systemd_service() {
    echo "Registering application as system service..."
    sudo chmod 644 /etc/systemd/system/webapp.service

    # Reload systemd, enable and start the webapp service
    echo "Activating automatic startup configuration..."
    sudo systemctl daemon-reload
    sudo systemctl enable webapp.service
    # Don't start the service now - it will start on boot with correct config
}

# Orchestrates deployment sequence
main() {
    create_system_user
    install_dependencies
    setup_application
    create_systemd_service
    create_placeholder_env_file
    set_permissions
    setup_systemd_service
    echo "Deployment successfully completed!"
}

# Execute the main function
main