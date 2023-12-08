local M = {}

local util = require('util')

--- opens the tab window and anchors it to the telescope window
local tab_window = function(telescope_win_id)
	-- Calculate the height of Telescope's search fields
	local telescope_width = vim.fn.winwidth(telescope_win_id) -- Adjust this based on Telescope's window ID

	-- Define the content for the floating window
	local content_s = ""

	local active_symbol_start = '> '
	local active_symbol_end = ' <'
	local inactive_symbol_start = '  '
	local inactive_symbol_end = '  '
	local separator = '|'

	for _, tab in ipairs(require("settings").tabs) do
		local tab_name = tab.name
		local start_symbol = tab.id == M.active_tab and active_symbol_start or inactive_symbol_start
		local end_symbol = tab.id == M.active_tab and active_symbol_end or inactive_symbol_end
		content_s = content_s .. start_symbol .. tab_name .. end_symbol .. separator
	end

	-- Remove trailing separator
	content_s = content_s:sub(1, -(#separator))


	local content = { content_s }

	-- Set up the floating window configuration
	local config = {
		relative = 'win',
		win = telescope_win_id,
		width = telescope_width,
		height = #content,
		col = 0,
		row = 2, -- Set the row position based on Telescope's height
		style = 'minimal',
		focusable = false,
		noautocmd = true,
	}

	-- Create a new buffer
	local new_buf = vim.api.nvim_create_buf(false, true)

	-- Set the content of the new buffer
	vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, content)

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

local set_keymap = function()
	-- now we bind our tab key to the next tab
	local opts = { noremap = true, silent = true }
	local cmd = "<cmd>lua require('search').next_tab()<CR>"
	local cmd_p = "<cmd>lua require('search').previous_tab()<CR>"
	vim.api.nvim_buf_set_keymap(0, 'n', "<Tab>", cmd, opts)
	vim.api.nvim_buf_set_keymap(0, 'i', "<Tab>", cmd, opts)
	vim.api.nvim_buf_set_keymap(0, 'n', "<S-Tab>", cmd_p, opts)
	vim.api.nvim_buf_set_keymap(0, 'i', "<S-Tab>", cmd_p, opts)
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
		layout_strategy = "vertical",
	})
	-- find a better way to do this
	-- we might need to wait for the telescope window to open
	util.do_when(function()
			return M.opened_on_win ~= vim.api.nvim_get_current_win()
		end,
		function()
			local current_win_id = vim.api.nvim_get_current_win()
			set_keymap()

			-- now we set the prompt to the one we had before
			vim.api.nvim_feedkeys(prompt, 't', true)

			vim.schedule(function()
				tab_window(current_win_id)
			end)
		end,
		1000 -- wait for 1 second at most
	)
end

--- the prompt that was used before
M.current_prompt = ""

--- the currently active tab id
M.active_tab = 1

--- switches to the next tab, preserving the prompt
--- only switches to tabs that are available
M.next_tab = function()
	local current_tab = M.active_tab
	local tabs = require('settings').tabs

	local next_tab = nil
	while next_tab == nil do
		current_tab = current_tab + 1
		if current_tab > #tabs then
			current_tab = 1
		end
		if current_tab == M.active_tab then
			-- we have looped through all tabs and none is available
			-- so we error out
			error("No tab available")
		end

		local tab = tabs[current_tab]
		if tab.available == nil or tab.available() then
			next_tab = tab
			break
		end
	end

	M.active_tab = next_tab.id

	M.remember_prompt()
	M.open_internal()
end

--- switches to the previous tab, preserving the prompt
M.previous_tab = function()
	local current_tab = M.active_tab
	local tabs = require('settings').tabs

	for _ = 1, #tabs do
		current_tab = current_tab - 1
		if current_tab < 1 then
			current_tab = #tabs
		end

		local tab = tabs[current_tab]
		if tab.available == nil or tab.available() then
			M.active_tab = tab.id
			break
		end
	end

	M.remember_prompt()
	M.open_internal()
end

--- remembers the prompt that was used before
M.remember_prompt = function()
	local current_prompt = vim.api.nvim_get_current_line()
	local without_prefix = string.sub(current_prompt, 3)
	M.current_prompt = without_prefix
end

--- sets the active tab to the given tab id
M.set_tab = function(tab_id)
	M.active_tab = tab_id
end

--- returns the currently active tab
M.get_active_tab = function()
	local tabs = require('settings').tabs
	for _, tab in ipairs(tabs) do
		if tab.id == M.active_tab then
			return tab
		end
	end
end

--- opens the telescope window with the current prompt
M.open_internal = function()
	if M.get_active_tab() == nil then
		M.active_tab = 1
	end
	local active_tab = M.get_active_tab()

	open_telescope(active_tab, M.current_prompt)
end

--- resets the state of the search module
M.reset = function()
	M.current_prompt = ""
	M.active_tab = 1
end

M.opened_on_win = -1

--- opens the telescope window with the current prompt
--- this is the function that should be called from the outside
M.open = function()
	M.opened_on_win = vim.api.nvim_get_current_win()
	print(M.opened_on_win)
	M.reset()
	M.open_internal()
end

return M
