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
    sudo apt-get install -y unzip jq

# Install AWS CLI for S3 access if not already installed
    if ! command -v aws &> /dev/null; then
        echo "Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf awscliv2.zip aws
    fi

# Verify AWS CLI installation
    aws --version
}

# Deploys application components
setup_application() {
    echo "Preparing application environment..."
    sudo mkdir -p /opt/csye6225
    sudo mv /tmp/webapp /opt/csye6225/webapp
    sudo chmod +x /opt/csye6225/webapp
}

# Sets runtime configuration parameters
create_placeholder_env_file() {
    echo "Generating placeholder configuration parameters..."
    # This will be replaced with actual values by user data on instance boot
    cat <<EOF | sudo tee /opt/csye6225/.env > /dev/null
DB_HOST=placeholder_db_host
DB_PORT=3306
DB_USER=csye6225
DB_PASSWORD=placeholder_db_password
DB_NAME=csye6225
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
    sudo mv /tmp/webapp.service /etc/systemd/system/webapp.service
    sudo chmod 644 /etc/systemd/system/webapp.service

    # Reload systemd and enable the webapp service for automatic startup
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
    create_placeholder_env_file
    set_permissions
    setup_systemd_service
    echo "Deployment successfully completed!"
}

# Execute the main function
main