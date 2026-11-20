-- NVIM_OFFLINE=1 (set in the nvim-docker image) disables everything that
-- downloads: plugin installs and update checks, Mason, Tree-sitter, windsurf.
vim.g.offline = vim.env.NVIM_OFFLINE == "1"

require("core.options")
require("core.keymaps")
require("core.lazy")
