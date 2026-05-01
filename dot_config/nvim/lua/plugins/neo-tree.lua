return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	lazy = false,
	config = function()
		require("neo-tree").setup({
			enable_diagnostics = true,
			window = {
				mappings = {
					["Z"] = "expand_all_subnodes",
				},
			},
			filesystem = {
				bind_to_cwd = true,
			},
		})
		local keymap = vim.keymap
		keymap.set("n", "<leader>et", "<cmd>Neotree toggle left<CR>", { desc = "Toggle" })
		keymap.set("n", "<leader>ec", "<cmd>Neotree close filesystem<CR>", { desc = "Close" })
		keymap.set("n", "<leader>eb", "<cmd>Neotree buffers right<CR>", { desc = "Buffers" })
		keymap.set("n", "<leader>ef", "<cmd>Neotree right left reveal_force_cwd<CR>", { desc = "Open at current file" })
		keymap.set("n", "<leader>gs", "<cmd>Neotree float git_status<CR>", { desc = "Status" })
	end,
}
