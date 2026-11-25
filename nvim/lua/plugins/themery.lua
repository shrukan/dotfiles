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
				{
					name = "Onedark (Deeper)",
					colorscheme = "onedark",
					before = [[ vim.opt.background = "dark" ]],
				},
				{
					name = "Jetbrains (Light)",
					colorscheme = "jb",
					before = [[ vim.opt.background = "light" ]],
				},
				{
					name = "Jetbrains (Dark)",
					colorscheme = "jb",
					before = [[ vim.opt.background = "dark" ]],
				},
				{ name = "Cyberdream", colorscheme = "cyberdream" },
				{ name = "Jellybeans", colorscheme = "jellybeans" },
			},
			livePreview = true,
		})

		-- Themery only restores a theme saved in stdpath("data"); a fresh machine or
		-- container has none and would start on Neovim's built-in default. theme_id is
		-- set exactly when a saved state was loaded. Not persisted, so a later pick wins.
		-- setThemeByIndex rather than setThemeByName: the latter stores index + 1.
		local default_theme = "Onedark (Deeper)"
		if vim.g.theme_id == nil then
			for i, theme in ipairs(require("themery").getAvailableThemes()) do
				if theme.name == default_theme then
					require("themery").setThemeByIndex(i, false)
					break
				end
			end
		end

		vim.keymap.set("n", "<leader>sc", "<cmd>Themery<CR>", { desc = "Colorscheme" })
	end,
}
