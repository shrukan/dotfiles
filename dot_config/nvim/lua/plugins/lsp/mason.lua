return {
	"williamboman/mason.nvim",
	dependencies = {
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		local has_go = function()
			return vim.fn.executable("go") == 1
		end

		local has_temple = function()
			return vim.fn.executable("temple") == 1
		end

		local has_python = function()
			local has_binaries = vim.fn.executable("python3") == 1
				and (vim.fn.executable("pip") == 1 or vim.fn.executable("pip3") == 1)

			if not has_binaries then
				return false
			end

			local venv_check = os.execute("python3 -m venv --help > /dev/null 2>&1")
			return venv_check == 0
		end

		-- list of tools for mason to install
		mason_tool_installer.setup({
			ensure_installed = {
				-- lsp
				"lua-language-server",
				{ "gopls", condition = has_go },
				{ "zuban", condition = has_python },
				{ "templ", condition = has_temple },
				"typescript-language-server",
				"angular-language-server",
				"html-lsp",
				"css-lsp",
				"taplo",
				"json-lsp",
				"yaml-language-server",
				"emmet-language-server",
				"dockerfile-language-server",
				"docker-compose-language-service",
				"bash-language-server",
				"marksman",

				-- formatters
				"prettier", -- web
				"stylua", -- lua
				"shfmt", -- bash
				"mbake", -- makefile

				-- linters
				"eslint_d", -- web
				"selene", -- lua
				"hadolint", -- dockerfile
				"shellcheck", -- bash
				"checkmake", -- makefile

				-- formatter/linters
				{ "golangci-lint", condition = has_go },
				{ "ruff", condition = has_python },
				"rumdl", -- markdown
			},

			automatic_installation = true,
		})
	end,
}
