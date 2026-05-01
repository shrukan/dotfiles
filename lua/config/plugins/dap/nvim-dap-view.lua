return {
	{
		"igorlfs/nvim-dap-view",
		lazy = false,
		---@module 'dap-view'
		---@type dapview.Config
		opts = {},
		config = function()
			local wk = require("which-key")
			wk.add({
				{
					"<leader>dv",
					"<cmd>DapViewToggle<cr>",
					desc = "Toggle view",
					mode = { "n" },
				},
				{
					"<leader>dw",
					"<cmd>DapViewWatch<cr>",
					desc = "Watch expression",
					mode = { "n", "v" },
				},
				{
					"<leader>dW",
					":DapViewWatch ",
					desc = "Watch custom expression",
					mode = { "n" },
				},
			})
		end,
	},
}
