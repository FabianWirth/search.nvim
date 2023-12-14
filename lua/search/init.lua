local M = {}

local util = require('search.util')
local settings = require('search.settings')
local tab_bar = require('search.tab_bar')
local tabs = require('search.tabs')


--- opens the tab window and anchors it to the telescope window
--- @param telescope_win_id number the id of the telescope window
--- @return nil
local tab_window = function(telescope_win_id)
	-- the width of the prompt
	local telescope_width = vim.fn.winwidth(telescope_win_id)

	-- if the telescope window is closed, we exit early
	-- this can happen when the user holds down the tab key
	if telescope_width == -1 then
		return
	end

	-- create the tab bar window, anchoring it to the telescope window
	local tab_bar_win = tab_bar.create({
		width = telescope_width,
		relative = 'win',
		win = telescope_win_id,
		col = 0,
		row = 2,
	})

	-- make this window disappear when the telescope window is closed
	local tele_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = tele_buf,
		nested = true,
		once = true,
		callback = function()
			vim.api.nvim_win_close(tab_bar_win, true)
		end,
	})
end


--- opens the telescope window and sets the prompt to the one that was used before
local open_telescope = function()
	M.busy = true
	local tab = tabs.current()
	local prompt = M.current_prompt

	-- since some telescope functions are linked to lsp, we need to make sure that we are in the correct buffer
	-- this would become an issue if we are coming from another tab
	if vim.api.nvim_get_current_win() ~= M.opened_on_win then
		vim.api.nvim_set_current_win(M.opened_on_win)
	end
	tab:start_waiting()

	-- then we spawn the telescope window
	local success = pcall(tab.tele_func, {
		prompt_title = tab.name,
	})

	-- this (only) happens, if the telescope function actually errors out.
	-- if the telescope window does not open without error, this is not handled here
	if not success then
		M.busy = false
		tab:fail()
		M.continue_tab(false)
		return
	end


	-- find a better way to do this
	-- we might need to wait for the telescope window to open
	util.do_when(function()
			-- wait for the window change
			return M.opened_on_win ~= vim.api.nvim_get_current_win()
		end,
		function()
			tab:stop_waiting()
			local current_win_id = vim.api.nvim_get_current_win()
			util.set_keymap()

			-- now we set the prompt to the one we had before
			vim.api.nvim_feedkeys(prompt, 't', true)

			vim.defer_fn(function()
				-- we need to wait for the prompt to be set
				tab_window(current_win_id)
				M.busy = false
			end, 4)
		end,
		2000, -- wait for 2 second at most
		function()
			M.busy = false
			tab:fail()
			M.continue_tab(false)
		end
	)
end

--- the prompt that was used before
M.current_prompt = ""

M.direction = "next"

M.busy = false

M.continue_tab = function(remember)
	if M.direction == "next" then
		M.next_tab(remember)
	else
		M.previous_tab(remember)
	end
end

--- switches to the next tab, preserving the prompt
--- only switches to tabs that are available
M.next_tab = function(remember)
	remember = remember == nil and true or remember
	M.direction = "next"

	if M.busy then
		return
	end
	util.next_available()

	if remember then
		M.remember_prompt()
	end

	open_telescope()
end

--- switches to the previous tab, preserving the prompt
M.previous_tab = function(remember)
	remember = remember == nil and true or remember
	M.direction = "previous"

	if M.busy then
		return
	end
	util.previous_available()

	if remember then
		M.remember_prompt()
	end

	open_telescope()
end

--- remembers the prompt that was used before
M.remember_prompt = function()
	local current_prompt = vim.api.nvim_get_current_line()
	-- removing the prefix, by cutting the length
	local without_prefix = string.sub(current_prompt, M.prefix_len + 1)
	M.current_prompt = without_prefix
end

--- resets the state of the search module
M.reset = function(opts)
	opts = opts or {}
	if opts.tab_id then
		tabs.set_by_id(opts.tab_id)
	elseif opts.tab_name then
		tabs.set_by_name(opts.tab_name)
	else
		tabs.initial_tab()
	end

	M.current_prompt = ""
	M.opened_on_win = -1
end

-- the prefix can be defined in the telescope config, so we need to read
-- it's length in the open() method.
-- @todo: maybe do the reading somewhere else, to avoid doing so multiple times
M.prefix_len = 2

M.opened_on_win = -1

--- opens the telescope window with the current prompt
--- this is the function that should be called from the outside
M.open = function(opts)
	local prefix = require("telescope.config").values.prompt_prefix or "> "
	M.prefix_len = #prefix

	M.reset(opts)
	M.opened_on_win = vim.api.nvim_get_current_win()
	M.busy = true
	open_telescope()
end

-- configuration
M.setup = function(opts)
	settings.setup(opts)
end

return M
