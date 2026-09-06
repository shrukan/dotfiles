#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Runtime dependencies for Neovim config (extracted from nvim-docker/Dockerfile)

# Debian/Ubuntu runtime packages
DEBIAN_RUNTIME_DEPS=(
	curl tar fzf ripgrep tree git xclip tzdata openssh-client
)

# RPM-based runtime packages
RPM_RUNTIME_DEPS=(
	curl tar fzf ripgrep tree git xclip tzdata openssh-client
)

# Tool versions (keep in sync with Dockerfile)
# Can be overridden via environment variables (used by Dockerfile)
GO_VERSION="${GO_VERSION:-1.26.0}"
NODE_VERSION="${NODE_VERSION:-24.0.0}"
LAZYGIT_VERSION="${LAZYGIT_VERSION:-0.62.2}"
TEMPL_VERSION="${TEMPL_VERSION:-0.3.1001}"

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

install_debian_runtime_deps() {
	echo "Installing Debian/Ubuntu runtime dependencies (this may require sudo)..."
	run_as_sudo apt-get update
	run_as_sudo apt-get install -y --no-install-recommends "${DEBIAN_RUNTIME_DEPS[@]}"
}

install_rpm_runtime_deps() {
	echo "Installing RPM-based runtime dependencies (this may require sudo)..."
	run_as_sudo dnf install -y --skip-unavailable "${RPM_RUNTIME_DEPS[@]}"
}

install_uv() {
	if command_exists uv; then
		echo "uv is already installed."
		return
	fi
	echo "Installing uv..."
	curl -fsSL https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
}

install_node() {
	if command_exists node && node --version | grep -q "^v${NODE_VERSION}"; then
		echo "Node.js v${NODE_VERSION} is already installed."
		return
	fi
	echo "Installing Node.js v${NODE_VERSION}..."
	curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" |
		tar -xJ --strip-components=1 -C /usr/local/bin
}

install_lazygit() {
	if command_exists lazygit; then
		echo "lazygit is already installed."
		return
	fi
	echo "Installing lazygit v${LAZYGIT_VERSION}..."
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz" &&
		tar xf lazygit.tar.gz lazygit &&
		install lazygit /usr/local/bin &&
		rm lazygit lazygit.tar.gz
}

install_go() {
	if command -v go >/dev/null 2>&1 && go version | grep -q "go${GO_VERSION}"; then
		echo "Go ${GO_VERSION} is already installed."
		return
	fi
	echo "Installing Go ${GO_VERSION}..."
	curl -Lo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" &&
		tar -C /usr/local -xzf /tmp/go.tar.gz &&
		rm /tmp/go.tar.gz
}

install_templ() {
	if command_exists templ; then
		echo "templ is already installed."
		return
	fi
	echo "Installing templ v${TEMPL_VERSION}..."
	curl -Lo templ.tar.gz "https://github.com/a-h/templ/releases/download/v${TEMPL_VERSION}/templ_Linux_x86_64.tar.gz" &&
		tar xf templ.tar.gz templ &&
		install templ /usr/local/bin &&
		rm templ templ.tar.gz
}

install_tree_sitter_cli() {
	if command_exists tree-sitter; then
		echo "tree-sitter-cli is already installed."
		return
	fi
	echo "Installing tree-sitter-cli..."
	npm i -g tree-sitter-cli
}

# --- Uninstall functions ---

uninstall_debian_runtime_deps() {
	echo "Removing Debian/Ubuntu runtime dependencies (this may require sudo)..."
	run_as_sudo apt-get autoremove -y "${DEBIAN_RUNTIME_DEPS[@]}"
}

uninstall_rpm_runtime_deps() {
	echo "Removing RPM-based runtime dependencies (this may require sudo)..."
	run_as_sudo dnf remove -y --skip-unavailable "${RPM_RUNTIME_DEPS[@]}"
}

uninstall_go() {
	if [ -d /usr/local/go ]; then
		echo "Removing Go from /usr/local/go..."
		run_as_sudo rm -rf /usr/local/go
	fi
}

uninstall_node() {
	echo "Removing Node.js from /usr/local/bin..."
	run_as_sudo rm -f /usr/local/bin/node /usr/local/bin/nodejs /usr/local/bin/npm /usr/local/bin/npx
}

uninstall_lazygit() {
	if command -v lazygit >/dev/null 2>&1; then
		echo "Removing lazygit..."
		run_as_sudo rm -f /usr/local/bin/lazygit
	else
		echo "lazygit not found, skipping."
	fi
}

uninstall_templ() {
	if command -v templ >/dev/null 2>&1; then
		echo "Removing templ..."
		run_as_sudo rm -f /usr/local/bin/templ
	else
		echo "templ not found, skipping."
	fi
}

uninstall_tree_sitter_cli() {
	if command_exists tree-sitter; then
		echo "Removing tree-sitter-cli..."
		sudo npm uninstall -g tree-sitter-cli
	else
		echo "tree-sitter-cli not found, skipping."
	fi
}

# --- Main Script ---

# Handle --uninstall flag
if [[ "$1" == "--uninstall" ]]; then
	echo "--- Neovim Runtime Dependencies Uninstallation ---"

	# Uninstall tools
	uninstall_tree_sitter_cli
	uninstall_templ
	uninstall_go
	uninstall_lazygit
	uninstall_node
	uninstall_uv

	# Uninstall system packages
	if command_exists apt-get; then
		uninstall_debian_runtime_deps
	elif command_exists dnf; then
		uninstall_rpm_runtime_deps
	fi

	echo "--- Neovim Runtime Dependencies Uninstallation Complete ---"
	exit 0
fi

echo "--- Neovim Runtime Dependencies Installation ---"

# 1. Install system runtime dependencies
echo "Installing runtime dependencies (this may require sudo)..."
if command_exists apt-get; then
	install_debian_runtime_deps
elif command_exists dnf; then
	install_rpm_runtime_deps
else
	echo "ERROR: Unsupported package manager. Please install dependencies manually."
	exit 1
fi

# 2. Install uv
install_uv

# 3. Install Node.js
install_node

# 4. Install lazygit
install_lazygit

# 5. Install Go
install_go

# 6. Install templ
install_templ

# 7. Install tree-sitter-cli
install_tree_sitter_cli

echo "--- Neovim Runtime Dependencies Installation Complete ---"
