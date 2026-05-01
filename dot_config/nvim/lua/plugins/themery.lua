return {
	"zaldih/themery.nvim",
	lazy = false,
	config = function()
		require("themery").setup({
			themes = {
				{ name = "Catppuccin (Latte)", colorscheme = "catppuccin-latte" },
				{ name = "Catppuccin (Frappe)", colorscheme = "catppuccin-frappe" },
				{ name = "Catppuccin (Macchiato)", colorscheme = "catppuccin-macchiato" },
				{ name = "Catppuccin (Mocha)", colorscheme = "catppuccin-mocha" },
				{ name = "Tokyonight (Day)", colorscheme = "tokyonight-day" },
				{ name = "Tokyonight (Moon)", colorscheme = "tokyonight-moon" },
				{ name = "Tokyonight (Storm)", colorscheme = "tokyonight-storm" },
				{ name = "Tokyonight (Night)", colorscheme = "tokyonight-night" },
				{ name = "Kanagawa (Wave)", colorscheme = "kanagawa-wave" },
				{ name = "Kanagawa (Lotus)", colorscheme = "kanagawa-lotus" },
				{ name = "Kanagawa (Dragon)", colorscheme = "kanagawa-dragon" },
				{ name = "Onedark (Deeper)", colorscheme = "onedark" },

				{ name = "Cyberdream", colorscheme = "cyberdream" },
				{ name = "Jellybeans", colorscheme = "jellybeans" },
			},
			livePreview = true, -- Apply theme while picking. Default to true.
		})

		-- keymaps
		vim.keymap.set("n", "<leader>sc", "<cmd>Themery<CR>", { desc = "Colorscheme" })
	end,
}
