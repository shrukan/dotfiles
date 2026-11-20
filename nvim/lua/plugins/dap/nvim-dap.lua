-- package for handling pairs
return {
	"mfussenegger/nvim-dap",
	lazy = true,
	config = function()
		vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })

		local wk = require("which-key")
		wk.add({
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
				icon = "",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
				icon = "",
			},
			{
				"<leader>dC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},
			{
				"<leader>dd",
				function()
					require("dap").disconnect()
				end,
				desc = "Disconnect session",
				icon = "",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
				icon = "",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
				icon = "",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_out()
				end,
				desc = "Step out",
				icon = "",
			},
			{
				"<leader>dp",
				function()
					require("dap").pause()
				end,
				desc = "Pause",
				icon = "",
			},
			{
				"<leader>dr",
				function()
					require("dap").run_last()
				end,
				desc = "Rerun",
				icon = "",
			},
			{
				"<leader>ds",
				function()
					require("dap").continue()
				end,
				desc = "Start",
				icon = "",
			},
			{
				"<leader>dS",
				function()
					require("dap").terminate()
				end,
				desc = "Stop",
				icon = "",
			},
		})
	end,
}
