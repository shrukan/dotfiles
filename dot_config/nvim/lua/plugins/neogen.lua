return {
	"danymat/neogen",
	config = function()
		require("neogen").setup({
			enabled = true,
			languages = {
				lua = {
					template = {
						annotation_convention = "emmylua",
					},
					typescript = {
						template = {
							annotation_convention = "tsdoc",
						},
					},
					typescriptreact = {
						template = {
							annotation_convention = "tsdoc",
						},
					},
					python = {
						template = {
							annotation_convention = "google_docstrings",
						},
					},
				},
			},
		})
		vim.keymap.set("n", "<leader>cg", "<cmd>Neogen<CR>", { desc = "Generate annotations" })
	end,
}
