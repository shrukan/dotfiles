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

# Function to uninstall alacritty installed via snap
uninstall_snap_package() {
	local package_name="$1"
	if command_exists snap && snap list | grep -q "^$package_name "; then
		echo "Uninstalling $package_name via snap..."
		sudo snap remove "$package_name"
	else
		echo "$package_name is not installed via snap."
	fi
}

# Function to uninstall alacritty installed via dnf
uninstall_dnf_package() {
	if command_exists dnf; then
		echo "Removing alacritty via dnf..."
		sudo dnf remove -y alacritty
	else
		echo "dnf not found, skipping dnf uninstall."
	fi
}

# --- Main Script ---

# Handle --uninstall flag
if [[ "$1" == "--uninstall" ]]; then
	echo "--- Alacritty Uninstallation Script ---"
	uninstall_snap_package "$ALACRITTY_SNAP_NAME"
	uninstall_dnf_package
	echo "--- Alacritty Uninstallation Complete ---"
	exit 0
fi

echo "--- Alacritty Installation Script ---"

# 1. Check if Alacritty is already installed (via snap)
if command_exists "$ALACRITTY_BIN_NAME"; then
	if snap list | grep -q "^$ALACRITTY_SNAP_NAME "; then
		echo "Alacritty (Snap version) is already installed:"
		"$ALACRITTY_BIN_NAME" --version
		echo "Exiting."
		exit 0
	else
		echo "Alacritty binary found, but not installed via Snap. Proceeding with native installation."
	fi
fi

echo "Alacritty not found or not a Snap install. Attempting to install..."

# 2. Try Fedora/RHEL (dnf)
if command_exists dnf; then
	echo "Installing Alacritty via dnf..."
	sudo dnf install -y alacritty
# 3. Try Debian/Ubuntu (snap)
elif command_exists apt; then
	# Install Snap if not present (common for Debian/Ubuntu derivatives)
	if ! command_exists snap; then
		echo "Snap not found. Attempting to install snapd..."
		sudo apt update
		sudo apt install -y snapd
		sudo snap install core # Install snap core for basic functionality
	else
		echo "Snapd installed. Please log out and back in, then re-run this script if you encounter issues."
	fi

	# Install Alacritty via Snap
	echo "Installing Alacritty via Snap..."
	sudo snap install "$ALACRITTY_SNAP_NAME" --classic # --classic is often needed for terminal emulators

	# Give it a moment for the binary to appear in PATH sometimes
	sleep 2
fi

# 4. Verify installation
echo "Verifying Alacritty installation..."
if command_exists "$ALACRITTY_BIN_NAME"; then
	echo "Alacritty installed successfully:"
	"$ALACRITTY_BIN_NAME" --version
	echo "NOTE: You may need to restart your shell for Alacritty to be found in PATH and for autocompletion to fully work."
else
	echo "ERROR: Alacritty appears to be installed, but the '$ALACRITTY_BIN_NAME' command is not found."
	echo "Try restarting your shell."
	exit 1
fi

echo "--- Alacritty Installation Complete ---"
