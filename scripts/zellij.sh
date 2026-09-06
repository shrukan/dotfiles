#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
ZELLIJ_BIN_NAME="zellij"
INSTALL_DIR="$HOME/.local/bin"

# Autocompletion directories
BASH_COMPLETION_DIR="/etc/bash_completion.d"
ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"

# GitHub release
ZELLIJ_VERSION="0.44.3"
ZELLIJ_REPO="zellij-org/zellij"

# --- Functions ---

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

# Setup autocompletion
setup_zellij_autocompletion() {
	echo "Setting up autocompletion for Zellij..."

	export PATH="$INSTALL_DIR:$PATH"

	# Bash completion
	if command_exists bash && [ -d "$BASH_COMPLETION_DIR" ]; then
		echo "  - Installing Bash completion for 'zellij' to $BASH_COMPLETION_DIR..."
		"$ZELLIJ_BIN_NAME" setup --generate-completion bash | run_as_sudo tee "$BASH_COMPLETION_DIR/$ZELLIJ_BIN_NAME" >/dev/null
		echo "    Bash completion installed. You might need to restart your shell or run 'source /etc/bash_completion'."
	elif command_exists bash; then
		echo "  - WARNING: Bash completion directory $BASH_COMPLETION_DIR not found. Manual setup advised."
		echo "    To install manually: '$INSTALL_DIR/$ZELLIJ_BIN_NAME setup --generate-completion bash > ~/.bash_completion/zellij' and source it in your .bashrc."
	fi

	# Zsh completion
	if command_exists zsh && [ -d "$ZSH_COMPLETION_DIR" ]; then
		echo "  - Installing Zsh completion for 'zellij' to $ZSH_COMPLETION_DIR..."
		"$ZELLIJ_BIN_NAME" setup --generate-completion zsh | run_as_sudo tee "$ZSH_COMPLETION_DIR/_$ZELLIJ_BIN_NAME" >/dev/null
		echo "    Zsh completion installed. Make sure '$ZSH_COMPLETION_DIR' is in your \$fpath and you run 'compinit'."
	elif command_exists zsh; then
		echo "  - WARNING: Zsh completion directory $ZSH_COMPLETION_DIR not found. Manual setup advised."
		echo "    To install manually: '$INSTALL_DIR/$ZELLIJ_BIN_NAME setup --generate-completion zsh > ~/.zsh/completion/_zellij' and source it or add to fpath."
	fi
}

# Uninstall autocompletion
remove_zellij_autocompletion() {
	echo "Removing autocompletion files for Zellij..."

	if [ -f "$BASH_COMPLETION_DIR/$ZELLIJ_BIN_NAME" ]; then
		run_as_sudo rm -f "$BASH_COMPLETION_DIR/$ZELLIJ_BIN_NAME"
		echo "  - Removed Bash completion for zellij."
	fi

	if [ -f "$ZSH_COMPLETION_DIR/_$ZELLIJ_BIN_NAME" ]; then
		run_as_sudo rm -f "$ZSH_COMPLETION_DIR/_$ZELLIJ_BIN_NAME"
		echo "  - Removed Zsh completion for zellij."
	fi
}

# Install from GitHub release
install_github_release() {
	echo "Installing Zellij v$ZELLIJ_VERSION from GitHub release..."

	local ZELLIJ_ARCH
	ZELLIJ_ARCH=$(uname -m)
	case "$ZELLIJ_ARCH" in
		x86_64) ZELLIJ_ARCH="x86_64" ;;
		aarch64) ZELLIJ_ARCH="aarch64" ;;
		arm64) ZELLIJ_ARCH="aarch64" ;;
		*) echo "Unsupported architecture: $ZELLIJ_ARCH. Please install Zellij manually." && exit 1 ;;
	esac

	local DOWNLOAD_URL="https://github.com/$ZELLIJ_REPO/releases/download/v$ZELLIJ_VERSION/zellij-${ZELLIJ_ARCH}-unknown-linux-musl.tar.gz"
	local DOWNLOAD_FILE="/tmp/zellij-$ZELLIJ_VERSION.tar.gz"
	local EXTRACT_DIR="/tmp/zellij_install"

	echo "Downloading from $DOWNLOAD_URL"
	if curl -fsLS "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE"; then
		mkdir -p "$EXTRACT_DIR"
		tar -xzf "$DOWNLOAD_FILE" -C "$EXTRACT_DIR"

		mkdir -p "$INSTALL_DIR"
		cp "$EXTRACT_DIR/$ZELLIJ_BIN_NAME" "$INSTALL_DIR/"
		chmod +x "$INSTALL_DIR/$ZELLIJ_BIN_NAME"

		rm "$DOWNLOAD_FILE"
		rm -rf "$EXTRACT_DIR"
	else
		echo "ERROR: Failed to download Zellij from GitHub releases."
		exit 1
	fi
}

# Remove binary installed from GitHub release
uninstall_github_release() {
	if [ -f "$INSTALL_DIR/$ZELLIJ_BIN_NAME" ]; then
		rm -f "$INSTALL_DIR/$ZELLIJ_BIN_NAME"
		echo "Removed binary: $INSTALL_DIR/$ZELLIJ_BIN_NAME"
	else
		echo "Zellij binary not found in $INSTALL_DIR."
	fi
}

# --- Main Script ---

# Handle --uninstall flag
if [[ "$1" == "--uninstall" ]]; then
	echo "--- Zellij Uninstallation ---"

	uninstall_github_release
	remove_zellij_autocompletion

	echo "--- Zellij Uninstallation Complete ---"
	exit 0
fi

echo "--- Zellij Installation ---"

# 1. Check if Zellij is already installed
if command_exists "$ZELLIJ_BIN_NAME"; then
	echo "Zellij is already installed:"
	"$ZELLIJ_BIN_NAME" --version
	setup_zellij_autocompletion
	echo "Exiting."
	exit 0
fi

# 2. Install from GitHub release
install_github_release

# 3. Setup autocompletion
setup_zellij_autocompletion

# 4. Verify installation
echo "Verifying Zellij installation..."
if command_exists "$ZELLIJ_BIN_NAME"; then
	echo "Zellij installed successfully:"
	"$ZELLIJ_BIN_NAME" --version
else
	echo "ERROR: Zellij was installed but the '$ZELLIJ_BIN_NAME' command is not found."
	echo "Try restarting your shell."
	exit 1
fi

echo "--- Zellij Installation Complete ---"
