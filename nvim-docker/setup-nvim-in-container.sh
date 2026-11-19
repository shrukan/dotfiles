#!/bin/bash
set -euo pipefail

echo "--- Neovim Plugin & LSP Setup in Container ---"

export XDG_CONFIG_HOME="/root/.config"
export PATH="/root/.local/bin:$PATH"

# Start nvim in an empty directory: plugins that search the working directory
# on startup would otherwise scan the whole image from /.
cd "$(mktemp -d)"

# The first start bootstraps lazy.nvim, installs missing plugins and, through
# the treesitter config, the parsers. restore then pins every plugin to
# lazy-lock.json.
echo "Installing Neovim plugins via Lazy.nvim..."
nvim --headless "+Lazy! restore" +qa

echo "Installing LSP servers and tools via Mason.nvim..."
nvim --headless "+MasonToolsInstallSync" +qa

# Parallel installs fail now and then (npm, GitHub rate limits). A second run
# only retries what is missing; a failure there is real and fails the build.
echo "Retrying Mason tools that failed..."
mason_out="$(nvim --headless "+MasonToolsInstallSync" +qa 2>&1)"
echo "$mason_out"
if grep -q "failed to install" <<<"$mason_out"; then
	echo "ERROR: Mason tools failed to install twice"
	exit 1
fi

# blink.cmp loads on InsertEnter, so a headless start never fetches its
# prebuilt fuzzy matcher; without it the image falls back to the lua matcher.
echo "Downloading the blink.cmp fuzzy matcher..."
nvim --headless "+Lazy! load blink.cmp" -c 'lua
local done, ok = false, false
require("blink.cmp.fuzzy.download").ensure_downloaded(function(err, impl)
	done, ok = true, err == nil and impl == "rust"
	if err then io.stderr:write(tostring(err) .. "\n") end
end)
vim.wait(180000, function() return done end, 200)
os.exit(ok and 0 or 1)' +qa

# --- Verify: fail the build instead of shipping a half-installed image ---
echo "Verifying installation..."
for bin in nvim go gopls golangci-lint dlv; do
	command -v "$bin" >/dev/null || {
		echo "ERROR: $bin missing"
		exit 1
	}
done

nvim --headless -c 'lua
local missing = {}
local installed = require("nvim-treesitter.config").get_installed()
for _, p in ipairs({ "go", "gomod", "gowork", "lua", "markdown" }) do
	if not vim.tbl_contains(installed, p) then
		table.insert(missing, "parser:" .. p)
	end
end
for _, b in ipairs({ "lua-language-server", "bash-language-server", "stylua" }) do
	if vim.fn.executable(b) == 0 then
		table.insert(missing, "mason:" .. b)
	end
end
if #missing > 0 then
	io.stderr:write("missing: " .. table.concat(missing, ", ") .. "\n")
	os.exit(1)
end
os.exit(0)' +qa

echo "--- Neovim Setup Complete in Container ---"
