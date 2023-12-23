local M = {}

TabCollection = require("search.tabs.collection")
---

M.collections = {}

M.current_collection_id = "default"

--- get all tabs
--- @return table # list of all tabs
M.all = function()
	return M.current_collection():all()
end


M.current_collection = function()
	return M.collections[M.current_collection_id]
end

--- initialize the tabs module
--- @param opts table with the following keys:
-- - tabs: list of tabs
-- - inital_tab: id of the tab to start with
M.init = function(opts)
	M.collections["default"] = TabCollection:new(opts)
	for id, collection_config in pairs(opts.collections) do
		local collection = TabCollection:new(collection_config)
		M.collections[id] = collection
	end
end

--- get the current tab
M.current = function()
	return M.current_collection():current()
end


--- get the next tab
--- @return Tab # the next tab
M.next = function()
	return M.current_collection():next()
end

--- get the previous tab
--- @return Tab # the previous tab
M.previous = function()
	return M.current_collection():previous()
end

M.initial_tab = function()
	return M.current_collection():initial_tab()
end

--- get the tab with the given name
--- @param name string the name of the tab
--- @return Tab|nil # the tab with the given name
M.id_by_name = function(name)
	return M.current_collection():id_by_name(name)
end

--- set the tab with the given name as the current tab
--- @param name string the name of the tab
--- @return boolean # true if the tab was found, false otherwise
M.set_by_name = function(name)
	return M.current_collection():set_by_name(name)
end

M.set_by_id = function(id)
	M.current_collection():set_current(id)
end

--- get the tab with the given id
--- @param id number the id of the tab
--- @return Tab|nil # the tab with the given id
M.find_by_id = function(id)
	return M.current_collection():find_by_id(id)
end

return M
