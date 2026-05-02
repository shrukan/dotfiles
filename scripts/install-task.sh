#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_DIR="$HOME/.local/bin"
TASK_REPO="go-task/task"
TASK_BIN_NAME="task"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to run a command as sudo if not root
run_as_sudo() {
	if [ "$(id -u)" -ne 0 ]; then
		sudo "$@"
	else
		"$@"
	fi
}

# --- Main Script ---

echo "--- Task Installation Script ---"

# 1. Check if Task is already installed
if command_exists "$TASK_BIN_NAME"; then
	echo "Task is already installed:"
	"$TASK_BIN_NAME" --version
	echo "Exiting."
	exit 0
fi

echo "Task not found. Attempting to install..."

# 2. Check for 'curl' and 'tar' (needed for download and extraction)
if ! command_exists curl; then
	echo "ERROR: 'curl' is required to download Task but is not installed."
	echo "Please install 'curl' (e.g., 'sudo apt-get install curl' or 'sudo dnf install curl') and try again."
	exit 1
fi
if ! command_exists tar; then
	echo "ERROR: 'tar' is required to extract Task but is not installed."
	echo "Please install 'tar' (e.g., 'sudo apt-get install tar' or 'sudo dnf install tar') and try again."
	exit 1
fi

# 3. Determine OS and Architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
Linux)
	OS_ID="linux"
	;;
Darwin)
	OS_ID="darwin"
	;;
*)
	echo "ERROR: Unsupported operating system: $OS"
	exit 1
	;;
esac

case "$ARCH" in
x86_64)
	ARCH_ID="amd64"
	;;
arm64 | aarch64)
	ARCH_ID="arm64"
	;;
*)
	echo "ERROR: Unsupported architecture: $ARCH"
	exit 1
	;;
esac

# 4. Get the latest stable release tag from GitHub API
echo "Fetching latest Task release information..."
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${TASK_REPO}/releases/latest" | grep -oP '"tag_name": "\K[^"]+')
if [ -z "$LATEST_TAG" ]; then
	echo "ERROR: Could not determine the latest Task release tag."
	exit 1
fi
echo "Latest Task version found: $LATEST_TAG"

# 5. Construct the download URL
DOWNLOAD_URL="https://github.com/${TASK_REPO}/releases/download/${LATEST_TAG}/task_${OS_ID}_${ARCH_ID}.tar.gz"
echo "Attempting to download from: $DOWNLOAD_URL"

# 6. Download and Extract
# Create a temporary directory for download
TEMP_DIR=$(mktemp -d)
echo "Downloading Task to $TEMP_DIR..."
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/task.tar.gz"; then
	echo "ERROR: Failed to download Task from $DOWNLOAD_URL."
	echo "This might be due to an unsupported OS/ARCH combination for this release, or a network issue."
	rm -rf "$TEMP_DIR"
	exit 1
fi

echo "Extracting Task..."
if ! tar -xzf "$TEMP_DIR/task.tar.gz" -C "$TEMP_DIR"; then
	echo "ERROR: Failed to extract Task archive."
	rm -rf "$TEMP_DIR"
	exit 1
fi

# 7. Install to INSTALL_DIR
echo "Installing Task binary to $INSTALL_DIR..."
run_as_sudo mkdir -p "$INSTALL_DIR"
run_as_sudo mv "$TEMP_DIR/$TASK_BIN_NAME" "$INSTALL_DIR/$TASK_BIN_NAME"
run_as_sudo chmod +x "$INSTALL_DIR/$TASK_BIN_NAME"

# 8. Clean up temporary directory
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# 9. Verify installation
echo "Verifying Task installation..."
if command_exists "$TASK_BIN_NAME"; then
	echo "Task installed successfully:"
	"$TASK_BIN_NAME" --version
else
	echo "ERROR: Task appears to be installed, but it's not found in PATH."
	echo "Please ensure '$INSTALL_DIR' is in your system's PATH."
	echo "You might need to add 'export PATH=\"$INSTALL_DIR:\$PATH\"' to your shell's config (e.g., .bashrc, .zshrc) and then 'source' it."
	exit 1
fi

echo "--- Task Installation Complete ---"
