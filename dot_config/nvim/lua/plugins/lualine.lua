local function get_attached_lsps()
	local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
	local buf_client_names = {}
	local num_client_names = #buf_client_names

	for _, client in pairs(buf_clients) do
		num_client_names = num_client_names + 1
		buf_client_names[num_client_names] = client.name
	end

	local client_names_str = table.concat(buf_client_names, ", ")
	local language_servers = string.format(" %s", client_names_str)
	if client_names_str == "" then
		language_servers = ""
	end

	return language_servers
end

local function get_attached_linters()
	local buf_ft = vim.bo.filetype
	local buf_client_names = {}
	local num_client_names = #buf_client_names

	-- Add linters for the current filetype (nvim-lint)
	local lint_success, lint = pcall(require, "lint")
	if lint_success then
		for ft, ft_linters in pairs(lint.linters_by_ft) do
			if ft == buf_ft then
				if type(ft_linters) == "table" then
					for _, linter in pairs(ft_linters) do
						num_client_names = num_client_names + 1
						buf_client_names[num_client_names] = linter
					end
				else
					num_client_names = num_client_names + 1
					buf_client_names[num_client_names] = ft_linters
				end
			end
		end
	end

	local client_names_str = table.concat(buf_client_names, ", ")
	local language_servers = string.format(" %s", client_names_str)
	if client_names_str == "" then
		language_servers = ""
	end

	return language_servers
end

local function get_attached_formatters()
	local buf_client_names = {}
	local num_client_names = #buf_client_names

	-- Add formatters (conform.nvim)
	local conform_success, conform = pcall(require, "conform")
	if conform_success then
		for _, formatter in pairs(conform.list_formatters_for_buffer(0)) do
			if formatter then
				num_client_names = num_client_names + 1
				buf_client_names[num_client_names] = formatter
			end
		end
	end

	local client_names_str = table.concat(buf_client_names, ", ")
	local language_servers = string.format(" %s", client_names_str)
	if client_names_str == "" then
		language_servers = ""
	end

	return language_servers
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"bezhermoso/todos-lualine.nvim",
		"folke/todo-comments.nvim",
	},
	config = function()
		local todos_component = require("todos-lualine").component({
			order = { "TODO", "FIX", "HACK" },
		})

		require("lualine").setup({

			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				always_show_tabline = true,
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
					refresh_time = 16, -- ~60fps
					events = {
						"WinEnter",
						"BufEnter",
						"BufWritePost",
						"SessionLoadPost",
						"FileChangedShellPost",
						"VimResized",
						"Filetype",
						"CursorMoved",
						"CursorMovedI",
						"ModeChanged",
					},
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename", todos_component },
				lualine_x = { get_attached_formatters, get_attached_linters, get_attached_lsps },
				lualine_y = {
					{
						"encoding",
						show_bomb = true,
					},
					"filetype",
				},
				lualine_z = { "%l/%L (%p%%)", "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = { "branch" },
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = { "mason", "toggleterm", "lazy", "neo-tree" },
		})
	end,
}
