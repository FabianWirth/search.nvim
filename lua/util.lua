local M = {}

--- the amount of milliseconds to wait between checks
M.await_time = 10

--- runs a function when a condition is met
--- @param condition function a function that returns a boolean
--- @param callback function a function that is called when the condition is met
--- @param max_ms number the maximum amount of milliseconds to wait
--- @return any the return value of the callback
M.do_when = function(condition, callback, max_ms)
	if condition() then
		return callback()
	else
		vim.defer_fn(function()
			max_ms = max_ms - M.await_time
			if max_ms < 0 then
				return
			end
			return M.do_when(condition, callback, max_ms)
		end, M.await_time)
	end
end


--- binds the tab key to the next tab
--- and the shift tab key to the previous tab
M.set_keymap = function()
	-- now we bind our tab key to the next tab
	local opts = { noremap = true, silent = true }
	local cmd = "<cmd>lua require('search').next_tab()<CR>"
	local cmd_p = "<cmd>lua require('search').previous_tab()<CR>"
	vim.api.nvim_buf_set_keymap(0, 'n', "<Tab>", cmd, opts)
	vim.api.nvim_buf_set_keymap(0, 'i', "<Tab>", cmd, opts)
	vim.api.nvim_buf_set_keymap(0, 'n', "<S-Tab>", cmd_p, opts)
	vim.api.nvim_buf_set_keymap(0, 'i', "<S-Tab>", cmd_p, opts)
end

M.next_available = function(current_tab, tabs, start)
	if start == nil then
		start = current_tab
	end

	if current_tab == #tabs then
		current_tab = 1
	else
		current_tab = current_tab + 1
	end

	if tabs[current_tab].available == nil or tabs[current_tab].available() then
		return current_tab
	elseif current_tab == start then
		return current_tab
	else
		return M.next_available(current_tab, tabs, start)
	end
end

M.previous_available = function(current_tab, tabs, start)
	if start == nil then
		start = current_tab
	end

	if current_tab == 1 then
		current_tab = #tabs
	else
		current_tab = current_tab - 1
	end

	if tabs[current_tab].available == nil or tabs[current_tab].available() then
		return current_tab
	elseif current_tab == start then
		return current_tab
	else
		return M.previous_available(current_tab, tabs, start)
	end
end

M.find_by_id = function(id, items)
	for i, item in ipairs(items) do
		if i == id then
			return item
		end
	end
	error("Could not find item with id " .. id)
end

--- makes the tabline for the given tabs
--- @param tabs table a list of tabs
--- @param active_tab number the id of the active tab
M.make_tabline = function(tabs, active_tab, buf_id)
	local content_s = ""

	local separator = '|'

	local active_start = 0
	local active_end = 0
	local total_len = 0

	local inactive_tabs = {}

	for id, tab in ipairs(tabs) do
		local tab_name = " " .. tab.name .. " "
		content_s = content_s .. tab_name .. separator
		local len = #tab_name + #separator
		if id == active_tab then
			active_start = total_len
			active_end = active_start + #tab_name
		end
		if tab.available ~= nil and not tab.available() then
			table.insert(inactive_tabs, {
							s = total_len,
							e = total_len + #tab_name,
			})
		end
		total_len = total_len + len
	end

	-- Remove trailing separator
	content_s = content_s:sub(1, -(#separator))
	local content = { content_s }

	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, content)
	vim.cmd("hi ActiveSearchTab guifg=#000000 guibg=#5558b5 gui=bold")
	vim.cmd("hi InactiveSearchTab guifg=#404040")
	vim.api.nvim_buf_add_highlight(buf_id, -1, "ActiveSearchTab", 0, active_start, active_end)
	for _, tab in ipairs(inactive_tabs) do
		vim.api.nvim_buf_add_highlight(buf_id, -1, "InactiveSearchTab", 0, tab.s, tab.e)
	end
end
return M;
