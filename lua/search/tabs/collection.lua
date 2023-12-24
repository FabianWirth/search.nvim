
local Tab = require('search.tabs.tab')

local TabCollection = {}

function TabCollection:new(opts)
	local tab_list = {}
	for id, t in ipairs(opts.tabs) do
		local tab = Tab:new(t, id)
		tab_list[id] = tab
	end
	local id = opts.initial_tab or 1

	local o = {
		tab_list = tab_list,
		current_id = id,
		initial_id = id,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function TabCollection:all()
	return self.tab_list
end

function TabCollection:current_tab()
	return self.current_id
end

--- get the current tab
function TabCollection:current()
	return self.tab_list[self.current_id]
end

function TabCollection:set_current(id)
	self.current_id = id
end

--- get the next tab
--- @return Tab # the next tab
function TabCollection:next()
	self.current_id = self.current_id + 1
	if self.current_id > #self.tab_list then
		self.current_id = 1
	end
	return self:current()
end

--- get the previous tab
--- @return Tab # the previous tab
function TabCollection:previous()
	self.current_id = self.current_id - 1
	if self.current_id < 1 then
		self.current_id = #self.tab_list
	end
	return self:current()
end

function TabCollection:initial_tab()
	self.current_id = self.initial_id
	return self:current()
end

--- get the tab with the given name
--- @param name string the name of the tab
--- @return Tab|nil # the tab with the given name
function TabCollection:id_by_name(name)
	for _, tab in ipairs(self.tab_list) do
		if tab.name == name then
			return tab
		end
	end
	return nil
end

--- set the tab with the given name as the current tab
--- @param name string the name of the tab
--- @return boolean # true if the tab was found, false otherwise
function TabCollection:set_by_name(name)
	local tab = self:id_by_name( name)
	if tab then
		self.current_id = tab.id
		return true
	end

	return false
end

function TabCollection:set_by_id(id)
	self.current_id = id
end

--- get the tab with the given id
--- @param id number the id of the tab
--- @return Tab|nil # the tab with the given id
function TabCollection:find_by_id(id)
	for _, tab in ipairs(self.tab_list) do
		if tab.id == id then
			return tab
		end
	end
	return nil
end

return TabCollection
