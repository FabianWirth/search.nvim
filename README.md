# search.nvim

*"**search.nvim** is a Neovim plugin that enhances the functionality of the [Telescope](https://github.com/nvim-telescope/telescope.nvim) plugin by providing a tab-based search experience. It allows you to seamlessly switch between different search modes within the Telescope window using tabs"* - ChatGPT

![example](https://raw.githubusercontent.com/FabianWirth/search.nvim/main/example.gif)

**this plugin is in early development and might have some bugs. You can also expect changes to the configuration api.**

## Features

- **Tab-based Searching**: Easily switch between different search modes, each represented by a tab.
- **Integration with Telescope**: Leverages the power of the Telescope plugin for versatile searching.
- **Customizable Tabs**: Configure the available tabs according to your preferences. (coming soon)
- **keybindings for switching tabs**: switch tabs by configurable keys (coming soon)

## Installation

Install search.nvim using your preferred plugin manager. For example:
```lua
--- lazy nvim
{
    "FabianWirth/search.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" }
}
```

## default tabs
the default tabs are:
- find_files
- git_files
- live_grep

they can be configured in the setup function.

## Usage

### Opening the Tabsearch Window
To open the search.nvim window, use the following command:

```lua
require('search').open()
```
This will activate the default tab and open the Telescope window with the specified layout.
it is also possible to provide a tab_id or tab_name to directly activate a specific tab (id takes precedence over name)
```lua
require('search').open({ tab_id = 2 })
require('search').open({ tab_name = 'Grep' }) -- if multiple tabs are named the same, the first is selected
```

### Switching Tabs
Navigate between tabs using the **`<Tab>`** and **`<S-Tab>`** keys in normal and insert modes. This allows you to switch between different search modes conveniently.

### Customizing Tabs
You can customize the available tabs by modifying the tabs table in the plugin configuration. Each tab should be defined as a Lua table with the following properties:

- name: Display name of the tab.
- tele_func: The Telescope function associated with the tab.
- available (optional): A function to determine if the tab is currently available based on certain conditions.
For example:

```lua
local builtin = require('telescope.builtin')
require("search").setup({
  append_tabs = { -- append_tabs will add the provided tabs to the default ones
    {
      "Commits", -- or name = "Commits"
      builtin.git_commits, -- or tele_func = require('telescope.builtin').git_commits
      available = function() -- optional
        return vim.fn.isdirectory(".git") == 1
      end
    }
  },
  -- its also possible to overwrite the default tabs using the tabs key instead of append_tabs
  tabs = {
    {
		"Files",
		function(opts)
			opts = opts or {}
			if vim.fn.isdirectory(".git") == 1 then
				builtin.git_files(opts)
			else
				builtin.find_files(opts)
			end
		end
    }
  }
})
```

### known issues
- pickers with more-than-average loading time (like lsp related, or http sending pickers) can feel a bit off, since the UI will wait for them to be ready.

## License

This plugin is licensed under the MIT License. See the [LICENSE](https://github.com/FabianWirth/search.nvim?tab=MIT-1-ov-file) file for details.

-------------------------------------------------------------------------------


Happy searching with search.nvim! 🚀
