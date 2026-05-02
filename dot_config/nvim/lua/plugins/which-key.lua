return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.setup({
			preset = "helix",
			delay = 10,
			plugins = {
				presets = {
					z = false,
				},
			},
		})
		wk.add({
			{ "<leader>c", group = "Code" },
			{ "<leader>cc", group = "Calls" },
			{ "<leader>cf", group = "Finder" },
			{ "<leader>ci", group = "Information" },

			{ "<leader>d", group = "Debug", icon = "" },

			{ "<leader>e", group = "Filesystem" },

			{ "<leader>f", group = "Search" },

			{ "<leader>g", group = "Git" },
			{ "<leader>gt", group = "Toggle" },

			{ "<leader>m", group = "Markview", icon = "" },
			{ "<leader>mc", group = "Checkbox" },
			{ "<leader>me", group = "Code" },
			{ "<leader>ms", group = "Split" },

			{ "<leader>s", group = "Settings", icon = "" },

			{ "<leader>t", group = "Test", icon = "" },
		})
	end,
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Show local keymaps",
		},
	},
}
