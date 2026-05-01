return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		{ "nvim-telescope/telescope.nvim", version = "*", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
	},
	ft = "python", -- Load when opening Python files
	keys = { { "fv", "<cmd>VenvSelect<cr>", { desc = { "Search virtual environements" } } } },
	opts = {
		options = {}, -- plugin-wide options
		search = {}, -- custom search definitions
	},
}
