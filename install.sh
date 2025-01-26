#!/bin/bash
# install.sh - Automated installer for source-request-simulator

# Variables
REPO_URL="https://raw.githubusercontent.com/deelesisuanu/source-request-simulator/main/simulator.sh"
SCRIPT_NAME="simulator.sh"

# Download the script
echo "Downloading $SCRIPT_NAME from $REPO_URL..."
curl -O $REPO_URL

# Make the script executable
echo "Making $SCRIPT_NAME executable..."
chmod +x $SCRIPT_NAME

# Confirm installation
echo "$SCRIPT_NAME has been downloaded and is ready to use."
echo "Run it with: ./$SCRIPT_NAME [options]"
