local M = {}

local Tab = {}

--- @class Tab
--- @field id number
--- @field name string
--- @field tele_func function
--- @field available_func function|nil
--- @field failed boolean
--- @field wait_for number|nil
--- @function new create a new tab
function Tab:new(tab, id)
	local name = tab.name or tab[1]
	local tele_func = tab.tele_func or tab[2]
	local o = {
		id = id,
		name = name,
		tele_func = tele_func,
		available_func = tab.available,
		failed = false,
		waiting = false,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

--- @param self Tab
--- @return boolean
function Tab:is_current()
	return M.current_id == self.id
end

--- @return boolean
function Tab:is_available()
	return self.available_func == nil or self.available_func()
end

function Tab:fail()
	self.waiting = false
	self.failed = true
end

function Tab:has_failed()
	return self.failed
end

function Tab:reset_failed()
	self.failed = false
end

function Tab:is_waiting()
	return self.waiting
end

function Tab:stop_waiting()
	self.waiting = false
end

function Tab:start_waiting()
	self.failed = false
	self.waiting = true
end

--- initialize the tabs module
--- @param opts table with the following keys:
-- - tabs: list of tabs
-- - inital_tab: id of the tab to start with
M.init = function(opts)
	for id, t in ipairs(opts.tabs) do
		local tab = Tab:new(t, id)
		M.tab_list[id] = tab
	end
	M.current_id = opts.initial_id
	M.initial_id = opts.initial_id
end

--- list of all tabs
M.tab_list = {}

--- id of the current tab
M.current_id = 0

--- id of the initial tab
M.initial_id = 0

--- get all tabs
--- @return table # list of all tabs
M.all = function()
	return M.tab_list
end

--- get the current tab
M.current = function()
	return M.tab_list[M.current_id]
end

--- get the next tab
--- @return Tab # the next tab
M.next = function()
	M.current_id = M.current_id + 1
	if M.current_id > #M.tab_list then
		M.current_id = 1
	end
	return M.current()
end

--- get the previous tab
--- @return Tab # the previous tab
M.previous = function()
	M.current_id = M.current_id - 1
	if M.current_id < 1 then
		M.current_id = #M.tab_list
	end
	return M.current()
end

M.initial_tab = function()
	M.current_id = M.initial_id
	return M.current()
end

--- get the tab with the given name
--- @param name string the name of the tab
--- @return Tab|nil # the tab with the given name
M.id_by_name = function(name)
	for _, tab in ipairs(M.tab_list) do
		if tab.name == name then
			return tab
		end
	end
	return nil
end

--- set the tab with the given name as the current tab
--- @param name string the name of the tab
--- @return boolean # true if the tab was found, false otherwise
M.set_by_name = function(name)
	local tab = M.id_by_name(name)
	if tab then
		M.current_id = tab.id
		return true
	end

	return false
end

M.set_by_id = function(id)
	M.current_id = id
end

--- get the tab with the given id
--- @param id number the id of the tab
--- @return Tab|nil # the tab with the given id
M.find_by_id = function(id)
	for _, tab in ipairs(M.tab_list) do
		if tab.id == id then
			return tab
		end
	end
	return nil
end

return M
