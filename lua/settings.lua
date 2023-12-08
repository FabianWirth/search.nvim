local M = {}

M.initial_tab = 1

local builtin = require('telescope.builtin')
M.tabs = {
	{
		id = 1,
		name = "Files",
		key = "f",
		tele_func = builtin.find_files,
	},
	{
		id = 2,
		name = "Git files",
		key = "b",
		tele_func = builtin.git_files,
	},
	{
		id = 3,
		name = "grep",
		key = "g",
		tele_func = builtin.live_grep,
	},
	{
		id = 4,
		name = "symbols",
		key = "s",
		tele_func = builtin.lsp_workspace_symbols,
		--- todo: check if the client supports document symbols and not just if there is a client
		available = function()
			return true
		end
	}
}


return M
