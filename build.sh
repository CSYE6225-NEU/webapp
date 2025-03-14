#!/bin/bash
#==============================================================================
# Node.js Application Build Script
#
# This script builds and packages the Node.js application into a standalone
# executable binary for Linux x64 environments using pkg.
#==============================================================================

# Color definitions for better visual feedback
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration variables
OUTPUT_DIR="dist"
OUTPUT_BINARY="webapp"
NODE_TARGET="node18-linux-x64"
ENTRY_POINT="server.js"

# Logging function for consistent output
log() {
  local level=$1
  local message=$2
  
  case $level in
    "INFO")    printf "${BLUE}[INFO]${NC} %s\n" "$message" ;;
    "SUCCESS") printf "${GREEN}[SUCCESS]${NC} %s\n" "$message" ;;
    "WARN")    printf "${YELLOW}[WARNING]${NC} %s\n" "$message" ;;
    "ERROR")   printf "${RED}[ERROR]${NC} %s\n" "$message" ;;
    *)         printf "%s\n" "$message" ;;
  esac
}

# Create output directory if it doesn't exist
log "INFO" "Ensuring output directory exists..."
mkdir -p "$OUTPUT_DIR"

# Install dependencies
log "INFO" "Installing project dependencies..."
npm install || { log "ERROR" "Failed to install dependencies"; exit 1; }

# Compile application to binary
log "INFO" "Packaging application as standalone binary..."
log "INFO" "Target: $NODE_TARGET"
pkg "$ENTRY_POINT" --output "$OUTPUT_DIR/$OUTPUT_BINARY" --targets "$NODE_TARGET" || { 
  log "ERROR" "Failed to package application"; 
  exit 1; 
}

# Set executable permissions
log "INFO" "Setting executable permissions..."
chmod +x "$OUTPUT_DIR/$OUTPUT_BINARY" || { 
  log "ERROR" "Failed to set executable permissions"; 
  exit 1; 
}

# Verify binary was created successfully
if [ -f "$OUTPUT_DIR/$OUTPUT_BINARY" ]; then
  BINARY_SIZE=$(du -h "$OUTPUT_DIR/$OUTPUT_BINARY" | cut -f1)
  log "SUCCESS" "=============================================="
  log "SUCCESS" "Build completed successfully!"
  log "SUCCESS" "Binary location: $OUTPUT_DIR/$OUTPUT_BINARY"
  log "SUCCESS" "Binary size: $BINARY_SIZE"
  log "SUCCESS" "=============================================="
else
  log "ERROR" "Build failed: Binary not found"
  exit 1
fi