return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters = {
				rumdl = {
					command = "rumdl",
					args = "fmt --stdin",
				},
				golangcilint = {
					command = "golangci-lint",
					args = { "fmt", "--stdin" },
					cwd = require("conform.util").root_file({ ".golangci.yml", "go.mod", "go.sum" }),
				},
			},

			formatters_by_ft = {
				go = { "golangcilint" },
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
				html = { "prettier" },
				htmlangular = { "prettier" },
				css = { "prettier" },
				jsonc = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				make = { "bake" },
				markdown = { "rumdl" },
				bash = { "shfmt" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
			},

			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 500,
			},
			-- conform will notify you when no formatters are available for the buffer
			notify_no_formatters = true,
		})

		vim.keymap.set({ "n", "v" }, "<leader>cs", function()
			conform.format({
				lsp_fallback = true,
				async = true,
			})
		end, { desc = "Style/Format file or range (in visual mode)" })
	end,
}
