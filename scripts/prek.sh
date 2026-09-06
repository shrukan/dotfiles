#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_DIR="$HOME/.local/bin"
PREK_INSTALL_SCRIPT_URL="https://github.com/j178/prek/releases/download"
PREK_VERSION="0.3.11"
PREK_BIN_NAME="prek"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# --- Main Script ---

# Handle --uninstall flag
if [[ "$1" == "--uninstall" ]]; then
	echo "--- Prek Uninstallation Script ---"

	if [ -f "$INSTALL_DIR/$PREK_BIN_NAME" ]; then
		rm -f "$INSTALL_DIR/$PREK_BIN_NAME"
		echo "Removed $INSTALL_DIR/$PREK_BIN_NAME"
	else
		echo "Prek binary not found in $INSTALL_DIR."
	fi

	echo "--- Prek Uninstallation Complete ---"
	exit 0
fi

echo "--- Prek Installation Script ---"

# 1. Check if prek is already installed
if command_exists "$PREK_BIN_NAME"; then
	echo "Prek is already installed:"
	"$PREK_BIN_NAME" --version
	echo "Exiting."
	exit 0
fi

echo "Prek not found. Attempting to install..."

# 2. Attempt to install prek using its official script
echo "Downloading and running the official prek installation script..."
if ! curl --proto '=https' --tlsv1.2 -LsSf "$PREK_INSTALL_SCRIPT_URL"/v"$PREK_VERSION"/prek-installer.sh | sh -s -- -b "$INSTALL_DIR"; then
	echo "ERROR: Failed to download or execute the prek installation script."
	echo "Please check your internet connection or try installing manually from $PREK_INSTALL_SCRIPT_URL"
	exit 1
fi

# 3. Verify installation
echo "Verifying prek installation..."
if command_exists "$PREK_BIN_NAME"; then
	echo "Prek installed successfully:"
	"$PREK_BIN_NAME" --version
else
	echo "ERROR: Prek appears to be installed, but it's not found in PATH."
	echo "Please ensure '$INSTALL_DIR' is in your system's PATH."
	echo "You might need to add 'export PATH=\"$INSTALL_DIR:\$PATH\"' to your shell's config (e.g., .bashrc, .zshrc) and then 'source' it."
	exit 1
fi

echo "--- Prek Installation Complete ---"
