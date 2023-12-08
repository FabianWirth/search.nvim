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

return M;
