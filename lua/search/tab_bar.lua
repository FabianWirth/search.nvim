local M = {}

local tabs_module = require("search.tabs")

M.seperator = "|"

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
	-- Other highlight groups can be found at https://neovim.io/doc/user/syntax.html#%3Ahighlight
	vim.api.nvim_set_hl(0, 'ActiveSearchTab', vim.api.nvim_get_hl(0, {name="IncSearch"}))
	vim.api.nvim_set_hl(0, 'FailedSearchTab', vim.api.nvim_get_hl(0, {name="Error"}))
	vim.api.nvim_set_hl(0, 'InactiveSearchTab', vim.api.nvim_get_hl(0, {name="Conceal"}))
	vim.api.nvim_set_hl(0, 'WaitingSearchTab', vim.api.nvim_get_hl(0, {name="PmenuKind"}))
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
