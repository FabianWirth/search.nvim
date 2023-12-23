
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

	-- this enables the user to define the function as second argument
	-- even if the first argument is named as name
	if name ~= nil and tab[1] ~= nil and type(tab[1]) == "function" then
		tele_func = tab[1]
	end

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
function Tab:is_current(collection)
	return collection:current_tab() == self.id
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

return Tab
