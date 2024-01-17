local M = {}

local tabs = require("search.tabs")
local settings = require("search.settings")

--- the amount of milliseconds to wait between checks
M.await_time = 10

--- runs a function when a condition is met
--- @param condition function a function that returns a boolean
--- @param callback function a function that is called when the condition is met
--- @param max_ms number the maximum amount of milliseconds to wait
--- @param fail_callback function a function that is called when the condition is not met in time
--- @return any the return value of the callback
M.do_when = function(condition, callback, max_ms, fail_callback)
	if max_ms == nil then
		max_ms = 1000
	end

	while max_ms > 0 do
		if condition() then
			return callback()
		end
		vim.wait(M.await_time)
		max_ms = max_ms - M.await_time
	end

	if fail_callback ~= nil then
		return fail_callback()
	end
end


--- binds the tab key to the next tab
--- and the shift tab key to the previous tab
M.set_keymap = function()
	-- now we bind our tab key to the next tab
	local opts = { noremap = true, silent = true }
	local cmd = "<cmd>lua require('search').next_tab()<CR>"
	local cmd_p = "<cmd>lua require('search').previous_tab()<CR>"


  local function set_keymap(keymap, cmd)
    if type(keymap) == "string" then
      vim.api.nvim_buf_set_keymap(0, 'n', keymap, cmd, opts)
      vim.api.nvim_buf_set_keymap(0, 'i', keymap, cmd, opts)
    else
      for _, value in ipairs(keymap) do
        vim.api.nvim_buf_set_keymap(0, value[2], value[1], cmd, opts)
      end
    end
  end

  set_keymap(settings.keys.next, cmd)
  set_keymap(settings.keys.prev, cmd_p)
  end

--- switches to the next available tab
--- @return Tab # the next available tab
M.next_available = function()
	local start = tabs.current().id
	while true do
		local tab = tabs.next()
		if tab:is_available() then
			return tab
		end
		if tab.id == start then
			return tab
		end
	end
end

--- switches to the previous available tab
--- @return Tab # the previous available tab
M.previous_available = function()
	local start = tabs.current().id
	while true do
		local tab = tabs.previous()
		if tab:is_available() then
			return tab
		end
		if tab.id == start then
			return tab
		end
	end
end
return M;
