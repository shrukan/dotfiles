return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local ensureInstalled = {
			"go",
			"gomod",
			"gosum",
			"gowork",
			"lua",
			"javascript",
			"typescript",
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
			"bash",
			"regex",
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
