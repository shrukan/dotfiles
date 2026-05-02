return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"b0o/schemastore.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		capabilities = {
			textDocument = {
				foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true,
				},
			},
		},
	},
	config = function()
		local opts = { noremap = true, silent = true }

		-- toggle inlay hints (start with true)
		vim.lsp.inlay_hint.enable(true)
		local toggle_inlay_hints = function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end

		local keymap = vim.keymap

		opts.desc = "Toggle inlay hints"
		keymap.set("n", "<leader>ch", toggle_inlay_hints, opts)

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>sr", "<cmd>LspRestart<CR>", opts) -- mapping to restart lsp if necessary

		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- configure lua server
		vim.lsp.config("lua_ls", {
			---@type lspconfig.settings.lua_ls
			settings = {
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					hint = {
						enable = true,
						setType = true,
						paramType = true,
						paramName = "All",
						semicolon = "All",
						arrayIndex = "Disable",
					},
					completion = {
						callSnippet = "Replace",
					},
					codeLens = {
						enable = true,
					},
				},
			},
		})

		vim.lsp.enable("lua_ls")

		-- configure go server
		vim.lsp.config("gopls", {
			cmd = { "gopls" },
			settings = {
				gopls = {
					gofumpt = false,
					codelenses = {
						gc_details = false,
						generate = true,
						regenerate_cgo = true,
						run_govulncheck = true,
						test = true,
						tidy = true,
						upgrade_dependency = true,
						vendor = true,
					},
					experimentalPostfixCompletions = true,
					analyses = {
						unusedparams = true,
						unusedwrite = true,
						shadow = true,
						nilness = true,
						useany = true,
					},
					hints = {
						rangeVariableTypes = true,
						parameterNames = true,
						constantValues = true,
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						functionTypeParameters = true,
					},
					staticcheck = true,
					semanticTokens = true,
					directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
					completeUnimported = true,
				},
			},
			init_options = {
				usePlaceholders = false,
			},
		})

		vim.lsp.enable("gopls")

		local install_path = vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules"
		local ang = install_path .. "/@angular/language-server/node_modules"

		local cmd = {
			"ngserver",
			"--stdio",
			"--tsProbeLocations",
			install_path,
			"--ngProbeLocations",
			ang,
		}

		vim.lsp.config("angularls", {
			root_markers = { "angular.json", "nx.json" },
			on_new_config = function(new_config, _)
				new_config.cmd = cmd
			end,
		})

		vim.lsp.enable("angularls")

		-- configure servers for web development
		vim.lsp.config("ts_ls", {
			---@type lspconfig.settings.ts_ls
			settings = {
				MaxTsServerMemory = 4096,
				preferences = {
					includeInlayParameterTypeHints = "all",
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					importModuleSpecifierPreference = "project-relative",
				},
			},
		})

		vim.lsp.enable("ts_ls")
		vim.lsp.enable("cssls")
		vim.lsp.enable("html")

		vim.lsp.config("emmet_language_server", {
			filetypes = {
				"css",
				"eruby",
				"html",
				"htmlangular",
				"javascript",
				"javascriptreact",
				"less",
				"sass",
				"scss",
				"pug",
				"typescriptreact",
			},
			init_options = {
				showSuggestionsAsSnippets = true,
			},
		})

		-- configure toml server
		vim.lsp.enable("taplo")

		vim.lsp.config("jsonls", {
			---@type lspconfig.settings.jsonls
			settings = {
				json = {
					schemaStore = {
						enable = false,
						url = "",
					},
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})

		vim.lsp.enable("jsonls")

		vim.lsp.config("yamlls", {
			---@type lspconfig.settings.yamlls
			settings = {
				yaml = {
					schemaStore = {
						enable = false,
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
					validate = true,
				},
			},
		})

		vim.lsp.enable("yamlls")

		-- configure docker server
		vim.lsp.enable("dockerls")

		vim.lsp.enable("docker_compose_language_service")

		vim.lsp.enable("bashls")

		vim.lsp.enable("marksman")

		vim.lsp.enable("templ")

		vim.lsp.enable("zuban")
	end,
}
