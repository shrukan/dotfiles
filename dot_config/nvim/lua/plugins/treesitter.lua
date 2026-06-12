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
		require("nvim-treesitter").install(parsersToInstall):wait(300000)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
