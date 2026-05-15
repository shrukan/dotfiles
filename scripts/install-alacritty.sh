#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
ALACRITTY_BIN_NAME="alacritty"
ALACRITTY_SNAP_NAME="alacritty"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to uninstall a snap package
uninstall_snap_package() {
	local package_name="$1"
	if command_exists snap && snap list | grep -q "^$package_name "; then
		echo "Uninstalling $package_name via snap..."
		sudo snap remove "$package_name"
	else
		echo "$package_name is not installed via snap."
	fi
}

# --- Main Script ---

# Check for uninstall argument
if [[ "$1" == "uninstall" ]]; then
	echo "--- Alacritty Uninstallation Script ---"
	uninstall_snap_package "$ALACRITTY_SNAP_NAME"
	echo "--- Alacritty Uninstallation Complete ---"
	exit 0
fi

echo "--- Alacritty Installation Script ---"

# 1. Check if Alacritty is already installed (via snap)
if command_exists "$ALACRITTY_BIN_NAME"; then
	if snap list | grep -q "^$ALACRITTY_SNAP_NAME "; then
		echo "Alacritty (Snap version) is already installed:"
		"$ALACRITTY_BIN_NAME" --version
		setup_alacritty_autocompletion # Ensure completion is set up/updated
		echo "Exiting."
		exit 0
	else
		echo "Alacritty binary found, but not installed via Snap. Proceeding with Snap installation."
	fi
fi

echo "Alacritty not found or not a Snap install. Attempting to install via Snap..."

# 2. Install Snap if not present (common for Debian/Ubuntu derivatives)
if ! command_exists snap; then
	echo "Snap not found. Attempting to install snapd..."
	if command_exists apt; then
		sudo apt update
		sudo apt install -y snapd
		sudo snap install core # Install snap core for basic functionality
	else
		echo "ERROR: Snap is not installed and your package manager (apt) is not supported to install it automatically."
		echo "Please install Snap manually for your distribution (https://snapcraft.io/docs/installing-snapd)."
		exit 1
	fi
	echo "Snapd installed. Please log out and back in, then re-run this script if you encounter issues."
fi

# 3. Install Alacritty via Snap
echo "Installing Alacritty via Snap..."
sudo snap install "$ALACRITTY_SNAP_NAME" --classic # --classic is often needed for terminal emulators

# Give it a moment for the binary to appear in PATH sometimes
sleep 2

# 4. Verify installation
echo "Verifying Alacritty installation..."
if command_exists "$ALACRITTY_BIN_NAME"; then
	echo "Alacritty installed successfully via Snap:"
	"$ALACRITTY_BIN_NAME" --version
	echo "NOTE: You may need to restart your shell for Alacritty to be found in PATH and for autocompletion to fully work."
else
	echo "ERROR: Alacritty appears to be installed via Snap, but the '$ALACRITTY_BIN_NAME' command is not found."
	echo "       This can sometimes happen immediately after Snap installation. Try restarting your shell."
	exit 1
fi

echo "--- Alacritty Installation Complete ---"
