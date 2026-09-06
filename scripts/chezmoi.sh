#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_DIR="$HOME/.local/bin"
CHEZMOI_INSTALL_SCRIPT_URL="https://get.chezmoi.io"
CHEZMOI_BIN_NAME="chezmoi"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# --- Main Script ---

# Handle --uninstall flag
if [[ "$1" == "--uninstall" ]]; then
	echo "--- Chezmoi Uninstallation Script ---"

	# 1. Remove binary
	if [ -f "$INSTALL_DIR/$CHEZMOI_BIN_NAME" ]; then
		rm -f "$INSTALL_DIR/$CHEZMOI_BIN_NAME"
		echo "Removed $INSTALL_DIR/$CHEZMOI_BIN_NAME"
	else
		echo "Chezmoi binary not found in $INSTALL_DIR."
	fi

	echo "--- Chezmoi Uninstallation Complete ---"
	exit 0
fi

echo "--- Chezmoi Installation Script ---"

# 1. Check if chezmoi is already installed
if command_exists "$CHEZMOI_BIN_NAME"; then
	echo "Chezmoi is already installed:"
	"$CHEZMOI_BIN_NAME" --version
	echo "Exiting."
	exit 0
fi

echo "Chezmoi not found. Attempting to install..."

# 2. Attempt to install chezmoi using its official script
echo "Downloading and running the official chezmoi installation script..."
if ! curl -fsLS "$CHEZMOI_INSTALL_SCRIPT_URL" | sh -s -- -b "$INSTALL_DIR"; then
	echo "ERROR: Failed to download or execute the chezmoi installation script."
	echo "Please check your internet connection or try installing manually from $CHEZMOI_INSTALL_SCRIPT_URL"
	exit 1
fi

# 3. Verify installation
echo "Verifying chezmoi installation..."
if command_exists "$CHEZMOI_BIN_NAME"; then
	echo "Chezmoi installed successfully:"
	"$CHEZMOI_BIN_NAME" --version
else
	echo "ERROR: Chezmoi appears to be installed, but it's not found in PATH."
	echo "Please ensure '$INSTALL_DIR' is in your system's PATH."
	echo "You might need to add 'export PATH=\"$INSTALL_DIR:\$PATH\"' to your shell's config (e.g., .bashrc, .zshrc) and then 'source' it."
	exit 1
fi

echo "--- Chezmoi Installation Complete ---"
