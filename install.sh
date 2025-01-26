#!/bin/bash
# install.sh - Automated installer/updater for source-request-simulator

# Variables
REPO_URL="https://raw.githubusercontent.com/deelesisuanu/source-request-simulator/main/simulator.sh"
SCRIPT_NAME="simulator.sh"
INSTALL_DIR="/usr/local/bin"
SERVICE_NAME="source-request-simulator"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Ensure script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use sudo."
   exit 1
fi

# Download or update the script
echo "Downloading the latest version of $SCRIPT_NAME from $REPO_URL..."
curl -o "$INSTALL_DIR/$SCRIPT_NAME" -s $REPO_URL

# Make the script executable
echo "Making $SCRIPT_NAME executable..."
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Check if the service already exists
if [[ -f "$SERVICE_FILE" ]]; then
  echo "Service already exists. Updating and restarting..."
  # Restart the service
  systemctl restart $SERVICE_NAME
else
  echo "Setting up the service for the first time..."

  # Create a systemd service file
  cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Source Request Simulator
After=network.target

[Service]
ExecStart=$INSTALL_DIR/$SCRIPT_NAME
Restart=always
RestartSec=5
User=$(whoami)
Environment=HOME=$(eval echo ~$USER)

[Install]
WantedBy=multi-user.target
EOF

  # Reload systemd, enable and start the service
  echo "Setting up and starting the service..."
  systemctl daemon-reload
  systemctl enable $SERVICE_NAME
  systemctl start $SERVICE_NAME
fi

# Confirm installation or update
echo "$SCRIPT_NAME has been installed or updated and is running as a background service."
echo "You can control it using:"
echo "  systemctl status $SERVICE_NAME  # Check status"
echo "  systemctl stop $SERVICE_NAME    # Stop the service"
echo "  systemctl start $SERVICE_NAME   # Start the service"
echo "  systemctl restart $SERVICE_NAME # Restart the service"
