#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_DIR="$HOME/.local/bin"
ALACRITTY_REPO="alacritty/alacritty"
ALACRITTY_BIN_NAME="alacritty"
ALACRITTY_VERSION="0.17.0"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to install a package using apt
install_apt_package() {
	local package_name="$1"
	if ! dpkg -s "$package_name" >/dev/null 2>&1; then
		echo "Installing $package_name..."
		sudo apt update
		sudo apt install -y "$package_name"
	else
		echo "$package_name is already installed."
	fi
}

# --- Main Script ---

echo "--- Alacritty Installation Script ---"

# 1. Check if Alacritty is already installed
if command_exists "$ALACRITTY_BIN_NAME"; then
	echo "Alacritty is already installed:"
	"$ALACRITTY_BIN_NAME" --version
	echo "Exiting."
	exit 0
fi

echo "Alacritty not found. Attempting to install..."

# 2. Attempt to install via package managers

# Check for apt (Debian/Ubuntu)
if command_exists apt; then
	echo "Detected apt. Attempting to install Alacritty via apt repository..."
	install_apt_package "alacritty"
	if command_exists "$ALACRITTY_BIN_NAME"; then
		echo "Alacritty installed successfully via apt."
		"$ALACRITTY_BIN_NAME" --version
		echo "--- Alacritty Installation Complete ---"
		exit 0
	else
		echo "Alacritty not found after apt installation attempt. Trying other methods."
	fi
fi

# Try installing from GitHub Releases as a fallback for newer versions or if not in apt
echo "Attempting to install Alacritty from GitHub releases..."
ALACRITTY_ARCH=$(uname -m)
case "$ALACRITTY_ARCH" in
x86_64) ALACRITTY_ARCH="x86_64" ;;
aarch64) ALACRITTY_ARCH="aarch64" ;;
arm64) ALACRITTY_ARCH="aarch64" ;; # macOS M1/M2 often reports arm64
*) echo "Unsupported architecture: $ALACRITTY_ARCH. Please install Alacritty manually." && exit 1 ;;
esac

# Alacritty typically provides a single binary in the release
DOWNLOAD_URL="https://github.com/$ALACRITTY_REPO/releases/download/v$ALACRITTY_VERSION/alacritty-linux-$ALACRITTY_ARCH"
DOWNLOAD_FILE="/tmp/alacritty-$ALACRITTY_VERSION-$ALACRITTY_ARCH"

echo "Downloading Alacritty v$ALACRITTY_VERSION for Linux-$ALACRITTY_ARCH from $DOWNLOAD_URL"
if curl -L "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE"; then
	mkdir -p "$INSTALL_DIR"
	mv "$DOWNLOAD_FILE" "$INSTALL_DIR/alacritty"
	chmod +x "$INSTALL_DIR/alacritty"

	echo "Cleaning up temporary files..."
	# The downloaded file was moved, so nothing to remove from /tmp directly

	# Verify installation
	echo "Verifying Alacritty installation..."
	if command_exists "$ALACRITTY_BIN_NAME"; then
		echo "Alacritty installed successfully from GitHub release:"
		"$ALACRITTY_BIN_NAME" --version
		echo "--- Alacritty Installation Complete ---"
		exit 0
	else
		echo "ERROR: Alacritty was downloaded but not found in PATH after installation attempt."
		echo "Please ensure '$INSTALL_DIR' is in your system's PATH."
		echo "You might need to add 'export PATH=\"$INSTALL_DIR:\$PATH\"' to your shell's config (e.g., .bashrc, .zshrc) and then 'source' it."
		exit 1
	fi
else
	echo "ERROR: Failed to download Alacritty from GitHub releases."
	echo "Please try installing Alacritty manually or check the version number."
	exit 1
fi

echo "--- Alacritty Installation Complete ---"
