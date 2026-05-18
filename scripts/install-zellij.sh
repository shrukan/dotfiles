#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_DIR="$HOME/.local/bin"
ZELLIJ_BIN_NAME="zellij"
ZELLIJ_VERSION="0.44.3"
ZELLIJ_REPO="zellij-org/zellij"

# Autocompletion directories
BASH_COMPLETION_DIR="/etc/bash_completion.d"
ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"

# --- Functions ---

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Function to setup Zellij autocompletion
setup_zellij_autocompletion() {
	echo "Setting up autocompletion for Zellij..."

	# Zellij generates its completion scripts directly
	# Ensure Zellij binary is in PATH for its completion command to work
	export PATH="$INSTALL_DIR:$PATH"

	# Bash completion
	if command_exists bash && [ -d "$BASH_COMPLETION_DIR" ]; then
		echo "  - Installing Bash completion for 'zellij' to $BASH_COMPLETION_DIR..."
		"$ZELLIJ_BIN_NAME" setup --generate-completion bash | sudo tee "$BASH_COMPLETION_DIR/$ZELLIJ_BIN_NAME" >/dev/null
		echo "    Bash completion installed. You might need to restart your shell or run 'source /etc/bash_completion'."
	elif command_exists bash; then
		echo "  - WARNING: Bash completion directory $BASH_COMPLETION_DIR not found. Manual setup advised."
		echo "    To install manually: '$INSTALL_DIR/$ZELLIJ_BIN_NAME setup --generate-completion bash > ~/.bash_completion/zellij' and source it in your .bashrc."
	fi

	# Zsh completion
	if command_exists zsh && [ -d "$ZSH_COMPLETION_DIR" ]; then
		echo "  - Installing Zsh completion for 'zellij' to $ZSH_COMPLETION_DIR..."
		"$ZELLIJ_BIN_NAME" setup --generate-completion zsh | sudo tee "$ZSH_COMPLETION_DIR/_$ZELLIJ_BIN_NAME" >/dev/null
		echo "    Zsh completion installed. Make sure '$ZSH_COMPLETION_DIR' is in your \$fpath and you run 'compinit'."
	elif command_exists zsh; then
		echo "  - WARNING: Zsh completion directory $ZSH_COMPLETION_DIR not found. Manual setup advised."
		echo "    To install manually: '$INSTALL_DIR/$ZELLIJ_BIN_NAME setup --generate-completion zsh > ~/.zsh/completion/_zellij' and source it or add to fpath."
	fi
}

# Function to remove Zellij autocompletion
remove_zellij_autocompletion() {
	echo "Removing autocompletion files for Zellij..."

	if [ -f "$BASH_COMPLETION_DIR/$ZELLIJ_BIN_NAME" ]; then
		sudo rm -f "$BASH_COMPLETION_DIR/$ZELLIJ_BIN_NAME"
		echo "  - Removed Bash completion for zellij."
	fi

	if [ -f "$ZSH_COMPLETION_DIR/_$ZELLIJ_BIN_NAME" ]; then
		sudo rm -f "$ZSH_COMPLETION_DIR/_$ZELLIJ_BIN_NAME"
		echo "  - Removed Zsh completion for zellij."
	fi
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
	remove_zellij_autocompletion # Remove completion scripts too
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
	setup_zellij_autocompletion # Ensure completion is set up even if already installed
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
# Check release assets for exact target name. Alternatives like "unknown-linux-gnu" exist.

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

	# 3. Setup autocompletion after binary is installed
	setup_zellij_autocompletion

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
