#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_DIR="$HOME/.local/bin"
ZELLIJ_BIN_NAME="zellij"
ZELLIJ_VERSION="0.44.3"
ZELLIJ_REPO="zellij-org/zellij"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to uninstall Zellij installed from GitHub release
uninstall_from_release() {
	echo "Attempting to remove Zellij installed from GitHub release..."
	if [ -f "$INSTALL_DIR/$ZELLIJ_BIN_NAME" ]; then
		rm -f "$INSTALL_DIR/$ZELLIJ_BIN_NAME"
		echo "Removed binary: $INSTALL_DIR/$ZELLIJ_BIN_NAME"
	else
		echo "Zellij binary not found in $INSTALL_DIR."
	fi
	echo "Zellij uninstallation attempt complete."
}

# --- Main Script ---

# Check for uninstall argument
if [[ "$1" == "uninstall" ]]; then
	echo "--- Zellij Uninstallation Script ---"
	uninstall_from_release
	echo "--- Zellij Uninstallation Complete ---"
	exit 0
fi

echo "--- Zellij Installation Script ---"

# 1. Check if Zellij is already installed
if command_exists "$ZELLIJ_BIN_NAME"; then
	echo "Zellij is already installed:"
	"$ZELLIJ_BIN_NAME" --version
	echo "Exiting."
	exit 0
fi

echo "Zellij not found. Attempting to install from GitHub release..."

# 2. Determine architecture and download
ZELLIJ_ARCH=$(uname -m)
case "$ZELLIJ_ARCH" in
x86_64) ZELLIJ_ARCH="x86_64" ;;
aarch64) ZELLIJ_ARCH="aarch64" ;;
arm64) ZELLIJ_ARCH="aarch64" ;; # macOS M1/M2 often reports arm64, but we're targeting Linux here
*) echo "Unsupported architecture: $ZELLIJ_ARCH. Please install Zellij manually." && exit 1 ;;
esac

# Zellij's releases are typically tar.gz archives containing the binary
ZELLIJ_TARGET="unknown-linux-musl" # Common for many Linux distributions
# If specifically targeting glibc-based systems (e.g., Ubuntu, Fedora), you might use "-gnu" instead of "-musl".
# Check the specific release assets for the exact target name.
# For simplicity and broad compatibility, musl is often chosen for pre-compiled Linux binaries.

DOWNLOAD_URL="https://github.com/$ZELLIJ_REPO/releases/download/v$ZELLIJ_VERSION/zellij-$ZELLIJ_ARCH-$ZELLIJ_TARGET.tar.gz"
DOWNLOAD_FILE="/tmp/zellij-$ZELLIJ_VERSION.tar.gz"
EXTRACT_DIR="/tmp/zellij_install"

echo "Downloading Zellij v$ZELLIJ_VERSION for $ZELLIJ_ARCH-$ZELLIJ_TARGET from $DOWNLOAD_URL"
if curl -fsLS "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE"; then
	mkdir -p "$EXTRACT_DIR"
	tar -xzf "$DOWNLOAD_FILE" -C "$EXTRACT_DIR"

	mkdir -p "$INSTALL_DIR"
	cp "$EXTRACT_DIR/$ZELLIJ_BIN_NAME" "$INSTALL_DIR/"
	chmod +x "$INSTALL_DIR/$ZELLIJ_BIN_NAME"

	echo "Cleaning up temporary files..."
	rm "$DOWNLOAD_FILE"
	rm -rf "$EXTRACT_DIR"

	echo "Zellij binary installed to $INSTALL_DIR/$ZELLIJ_BIN_NAME"

	# Verify installation
	echo "Verifying Zellij installation..."
	if command_exists "$ZELLIJ_BIN_NAME"; then
		echo "Zellij installed successfully from GitHub release:"
		"$ZELLIJ_BIN_NAME" --version
	else
		echo "ERROR: Zellij was downloaded but not found in PATH after installation attempt."
		echo "Please ensure '$INSTALL_DIR' is in your system's PATH."
		echo "You might need to add 'export PATH=\"$INSTALL_DIR:\$PATH\"' to your shell's config (e.g., .bashrc, .zshrc) and then 'source' it."
		exit 1
	fi
else
	echo "ERROR: Failed to download Zellij from GitHub releases. Check URL, version, and internet connection."
	echo "Download URL: $DOWNLOAD_URL"
	exit 1
fi

echo "--- Zellij Installation Complete ---"
