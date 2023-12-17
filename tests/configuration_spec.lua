local init = require('search.init')
local _tabs = require('search.tabs')
local _settings = require('search.settings')

local eq = assert.are.same

-- for my lsp to stop complaining
local describe = describe
local it = it
local before_each = before_each

describe("can configure search.nvim", function()
	before_each(function()
		_tabs.tab_list = {}
	end)


	it("can use default config", function()
		init.setup()

		local tabs = _tabs.all()
		eq(3, #tabs)
		eq('Files', tabs[1].name)
		eq('Git files', tabs[2].name)
		eq('Grep', tabs[3].name)
	end)

	it("can append a tab using long syntax", function()
		local config = {
			append_tabs = {
				{
					"Custom",
					function() return "custom" end
				}
			}
		}

		init.setup(config)
		eq(4, #_tabs.all())
		eq('Custom', _tabs.all()[4].name)
		eq('custom', _tabs.all()[4].tele_func())
	end)

	it("can append a tab using short syntax", function()
		_tabs.tab_list = {}
		local config = {
			append_tabs = {
				{ "Custom", function() return "custom" end }
			}
		}

		init.setup(config)
		eq(4, #_tabs.all())
		eq('Custom', _tabs.all()[4].name)
		eq('custom', _tabs.all()[4].tele_func())
	end)

	it("can append tab using partially short syntax", function()
		local config = {
			append_tabs = {
				{ "Custom", tele_func = function() return "custom" end }
			}
		}

		init.setup(config)
		eq(4, #_tabs.all())
		eq('Custom', _tabs.all()[4].name)
		eq('custom', _tabs.all()[4].tele_func())
	end)

	it("can append tab using partially short syntax2", function()
		local config = {
			append_tabs = {
				{ name = "Custom", function() return "custom" end }
			}
		}

		init.setup(config)
		eq(4, #_tabs.all())
		eq('Custom', _tabs.all()[4].name)
		eq('custom', _tabs.all()[4].tele_func())
	end)

	it("can define a available function", function()
		local config = {
			tabs = { { "Custom", function() return "custom" end, available = function() return false end } }
		}

		init.setup(config)
		eq(1, #_tabs.all())
		eq('Custom', _tabs.all()[1].name)
		eq('custom', _tabs.all()[1].tele_func())
		eq(false, _tabs.all()[1]:is_available())
	end)

	it("can configure mappings", function()
		local config = {
			mappings = {
				next = '<leader>l',
				prev = '<leader>h',
			}
		}

		init.setup(config)
		eq('<leader>l', _settings.keys.next)
		eq('<leader>h', _settings.keys.prev)
	end)

	it("has default mappings", function()
		init.setup()
		eq('<Tab>', _settings.keys.next)
		eq('<S-Tab>', _settings.keys.prev)
	end)
end)
