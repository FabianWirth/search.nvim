local M = {}

M.initial_tab = 1

local builtin = require('telescope.builtin')
M.tabs = {
	{
		name = "Files",
		tele_func = builtin.find_files,
	},
	{
		name = "Git files",
		tele_func = builtin.git_files,
	},
	{
		name = "grep",
		tele_func = builtin.live_grep,
	},
	{
		name = "symbols",
		tele_func = builtin.lsp_workspace_symbols,
		--- todo: check if the client supports document symbols and not just if there is a client
		available = function()
			local clients = vim.lsp.get_active_clients()
			for _, client in ipairs(clients) do
				if client.server_capabilities.document_symbol then
					return true
				end
			end
			return false
		end
	},
	{
		name = "buffers",
		tele_func = builtin.buffers,
	}
}


return M
