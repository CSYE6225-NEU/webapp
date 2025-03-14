#!/bin/bash

# Configuration Variables
# ====================================================
OUTPUT_PATH="dist/webapp"       # Path where the binary will be created
TARGET_PLATFORM="node18-linux-x64"  # Target platform for the binary
ENTRY_POINT="server.js"         # Main entry point of the application

# Core Functions
# ====================================================

# Install all project dependencies
install_dependencies() {
  echo "Installing dependencies..."
  npm install
}

# Package the application as a standalone binary
create_executable() {
  echo "Building executable binary..."
  pkg $ENTRY_POINT --output $OUTPUT_PATH --targets $TARGET_PLATFORM
}

# Set appropriate permissions on the binary
set_permissions() {
  echo "Setting executable permissions..."
  chmod +x $OUTPUT_PATH
}

# Main Execution
# ====================================================
main() {
  install_dependencies
  create_executable
  set_permissions
  
  echo "Build complete! Binary located at $OUTPUT_PATH"
}

# Execute the main function
main