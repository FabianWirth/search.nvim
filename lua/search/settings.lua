local M = {}

M.default_initial_tab = 1

M.initialized = false

M.default_keys = {
	next = { { "<Tab>", "n" }, { "<Tab>", "i" } },
	prev = { { "<S-Tab>", "n" }, { "<S-Tab>", "i" } },
}

M.keys = vim.deepcopy(M.default_keys)

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
	local collections = {}

	-- if the user has specified a custom list of tabs, use that instead
	-- of the default
	if opts.tabs ~= nil then
		tabs = opts.tabs
	end

	if opts.collections ~= nil then
		collections = opts.collections
	end

	-- if the user has specified a custom list of tabs to append, append
	-- them to the current list of tabs
	if opts.append_tabs ~= nil then
		for _, tab in ipairs(opts.append_tabs) do
			table.insert(tabs, tab)
		end
	end

	M.keys = vim.deepcopy(M.default_keys)
	if opts.mappings ~= nil then
		if opts.mappings.next ~= nil then
			M.keys.next = opts.mappings.next
		end
		if opts.mappings.prev ~= nil then
			M.keys.prev = opts.mappings.prev
		end
	end

	-- if the user has specified a custom initial tab, use that instead
	-- of the default
	if opts.initial_tab ~= nil then
		initial_tab = opts.initial_tab
	end

	require("search.tabs").init({
		tabs = tabs,
		collections = collections,
		initial_id = initial_tab,
	})

	M.initialized = true
end


return M
