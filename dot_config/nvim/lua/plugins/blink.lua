return {
	"saghen/blink.cmp",
	-- use a release tag to download pre-built binaries
	version = "1.*",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"archie-judd/blink-cmp-words",
		"ribru17/blink-cmp-spell",
		"MahanRahmati/blink-nerdfont.nvim",
		{
			"mikavilpas/blink-ripgrep.nvim",
			version = "*", -- use the latest stable version
		},
	},
	event = { "InsertEnter", "CmdlineEnter" },
	opts_extend = { "sources.default" },
	opts = {
		keymap = {
			preset = "none",

			["<tab>"] = {
				function(cmp)
					if cmp.snippet_active() then
						return cmp.accept()
					else
						return cmp.select_and_accept()
					end
				end,
				"snippet_forward",
				"fallback",
			},

			["<c-cr"] = {
				function(cmp)
					if cmp.snippet_active() then
						return cmp.accept_and_enter()
					else
						return cmp.select_accept_and_enter()
					end
				end,
			},

			["<c-k>"] = { "select_prev", "fallback" },
			["<c-j>"] = { "select_next", "fallback" },

			["<c-e>"] = { "show_documentation" },
			["<c-b>"] = { "scroll_documentation_up", "fallback" },
			["<c-f>"] = { "scroll_documentation_down", "fallback" },

			["<c-space>"] = { "show", "fallback" },
			["<c-q>"] = { "hide", "fallback" },

			-- use shift-tab for other mapping
			["<s-tab>"] = false,
		},

		appearance = {
			-- 'mono' (default) for 'nerd font mono' or 'normal' for 'nerd font'
			-- adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		-- (default) only show the documentation pop-up when manually triggered
		completion = {
			documentation = { auto_show = false },
			menu = {
				draw = {
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name", gap = 1 } },
					treesitter = { "lsp" },
				},
			},

			list = {
				selection = { preselect = true },
			},
		},

		-- default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer", "ripgrep", "nerdfont", "spell" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				lsp = {
					score_offset = 10,
				},
				nerdfont = {
					module = "blink-nerdfont",
					name = "Nerd Fonts",
					score_offset = 15, -- Tune by preference
					opts = { insert = true }, -- Insert nerdfont icon (default) or complete its name
				},
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					opts = {},
					score_offset = 0,
				},

				spell = {
					name = "Spell",
					module = "blink-cmp-spell",
					opts = {
						-- EXAMPLE: Only enable source in `@spell` captures, and disable it
						-- in `@nospell` captures.
						enable_in_context = function()
							local curpos = vim.api.nvim_win_get_cursor(0)
							local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
							local in_spell_capture = false
							for _, cap in ipairs(captures) do
								if cap.capture == "spell" then
									in_spell_capture = true
								elseif cap.capture == "nospell" then
									return false
								end
							end
							return in_spell_capture
						end,
					},
				},
				-- Use the thesaurus source
				thesaurus = {
					name = "Thesaurus",
					module = "blink-cmp-words.thesaurus",
					-- All available options
					opts = {
						-- A score offset applied to returned items.
						-- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
						score_offset = 0,

						-- Default pointers define the lexical relations listed under each definition,
						-- see Pointer Symbols below.
						-- Default is as below ("antonyms", "similar to" and "also see").
						definition_pointers = { "!", "&", "^" },

						-- The pointers that are considered similar words when using the thesaurus,
						-- see Pointer Symbols below.
						-- Default is as below ("similar to", "also see" }
						similarity_pointers = { "&", "^" },

						-- The depth of similar words to recurse when collecting synonyms. 1 is similar words,
						-- 2 is similar words of similar words, etc. Increasing this may slow results.
						similarity_depth = 2,
					},
				},
				-- Use the dictionary source
				dictionary = {
					name = "Dictionary",
					module = "blink-cmp-words.dictionary",
					-- All available options
					opts = {
						-- The number of characters required to trigger completion.
						-- Set this higher if completion is slow, 3 is default.
						dictionary_search_threshold = 3,

						-- See above
						score_offset = 0,

						-- See above
						definition_pointers = { "!", "&", "^" },
					},
				},
			},

			per_filetype = {
				text = { "dictionary" },
				markdown = { "thesaurus" },
			},
		},

		-- disable signature of functions (since other plugin will show it)
		signature = { enabled = false },

		cmdline = {
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},

		term = {
			enabled = true,
			keymap = { preset = "inherit" },
		},

		-- (default) rust fuzzy matcher for typo resistance and significantly better performance
		-- you may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- see the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
}
