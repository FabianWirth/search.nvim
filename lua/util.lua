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

return M;
