return {
	"leoluz/nvim-dap-go",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		require("dap-go").setup({
			delve = {
				-- Important: Tell dap-go to use the Mason-installed Delve
				path = "dlv",
				initialize_timeout_sec = 20,
				port = "${port}",
				args = {},
			},
		})

		local wk = require("which-key")
		wk.add({
			{
				"<leader>dt",
				function()
					require("dap-go").debug_test()
				end,
				desc = "Debug test",
				icon = "",
			},
		})
	end,
}
