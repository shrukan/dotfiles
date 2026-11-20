return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		local preset = require("markview.presets").tables

		require("markview").setup({
			preview = {
				modes = { "i", "n", "no", "c" },
				hybrid_modes = { "i" },
			},
			markdown = { tables = preset.single },
		})
		-- Enable checkbox extra
		require("markview.extras.checkboxes").setup()

		-- Enable editor extra
		require("markview.extras.editor").setup()

		local keymap = vim.keymap

		keymap.set("n", "<leader>mt", "<cmd>Markview toggle<CR>", { desc = "Toggle" })

		keymap.set("n", "<leader>mct", "<cmd>Checkbox toggle<CR>", { desc = "Toggle" })
		keymap.set("n", "<leader>mci", "<cmd>Checkbox interactive<CR>", { desc = "Interactive" })

		keymap.set("n", "<leader>mec", "<cmd>Editor create<CR>", { desc = "Create" })
		keymap.set("n", "<leader>mee", "<cmd>Editor edit<CR>", { desc = "Edit" })

		keymap.set("n", "<leader>mh", "<cmd>Markview HybridToggle<CR>", { desc = "Hybrid" })

		keymap.set("n", "<leader>msr", "<cmd>Markview splitRedraw<CR>", { desc = "Redraw" })
		keymap.set("n", "<leader>mst", "<cmd>Markview splitToggle<CR>", { desc = "Toggle" })
	end,
}
