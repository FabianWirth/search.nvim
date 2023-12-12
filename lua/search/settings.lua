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
		available = function()
			return vim.fn.isdirectory(".git") == 1
		end
	},
	{
		name = "Grep",
		tele_func = builtin.live_grep,
	},
}

M.setup = function(opts)
	if opts == nil then
		return
	end
	if opts.tabs ~= nil then
		M.tabs = opts.tabs
	end
	if opts.append_tabs ~= nil then
		for _, tab in ipairs(opts.append_tabs) do
			table.insert(M.tabs, tab)
		end
	end
	if opts.initial_tab ~= nil then
		M.initial_tab = opts.initial_tab
	end
end


return M
