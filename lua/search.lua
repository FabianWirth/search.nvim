local M = {}

local util = require('util')
local settings = require('settings')

--- opens the tab window and anchors it to the telescope window
--- @param telescope_win_id number the id of the telescope window
--- @return nil
local tab_window = function(telescope_win_id)
	-- Calculate the height of Telescope's search fields
	local telescope_width = vim.fn.winwidth(telescope_win_id) -- Adjust this based on Telescope's window ID

	-- Define the content for the floating window

	-- Set up the floating window configuration
	local config = {
		relative = 'win',
		win = telescope_win_id,
		width = telescope_width,
		height = 1,
		col = 0,
		row = 2, -- Set the row position based on Telescope's height
		style = 'minimal',
		focusable = false,
		noautocmd = true,
	}

	-- Create a new buffer
	local new_buf = vim.api.nvim_create_buf(false, true)

	-- write the tabline to the buffer
	util.make_tabline(settings.tabs, M.active_tab, new_buf)

	local new_win = vim.api.nvim_open_win(new_buf, false, config)

	local tele_buf = vim.api.nvim_get_current_buf()

	-- make this buffer disappear when we close the telescope window
	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = tele_buf,
		group = "PickerInsert",
		nested = true,
		once = true,
		callback = function()
			vim.api.nvim_win_close(new_win, true)
		end,
	})
end


--- opens the telescope window and sets the prompt to the one that was used before
--- @param tab table the table that contains the information about the tab
--- @param prompt string the prompt that should be set
local open_telescope = function(tab, prompt)
	-- since some telescope functions are linked to lsp, we need to make sure that we are in the correct buffer
	-- this would become an issue if we are coming from another tab
	if vim.api.nvim_get_current_win() ~= M.opened_on_win then
		vim.api.nvim_set_current_win(M.opened_on_win)
	end

	-- then we spawn the telescope window
	local c = pcall(tab.tele_func, {
		prompt_title = tab.name,
	})
	if not c then
		print(vim.inspect(tab))
		print("Could not open telescope window")
		print(vim.inspect(c))
	end
	-- find a better way to do this
	-- we might need to wait for the telescope window to open
	util.do_when(function()
			return M.opened_on_win ~= vim.api.nvim_get_current_win()
		end,
		function()
			local current_win_id = vim.api.nvim_get_current_win()
			util.set_keymap()

			-- now we set the prompt to the one we had before
			vim.api.nvim_feedkeys(prompt, 't', true)

			vim.defer_fn(function()
				-- we need to wait for the prompt to be set
				tab_window(current_win_id)
			end, 4)
		end,
		2000 -- wait for 2 second at most
	)
end

--- the prompt that was used before
M.current_prompt = ""

--- the currently active tab id
M.active_tab = 1

--- switches to the next tab, preserving the prompt
--- only switches to tabs that are available
M.next_tab = function()
	M.active_tab = util.next_available(M.active_tab, settings.tabs)

	M.remember_prompt()
	M.open_internal()
end

--- switches to the previous tab, preserving the prompt
M.previous_tab = function()
	M.active_tab = util.previous_available(M.active_tab, settings.tabs)

	M.remember_prompt()
	M.open_internal()
end

--- remembers the prompt that was used before
M.remember_prompt = function()
	local current_prompt = vim.api.nvim_get_current_line()
	-- removing the prefix, by cutting the length
	local without_prefix = string.sub(current_prompt, M.prefix_len + 1) 
	M.current_prompt = without_prefix
end

--- returns the currently active tab
M.get_active_tab = function()
	return util.find_by_id(M.active_tab, settings.tabs)
end

--- opens the telescope window with the current prompt
M.open_internal = function()
	local active_tab = M.get_active_tab()
	if util.cannot_open(active_tab) then
		return M.next_tab()
	end

	open_telescope(active_tab, M.current_prompt)
end

--- resets the state of the search module
M.reset = function(to_tab)
	M.active_tab = to_tab or settings.initial_tab
	M.current_prompt = ""
	M.opened_on_win = -1
end

-- the prefix can be defined in the telescope config, so we need to read
-- it's length in the open() method. 
-- @todo: maybe do the reading somewhere else, to avoid doing so multiple times
M.prefix_len = 3

--- opens the telescope window with the current prompt
--- this is the function that should be called from the outside
M.open = function(opts)
  local prefix = require("telescope.config").values.prompt_prefix or 3
  M.prefix_len = #prefix
	M.reset(opts and opts.tab_id)
	M.opened_on_win = vim.api.nvim_get_current_win()
	M.open_internal()
end

-- configuration
M.setup = function(opts)
	settings.setup(opts)
end

return M
