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
		"folke/todo-comments.nvim",
	},
	config = function()
		-- Project-wide TODO/FIX/HACK counts. todos-lualine restarted a ripgrep over the
		-- whole cwd on nearly every statusline redraw (every second and on each cursor
		-- move), which keeps a core busy in large repos. Search only on start, after a
		-- save and when the cwd changes.
		local todo_order = { "TODO", "FIX", "HACK" }
		local todo_status = ""
		local todo_started, todo_searching, todo_pending = false, false, false

		local function refresh_todos()
			if todo_searching then
				todo_pending = true
				return
			end
			todo_searching = true
			local keywords_cfg = require("todo-comments.config").options.keywords
			local keywords = {}
			for _, kw in ipairs(todo_order) do
				table.insert(keywords, kw)
				vim.list_extend(keywords, (keywords_cfg[kw] or {}).alt or {})
			end
			require("todo-comments.search").search(function(results)
				local counts = {}
				for _, item in ipairs(results) do
					counts[item.tag] = (counts[item.tag] or 0) + 1
				end
				-- Fixed todo_order so segments keep their position and witdh between refreshes.
				local parts = {}
				for _, kw in ipairs(todo_order) do
					if counts[kw] then
						table.insert(parts, ((keywords_cfg[kw] or {}).icon or (kw .. ": ")) .. counts[kw])
					end
				end
				todo_status = table.concat(parts, " ")
				todo_searching = false
				if todo_pending then
					todo_pending = false
					refresh_todos()
				end
			end, { keywords = table.concat(keywords, ","), disable_not_found_warnings = true })
		end

		-- todo-comments finishes its setup after VimEnter, so the first search starts
		-- from the first statusline redraw after that.
		local function todos_component()
			if not todo_started and require("todo-comments.config").loaded then
				todo_started = true
				refresh_todos()
			end
			return todo_status
		end

		vim.api.nvim_create_autocmd({ "BufWritePost", "DirChanged" }, {
			group = vim.api.nvim_create_augroup("lualine_todos", { clear = true }),
			callback = function()
				if todo_started then
					refresh_todos()
				end
			end,
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
