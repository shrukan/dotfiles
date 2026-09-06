#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Each entry: font_id|GitHub zip URL
# To add a new font, add a line here and update README.md
FONTS=(
	"JetBrainsMono|https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
)

FONT_DIR="$HOME/.local/share/fonts"

# --- Functions ---

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

uninstall_font() {
	local font_id="$1"
	echo "Removing $font_id from $FONT_DIR..."
	rm -f "$FONT_DIR/${font_id}*"
	echo "Removed $font_id files from $FONT_DIR"
}

download_file() {
	local url="$1"
	local dest="$2"
	if command_exists curl; then
		curl -fsLS "$url" -o "$dest"
	elif command_exists wget; then
		wget -q "$url" -O "$dest"
	else
		echo "ERROR: Neither curl nor wget found."
		exit 1
	fi
}

# --- Main Script ---

# Handle --uninstall flag
if [[ "$1" == "--uninstall" ]]; then
	echo "--- Font Uninstallation ---"
	for entry in "${FONTS[@]}"; do
		font_id="${entry%%|*}"
		uninstall_font "$font_id"
	done
	echo "--- Font Uninstallation Complete ---"
	exit 0
fi

echo "--- Font Installation ---"

# 1. Create font directory
mkdir -p "$FONT_DIR"

# 2. Install each font
for entry in "${FONTS[@]}"; do
	font_id="${entry%%|*}"
	font_url="${entry#*|}"

	# Check if any files for this font already exist
	if ls "$FONT_DIR"/${font_id}* >/dev/null 2>&1; then
		echo "$font_id is already installed in $FONT_DIR"
		continue
	fi

	echo "Installing $font_id..."

	TEMP_ZIP="/tmp/${font_id}.zip"
	download_file "$font_url" "$TEMP_ZIP"

	unzip -o "$TEMP_ZIP" -d "$FONT_DIR"
	rm "$TEMP_ZIP"
done

# 3. Rebuild font cache
fc-cache -fv

echo "All fonts installed successfully to $FONT_DIR"
echo "You may need to restart your terminal emulator for the fonts to appear."

echo "--- Font Installation Complete ---"
