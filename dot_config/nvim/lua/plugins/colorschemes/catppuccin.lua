return {
	"catppuccin/nvim",
	name = "catppucin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			term_colors = true,
			integration = {
				lazygit = true,
				sttusline = true,
				illuminate = true,
				gitsigns = true,
				toogleterminal = true,
				noice = true,
				mason = true,
				neotree = true,
				telescope = {
					enabled = true,
				},
				treesiter = true,
				treesitter_context = true,
				which_key = true,
			},
		})
	end,
}
