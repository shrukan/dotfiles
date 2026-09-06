#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
INSTALL_PREFIX="$1"
NVIM_VERSION="$2"
# Directory where Neovim will be cloned
CLONE_DIR="/tmp/nvim_build_source"

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

# Function to remove build dependencies installed by this script
remove_debian_deps() {
	echo "Removing Debian/Ubuntu build dependencies (this may require sudo)..."
	run_as_sudo apt-get autoremove -y git cmake build-essential gettext ninja-build unzip libtool libtool-bin autoconf automake pkg-config g++ libjemalloc-dev libicu-dev python3 python3-pip
}

remove_rpm_deps() {
	echo "Removing RPM-based build dependencies (this may require sudo)..."
	run_as_sudo dnf remove -y --skip-unavailable git cmake make which gettext ninja-build unzip autoconf automake pkg-config gcc jemalloc-devel libicu-devel python3 python3-pip
}

install_debian_deps() {
	echo "Installing Debian/Ubuntu dependencies (this may require sudo)..."
	run_as_sudo apt-get update
	run_as_sudo apt-get install -y git cmake build-essential gettext ninja-build unzip libtool libtool-bin autoconf automake pkg-config g++ libjemalloc-dev libicu-dev python3 python3-pip python3-venv
}

install_rpm_deps() {
	echo "Installing RPM-based dependencies (this may require sudo)..."
	run_as_sudo dnf install -y --skip-unavailable git cmake make which gettext ninja-build unzip autoconf automake pkg-config gcc jemalloc-devel libicu-devel python3 python3-pip
}

# --- Main Script ---

# Handle --uninstall flag
if [[ "$1" == "--uninstall" ]]; then
	echo "--- Neovim Uninstallation Script ---"

	# 1. Remove Neovim binary
	echo "Removing Neovim from $INSTALL_PREFIX/bin..."
	if [ -f "$INSTALL_PREFIX/bin/nvim" ]; then
		run_as_sudo rm -f "$INSTALL_PREFIX/bin/nvim"
		echo "Removed $INSTALL_PREFIX/bin/nvim"
	else
		echo "Neovim binary not found at $INSTALL_PREFIX/bin/nvim"
	fi

	# 2. Remove build dependencies
	echo "Removing build dependencies..."
	if command_exists apt-get; then
		remove_debian_deps
	elif command_exists dnf; then
		remove_rpm_deps
	fi

	# 3. Remove build source directory if it still exists
	if [ -d "$CLONE_DIR" ]; then
		echo "Removing build source directory: $CLONE_DIR"
		rm -rf "$CLONE_DIR"
	fi

	echo "--- Neovim Uninstallation Complete ---"
	exit 0
fi

echo "--- Neovim Installation from Source Script ---"
echo "Targeting installation prefix: $INSTALL_PREFIX"
echo "Building Neovim version: $NVIM_VERSION"

# 1. Install Build Dependencies (for Debian/Ubuntu/Fedora/RHEL)
echo "Installing build dependencies (this may require sudo)..."
if command_exists apt-get; then
	install_debian_deps
elif command_exists dnf; then
	install_rpm_deps
else
	echo "ERROR: Unsupported package manager. Please install dependencies manually."
	exit 1
fi

echo "Build dependencies installed."

# 2. Clone/Update Neovim Repository
if [ -d "$CLONE_DIR" ]; then
	echo "Neovim source directory already exists. Pulling latest changes..."
	cd "$CLONE_DIR"
	git fetch origin
	git checkout "$NVIM_VERSION"
	git pull origin "$NVIM_VERSION"
else
	echo "Cloning Neovim repository to $CLONE_DIR..."
	mkdir -p "$(dirname "$CLONE_DIR")" # Ensure parent directory exists
	git clone https://github.com/neovim/neovim.git "$CLONE_DIR"
	cd "$CLONE_DIR"
	git checkout "$NVIM_VERSION"
fi

echo "Neovim source code is ready."

# 3. Build Neovim
echo "Building Neovim (this may take a few minutes)..."
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" -j"$(nproc)" # Use all available cores

# 4. Install Neovim
echo "Installing Neovim to $INSTALL_PREFIX/bin (this may require sudo)..."
run_as_sudo make install

# 5. Clean up source directory
echo "Cleaning up Neovim build source files..."
rm -rf "$CLONE_DIR"

# 6. Verify Installation
echo "Verifying Neovim installation..."
if command_exists nvim; then
	echo "Neovim installed successfully:"
	nvim --version | head -n 1
else
	echo "ERROR: Neovim appears to be installed, but 'nvim' command is not found in PATH."
	echo "This indicates an issue with the installation or PATH setup within the container."
	echo "You might need to add 'export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"' to your shell's config (e.g., .bashrc, .zshrc) and then 'source' it."
	exit 1
fi

echo "--- Neovim Installation from Source Complete ---"
