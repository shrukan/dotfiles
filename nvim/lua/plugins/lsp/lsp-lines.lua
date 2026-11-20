return {
	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	config = function()
		local lsp_lines = require("lsp_lines")

		vim.diagnostic.config({
			virtual_text = {
				source = "if_many",
			},
		})

		Virtual_text = true

		lsp_lines.setup(vim.keymap.set("n", "<leader>sd", function()
			lsp_lines.toggle()

			Virtual_text = not Virtual_text

			if Virtual_text then
				vim.diagnostic.config({
					virtual_text = {
						source = "if_many",
					},
				})
			else
				vim.diagnostic.config({
					virtual_text = false,
				})
			end
		end, { desc = "Toggle detailed line diagnostics" }))
	end,
}
