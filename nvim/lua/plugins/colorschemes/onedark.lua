return {
	"navarasu/onedark.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("onedark").setup({
			style = "deep",
			colors = {
				green = "#00bb5a",
				fg = "#b7c6e2",
			},
			highlights = {
				["@nospell"] = { fg = "none" },
				["@spell"] = { fg = "none" },
			},
		})
	end,
}
