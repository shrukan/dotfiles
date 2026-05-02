return {
	"mfussenegger/nvim-lint",
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	config = function()
		local lint = require("lint")

		local function get_lsp_root()
			-- Get all clients attached to the current buffer (0)
			local clients = vim.lsp.get_clients({ bufnr = 0 })

			for _, client in ipairs(clients) do
				if client.root_dir then
					return client.root_dir
				end
			end
			-- FALLBACK: If no LSP is attached yet, fall back to file directory
			return vim.loop.cwd()
		end

		lint.linters_by_ft = {
			lua = { "selene" },
			go = { "golangcilint" },
			python = { "ruff" },
			make = { "checkmake" },
			markdown = { "rumdl" },
			mod = { "golangcilint" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			htmlangular = { "eslint_d" },
			html = { "eslint_d" },
			dockerfile = { "hadolint" },
			bash = { "shellcheck" },
			sh = { "shellcheck" },
			zsh = { "shellcheck" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint(nil, { cwd = get_lsp_root() })
			end,
		})

		vim.keymap.set("n", "<leader>cl", function()
			lint.try_lint(nil, { cwd = get_lsp_root() })
		end, { desc = "Trigger linting for current file" })
	end,
}
