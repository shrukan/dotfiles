return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
		},
		keys = {
			{
				"<leader>ta",
				function()
					require("neotest").run.attach()
				end,
				desc = "Attach",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "File",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Toggle summary",
			},
			{
				"<leader>tA",
				function()
					require("neotest").run.run(vim.uv.cwd())
				end,
				desc = "All files",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true, auto_close = true })
				end,
				desc = "Output",
			},
		},
		config = function()
			local neotest_golang_opts = {} -- Specify custom configuration
			require("neotest").setup({
				-- Registration
				adapters = {
					require("neotest-golang")(neotest_golang_opts),
				},
			})
		end,
	},
}
