#!/bin/bash
set -e

echo "--- Neovim Plugin & LSP Setup in Container ---"

# Set XDG_CONFIG_HOME if Neovim is looking there
export XDG_CONFIG_HOME="/root/.config"
export PATH="/root/.local/bin:$PATH"

# Install Neovim plugins using Lazy.nvim
echo "Installing Neovim plugins via Lazy.nvim..."
nvim --headless -c "Lazy! install" +qa || true
echo "Neovim plugins installed."

# Install LSP servers, formatters, linters using Mason.nvim
echo "Installing LSP servers and tools via Mason.nvim..."
nvim --headless -c ":MasonToolsUpdateSync" +qa || true
echo "Mason.nvim tools installed."

# Install Tree-sitter parsers
echo "Running :TSUpdate to ensure Tree-sitter parsers are installed..."
nvim --headless -c ":TSUpdate" +qa || true
echo "Tree-sitter parsers updated."

echo "--- Neovim Setup Complete in Container ---"
