#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_DIR="$HOME/.local/bin"
TASK_BIN_NAME="task"
TASK_REPO="go-task/task"
TASK_VERSION="3.50.0"

# Autocompletion directories
# For bash, typically /etc/bash_completion.d/ or ~/.bash_completion (if sourced)
# For zsh, typically /usr/local/share/zsh/site-functions/ or ~/.zsh/completion/
BASH_COMPLETION_DIR="/etc/bash_completion.d"
ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to setup autocompletion
setup_autocompletion() {
	echo "Setting up autocompletion for Task..."

	# Bash completion
	if command_exists bash && [ -d "$BASH_COMPLETION_DIR" ]; then
		echo "  - Installing Bash completion to $BASH_COMPLETION_DIR..."
		"$TASK_BIN_NAME" --completion bash | sudo tee "$BASH_COMPLETION_DIR/$TASK_BIN_NAME" >/dev/null
		echo "    Bash completion installed. You might need to restart your shell or run 'source /etc/bash_completion' (if not automatically sourced)."
	elif command_exists bash; then
		echo "  - WARNING: Bash completion directory $BASH_COMPLETION_DIR not found. You might need to set it up manually."
		echo "    To install manually: '$INSTALL_DIR/$TASK_BIN_NAME completion bash > ~/.bash_completion' and source it in your .bashrc."
	fi

	# Zsh completion
	if command_exists zsh && [ -d "$ZSH_COMPLETION_DIR" ]; then
		echo "  - Installing Zsh completion to $ZSH_COMPLETION_DIR..."
		"$TASK_BIN_NAME" --completion zsh | sudo tee "$ZSH_COMPLETION_DIR/$TASK_BIN_NAME" >/dev/null
		echo "    Zsh completion installed. Make sure '$ZSH_COMPLETION_DIR' is in your \$fpath and you run 'compinit'."
		echo "    If using Oh My Zsh, you might move it to ~/.oh-my-zsh/custom/plugins/task/_task"
	elif command_exists zsh; then
		echo "  - WARNING: Zsh completion directory $ZSH_COMPLETION_DIR not found. You might need to set it up manually."
		echo "    To install manually: '$INSTALL_DIR/$TASK_BIN_NAME completion zsh > ~/.zsh/completion/_task' and source it or add to fpath."
	fi
}

# Function to remove autocompletion
remove_autocompletion() {
	echo "Removing autocompletion for Task..."

	# Bash completion
	if [ -f "$BASH_COMPLETION_DIR/$TASK_BIN_NAME" ]; then
		sudo rm -f "$BASH_COMPLETION_DIR/$TASK_BIN_NAME"
		echo "  - Removed Bash completion file: $BASH_COMPLETION_DIR/$TASK_BIN_NAME"
	fi

	# Zsh completion
	if [ -f "$ZSH_COMPLETION_DIR/_$TASK_BIN_NAME" ]; then
		sudo rm -f "$ZSH_COMPLETION_DIR/_$TASK_BIN_NAME"
		echo "  - Removed Zsh completion file: $ZSH_COMPLETION_DIR/_$TASK_BIN_NAME"
	fi
}

# Function to uninstall Task
uninstall_task() {
	echo "Attempting to remove Task binary..."
	if [ -f "$INSTALL_DIR/$TASK_BIN_NAME" ]; then
		rm -f "$INSTALL_DIR/$TASK_BIN_NAME"
		echo "Removed Task binary: $INSTALL_DIR/$TASK_BIN_NAME"
	else
		echo "Task binary not found in $INSTALL_DIR."
	fi
	remove_autocompletion # Also remove completion scripts during uninstall
	echo "Task uninstallation attempt complete."
}

# --- Main Script ---

# Check for uninstall argument
if [[ "$1" == "uninstall" ]]; then
	echo "--- Task Uninstallation Script ---"
	uninstall_task
	echo "--- Task Uninstallation Complete ---"
	exit 0
fi

echo "--- Task Installation Script ---"

# 1. Check if Task is already installed
if command_exists "$TASK_BIN_NAME"; then
	echo "Task is already installed:"
	"$TASK_BIN_NAME" --version
	# Even if installed, ensure autocompletion is set up/updated
	setup_autocompletion
	echo "Exiting."
	exit 0
fi

echo "Task not found. Attempting to install from GitHub release..."

# 2. Determine architecture and download
TASK_ARCH=$(uname -m)
case "$TASK_ARCH" in
x86_64) TASK_ARCH="amd64" ;;
aarch64) TASK_ARCH="arm64" ;;
arm64) TASK_ARCH="arm64" ;;
*) echo "Unsupported architecture: $TASK_ARCH. Please install Task manually." && exit 1 ;;
esac

TASK_OS=$(uname -s | tr '[:upper:]' '[:lower:]')

DOWNLOAD_URL="https://github.com/$TASK_REPO/releases/download/v$TASK_VERSION/${TASK_BIN_NAME}_${TASK_OS}_${TASK_ARCH}.tar.gz"
DOWNLOAD_FILE="/tmp/${TASK_BIN_NAME}_${TASK_VERSION}_${TASK_OS}_${TASK_ARCH}.tar.gz"
EXTRACT_DIR="/tmp/${TASK_BIN_NAME}_install_tmp"

echo "Downloading Task v$TASK_VERSION for $TASK_OS/$TASK_ARCH from $DOWNLOAD_URL"
if curl -fsLS "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE"; then
	mkdir -p "$EXTRACT_DIR"
	tar -xzf "$DOWNLOAD_FILE" -C "$EXTRACT_DIR"

	mkdir -p "$INSTALL_DIR"
	cp "$EXTRACT_DIR/$TASK_BIN_NAME" "$INSTALL_DIR/"
	chmod +x "$INSTALL_DIR/$TASK_BIN_NAME"

	echo "Cleaning up temporary files..."
	rm "$DOWNLOAD_FILE"
	rm -rf "$EXTRACT_DIR"

	echo "Task binary installed to $INSTALL_DIR/$TASK_BIN_NAME"

	# 3. Setup autocompletion after binary is installed
	setup_autocompletion

	# Verify installation
	echo "Verifying Task installation..."
	if command_exists "$TASK_BIN_NAME"; then
		echo "Task installed successfully:"
		"$TASK_BIN_NAME" --version
	else
		echo "ERROR: Task was downloaded but not found in PATH after installation attempt."
		echo "Please ensure '$INSTALL_DIR' is in your system's PATH."
		echo "You might need to add 'export PATH=\"$INSTALL_DIR:\$PATH\"' to your shell's config (e.g., .bashrc, .zshrc) and then 'source' it."
		exit 1
	fi
else
	echo "ERROR: Failed to download Task from GitHub releases. Check URL, version, and internet connection."
	echo "Download URL: $DOWNLOAD_URL"
	exit 1
fi

echo "--- Task Installation Complete ---"
