return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local ensureInstalled = {
			"dhall",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"lua",
			"javascript",
			"angular",
			"html",
			"css",
			"scss",
			"vim",
			"json",
			"yaml",
			"sql",
			"dockerfile",
			"git_config",
			"gitcommit",
			"git_rebase",
			"gitignore",
			"gitattributes",
			"markdown",
			"markdown_inline",
			"python",
			"bash",
			"regex",
			"templ",
			"typescript",
		}
		local alreadyInstalled = require("nvim-treesitter.config").get_installed()
		local parsersToInstall = vim.iter(ensureInstalled)
			:filter(function(parser)
				return not vim.tbl_contains(alreadyInstalled, parser)
			end)
			:totable()
		-- offline a missing parser is skipped instead of waiting on a download
		if not vim.g.offline and #parsersToInstall > 0 then
			require("nvim-treesitter").install(parsersToInstall):wait(300000)
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				-- Parsing a huge file (minified bundle, generated code, a vendored
				-- dependency reached via go-to-definition) blocks the UI; those fall
				-- back to regex syntax highlighting instead.
				local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
				if stat and stat.size > 1024 * 1024 then
					return
				end
				pcall(vim.treesitter.start)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
