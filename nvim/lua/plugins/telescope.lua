return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		--     { "nvim-telescope/telescope-fzf-native.nvim",
		--         build = "make",
		--         config = function()
		--           require("telescope").load_extension("fzf")
		--         end,build = "make" },
	},

	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local transform_mod = require("telescope.actions.mt").transform_mod

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
			extensions = {
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					-- the default case_mode is "smart_case"
				},
			},
		})

		telescope.load_extension("fzf")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "String in cwd" })
		keymap.set(
			"n",
			"<leader>fc",
			"<cmd>Telescope grep_string initial_mode=normal<cr>",
			{ desc = "String under cursor in cwd" }
		)
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope initial_mode=normal<cr>", { desc = "Todos" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers initial_mode=normal<cr>", { desc = "Buffers" })
	end,
}
