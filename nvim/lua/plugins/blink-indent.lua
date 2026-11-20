return {
	"saghen/blink.indent",
	config = function()
		local indent = require("blink.indent")
		vim.keymap.set("n", "<leader>si", function()
			indent.enable(not indent.is_enabled())
		end, { desc = "Toggle indent guide" })
	end,
}
