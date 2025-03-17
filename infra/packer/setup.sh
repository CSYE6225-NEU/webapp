#!/bin/bash

# Setup automation for web application deployment
# Handles user creation, MySQL installation, app configuration,
# and service initialization for continuous operation

# Define MySQL root password
MYSQL_ROOT_PASSWORD="Dark0vader#Mysql"

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
    sudo apt-get install -y mysql-server
}

# Initializes database service
configure_mysql() {
    echo "Configuring database service startup..."
    sudo systemctl enable mysql
    sudo systemctl start mysql
}

# Applies database hardening measures
secure_mysql() {
    echo "Applying database security measures..."
    sudo mysql <<EOF
    ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '$MYSQL_ROOT_PASSWORD';
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
EOF
}

# Deploys application components
setup_application() {
    echo "Preparing application environment..."
    sudo mkdir -p /opt/myapp
    sudo mv /tmp/webapp /opt/myapp/webapp
    sudo chmod +x /opt/myapp/webapp
}

# Sets runtime configuration parameters
create_env_file() {
    echo "Generating configuration parameters..."
    cat <<EOF | sudo tee /opt/myapp/.env > /dev/null
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
MYSQL_ROOT_PASSWORD='Dark0vader#Mysql'
DB_NAME=health_check
PORT=8080
EOF

    # Restrict access to sensitive configuration data
    sudo chmod 600 /opt/myapp/.env
}

# Establishes security controls
set_permissions() {
    echo "Applying security permissions..."
    sudo chown -R csye6225:csye6225 /opt/myapp
    sudo chmod -R 750 /opt/myapp
}

# Configures application for automatic operation
setup_systemd_service() {
    echo "Registering application as system service..."
    sudo mv /tmp/webapp.service /etc/systemd/system/webapp.service
    sudo chmod 644 /etc/systemd/system/webapp.service

    # Reload systemd, enable and start the webapp service
    echo "Activating automatic startup configuration..."
    sudo systemctl daemon-reload
    sudo systemctl enable webapp
    sudo systemctl start webapp
}

# Orchestrates deployment sequence
main() {
    create_system_user
    install_dependencies
    configure_mysql
    secure_mysql
    setup_application
    create_env_file
    set_permissions
    setup_systemd_service
    echo "Deployment successfully completed!"
}

# Execute the main function
main