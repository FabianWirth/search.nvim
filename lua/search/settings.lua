local M = {}

local tabs = require('search.tabs')

M.initial_tab = 1

local builtin = require('telescope.builtin')
M.tabs = {
	{
		"Files",
		builtin.find_files,
	},
	{
		"Git files",
		builtin.git_files,
		available = function()
			return vim.fn.isdirectory(".git") == 1
		end
	},
	{
		"Grep",
		builtin.live_grep,
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
	tabs.init({
		tabs = M.tabs,
		initial_id = M.initial_tab,
	})
end


return M
