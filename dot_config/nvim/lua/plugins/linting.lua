return {
	"mfussenegger/nvim-lint",
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	config = function()
		local lint = require("lint")

		local js_markers = { "eslint.config.js", "eslint.config.mjs", "eslint.config.ts", "package.json" }

		-- Nearest dir (walking up from the file) containing any of these markers
		-- becomes the linter's cwd, so monorepo sub-projects win over the repo root.
		local root_markers_by_ft = {
			go = { "go.mod" },
			mod = { "go.mod" },
			python = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.cfg" },
			javascript = js_markers,
			typescript = js_markers,
			javascriptreact = js_markers,
			typescriptreact = js_markers,
			htmlangular = js_markers,
			html = js_markers,
		}

		local function get_lint_cwd()
			local markers = root_markers_by_ft[vim.bo.filetype]
			local root = markers and vim.fs.root(0, markers)
			return root
				or vim.fs.root(0, ".git")
				or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
		end

		-- Upstream golangcilint decides file-vs-directory mode once at load time
		-- via `go env GOMOD` in nvim's startup cwd, so starting nvim at a monorepo
		-- root (no top-level go.mod) makes it lint single files and typecheck
		-- breaks on symbols from sibling files. Decide per buffer instead.
		local golangcilint = lint.linters.golangcilint
		golangcilint.args[#golangcilint.args] = function()
			local in_module = vim.fs.root(0, "go.mod") ~= nil
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), in_module and ":h" or ":p")
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
				lint.try_lint(nil, { cwd = get_lint_cwd() })
			end,
		})

		vim.keymap.set("n", "<leader>cl", function()
			lint.try_lint(nil, { cwd = get_lint_cwd() })
		end, { desc = "Trigger linting for current file" })
	end,
}
