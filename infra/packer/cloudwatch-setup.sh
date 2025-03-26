#!/bin/bash

# Install CloudWatch Agent
install_cloudwatch_agent() {
    echo "Installing CloudWatch Agent..."
    sudo apt-get update -y
    sudo apt-get install -y wget

    # Download the CloudWatch agent package
    wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

    # Install the package
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

    # Cleanup
    rm ./amazon-cloudwatch-agent.deb
}

# Copy the config file to the proper location
setup_cloudwatch_config() {
    echo "Setting up CloudWatch Agent configuration..."
    sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
    sudo cp /tmp/amazon-cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    sudo chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
}

# Enable CloudWatch agent on startup
enable_cloudwatch_agent() {
    echo "Enabling CloudWatch Agent service..."
    sudo systemctl enable amazon-cloudwatch-agent
}

# Main execution
main() {
    install_cloudwatch_agent
    setup_cloudwatch_config
    enable_cloudwatch_agent
    echo "CloudWatch Agent setup completed successfully!"
}

# Execute main function
main