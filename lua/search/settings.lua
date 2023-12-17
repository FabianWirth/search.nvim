local M = {}

M.default_initial_tab = 1

local builtin = require('telescope.builtin')
M.defaults = {
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
	opts = opts or {}

	-- the deepcopz is needed to avoid the tabs being shared between
	-- between calls of the setup function - not sure if we need this
	-- but it's better to be safe than sorry
	local tabs = vim.deepcopy(M.defaults)
	local initial_tab = M.default_initial_tab

	-- if the user has specified a custom list of tabs, use that instead
	-- of the default
	if opts.tabs ~= nil then
		tabs = opts.tabs
	end

	-- if the user has specified a custom list of tabs to append, append
	-- them to the current list of tabs
	if opts.append_tabs ~= nil then
		for _, tab in ipairs(opts.append_tabs) do
			table.insert(tabs, tab)
		end
	end

	-- if the user has specified a custom initial tab, use that instead
	-- of the default
	if opts.initial_tab ~= nil then
		initial_tab = opts.initial_tab
	end

	require("search.tabs").init({
		tabs = tabs,
		initial_id = initial_tab,
	})
end


return M
