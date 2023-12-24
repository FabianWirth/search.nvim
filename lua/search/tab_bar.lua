local M = {}

local tabs_module = require("search.tabs")

M.seperator = "|"

M.active_tab_fg = "#000000"
M.active_tab_bg = "#5558b5"
M.active_tab_gui = "bold"

M.failed_tab_fg = "#ff9980"
M.failed_tab_gui = "bold"

M.inactive_tab_fg = "#404040"

M.waiting_tab_fg = "yellow"


M.create = function(conf)
	local buf_id = vim.api.nvim_create_buf(false, true)
	local max_width = conf.width
	local tabline_config = M.make(buf_id, max_width)
	local config = vim.tbl_extend("keep", tabline_config, conf)
	return vim.api.nvim_open_win(buf_id, false, config)
end

M.make = function(buf_id, max_width)
	local collection = tabs_module.current_collection()
	local tabs = collection:all()

	local current_row = ""
	local content = {}
	local hil_groups = {}

	for _, tab in ipairs(tabs) do
		local tab_name = " " .. tab.name .. " "
		local len = #tab_name + #M.seperator

		if #current_row + len > max_width then
			--- we have to add a new row
			table.insert(content, current_row)
			current_row = ""
		end

		local group = "";
		if tab:is_current(collection) then
			group = "ActiveSearchTab"
		end
		if tab:has_failed() then
			group = "FailedSearchTab"
		end
		if not tab:is_available() then
			group = "InactiveSearchTab"
		end
		if tab:is_waiting() then
			group = "WaitingSearchTab"
		end

		if group ~= "" then
			table.insert(hil_groups, {
				s = #current_row,
				e = #current_row + #tab_name,
				r = #content,
				g = group
			})
		end
		current_row = current_row .. tab_name .. M.seperator
	end

	if current_row ~= "" then
		table.insert(content, current_row)
	end

	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, content)
	vim.cmd("hi! ActiveSearchTab guifg=" .. M.active_tab_fg .. " guibg=" .. M.active_tab_bg .. " gui=" .. M.active_tab_gui)
	vim.cmd("hi! FailedSearchTab guifg=" .. M.failed_tab_fg .. " gui=" .. M.failed_tab_gui)
	vim.cmd("hi! InactiveSearchTab guifg=" .. M.inactive_tab_fg)
	vim.cmd("hi! WaitingSearchTab guifg=" .. M.waiting_tab_fg)
	for _, group in ipairs(hil_groups) do
		vim.api.nvim_buf_add_highlight(buf_id, -1, group.g, group.r, group.s, group.e)
	end

	return {
		width = max_width,
		height = #content,
		style = 'minimal',
		focusable = false,
		noautocmd = true,
	}
end


return M
