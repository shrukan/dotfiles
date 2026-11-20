return {
	"nvimdev/lspsaga.nvim",
	config = function()
		require("lspsaga").setup({
			-- TODO: Configure plugin
			code_action = {
				show_server_name = false,
				extend_gitsigns = false,
			},
			lightbulb = {
				virtual_text = false,
			},
			symbol_in_winbar = {
				enable = true,
			},
			outline = {
				win_width = 40,
				keys = {
					toggle_or_jump = "<CR>",
				},
			},
			finder = {
				keys = {
					toggle_or_open = "<CR>",
					split = "s",
					vsplit = "S",
				},
			},
			implement = {
				enable = true,
				sign = true,
				virtual_text = true,
				priority = 100,
			},
		})

		-- keymaps
		local keymap = vim.keymap
		keymap.set("n", "<leader>ce", "<cmd>Lspsaga hover_doc<CR>", { desc = "Show documentation" })
		keymap.set("n", "<leader>cE", "<cmd>Lspsaga hover_doc ++keep<CR>", { desc = "Show documentation (keep)" })
		keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Available action(s)" })

		keymap.set("n", "<leader>cr", "<cmd>Lspsaga rename<CR>", { desc = "Rename" })
		keymap.set("n", "<leader>cR", "<cmd>Lspsaga rename ++project<CR>", { desc = "Rename (project)" })

		keymap.set("n", "<leader>cci", "<cmd>Lspsaga incoming_calls<CR>", { desc = "Incoming" })
		keymap.set("n", "<leader>cco", "<cmd>Lspsaga outgoing_calls<CR>", { desc = "Outgoing" })

		keymap.set("n", "<leader>cd", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
		keymap.set("n", "<leader>cD", "<cmd>Lspsaga goto_definition<CR>", { desc = "Goto definition" })
		keymap.set("n", "<leader>ct", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "Peek type definition" })
		keymap.set("n", "<leader>cT", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "Goto type definition" })

		keymap.set("n", "<leader>cid", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next diagnostic" })
		keymap.set("n", "<leader>ciD", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous diagnostic" })
		keymap.set(
			"n",
			"<leader>ciw",
			"<cmd>Lspsaga show_workspace_diagnostics<CR>",
			{ desc = "Workspace diagnostic(s)" }
		)

		keymap.set("n", "<leader>cfa", "<cmd>Lspsaga finder def+ref+imp<CR>", { desc = "All" })
		keymap.set("n", "<leader>cfd", "<cmd>Lspsaga finder def<CR>", { desc = "Definition(s)" })
		keymap.set("n", "<leader>cfr", "<cmd>Lspsaga finder ref<CR>", { desc = "Reference(s)" })
		keymap.set("n", "<leader>cfi", "<cmd>Lspsaga finder imp<CR>", { desc = "Implementation(s)" })

		-- FIX: LSP errors
		keymap.set("n", "<leader>cio", "<cmd>Lspsaga outline<CR>", { desc = "Outline" })
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- optional
		"nvim-tree/nvim-web-devicons", -- optional
	},
}
