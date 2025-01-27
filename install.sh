#!/bin/bash
# install.sh - Automated installer/updater for source-request-simulator

# Variables
REPO_URL="https://raw.githubusercontent.com/deelesisuanu/source-request-simulator/main/simulator.sh"
SCRIPT_NAME="simulator.sh"
INSTALL_DIR="/usr/local/bin"
SERVICE_NAME="source-request-simulator"

# Function to resolve the absolute path of the script
get_script_path() {
  if command -v realpath &>/dev/null; then
    realpath "$0"
  else
    readlink -f "$0"
  fi
}

# Ensure script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use sudo."
   exit 1
fi

SCRIPT_PATH=$(get_script_path)

# Detect OS
OS=$(uname -s)
echo "Detected OS: $OS"

# Download or update the script
echo "Downloading the latest version of $SCRIPT_NAME from $REPO_URL..."
curl -o "$INSTALL_DIR/$SCRIPT_NAME" -s $REPO_URL

# Make the script executable
echo "Making $SCRIPT_NAME executable..."
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Initialize instructions variable
INSTRUCTIONS=""

# Configure service based on OS
if [[ "$OS" == "Linux" ]]; then
  # Check for systemd
  if command -v systemctl &>/dev/null; then
    SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
    echo "Setting up systemd service..."

    # Check if the service already exists
    if [[ -f "$SERVICE_FILE" ]]; then
      echo "Service already exists. Updating and restarting..."
      systemctl restart $SERVICE_NAME
    else
      echo "Creating new systemd service..."
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
      systemctl daemon-reload
      systemctl enable $SERVICE_NAME
      systemctl start $SERVICE_NAME
    fi

    # Add instructions for systemd
    INSTRUCTIONS="
To manage the service on your Linux system:
  Start the service:     sudo systemctl start $SERVICE_NAME
  Stop the service:      sudo systemctl stop $SERVICE_NAME
  Restart the service:   sudo systemctl restart $SERVICE_NAME
  Check status:          sudo systemctl status $SERVICE_NAME
  Remove the service:    sudo systemctl disable $SERVICE_NAME && sudo rm -f $SERVICE_FILE && sudo systemctl daemon-reload
"
  else
    echo "Systemd not found. Please configure the service manually."
    exit 1
  fi

elif [[ "$OS" == "Darwin" ]]; then
  # macOS
  PLIST_FILE="$HOME/Library/LaunchAgents/$SERVICE_NAME.plist"
  echo "Setting up launchd service for macOS..."

  # Create the plist file
  cat <<EOF > "$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$SERVICE_NAME</string>
  <key>ProgramArguments</key>
  <array>
    <string>$INSTALL_DIR/$SCRIPT_NAME</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF

  # Load the service
  launchctl unload "$PLIST_FILE" 2>/dev/null || true
  launchctl load "$PLIST_FILE"
  echo "Service $SERVICE_NAME has been set up and started on macOS."

  # Add instructions for macOS
  INSTRUCTIONS="
To manage the service on your macOS system:
  Start the service:     launchctl start $SERVICE_NAME
  Stop the service:      launchctl stop $SERVICE_NAME
  Restart the service:   launchctl unload $PLIST_FILE && launchctl load $PLIST_FILE
  Remove the service:    launchctl unload $PLIST_FILE && rm -f $PLIST_FILE
"
else
  echo "Unsupported operating system: $OS"
  exit 1
fi

# Display management instructions
echo "$INSTRUCTIONS"

# Cleanup: Delete the install script from its current directory
# Remove the install.sh script after installation
if [[ -f "$SCRIPT_PATH" ]]; then
  echo "Cleaning up: Deleting the install script from $(dirname "$SCRIPT_PATH")..."
  rm -f "$SCRIPT_PATH"
fi

# Confirm installation or update
echo "$SCRIPT_NAME has been installed or updated and is running as a background service."
