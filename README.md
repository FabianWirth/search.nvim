# search.nvim

**search.nvim** is a Neovim plugin that enhances the functionality of the Telescope plugin by providing a tab-based search experience. It allows you to seamlessly switch between different search modes within the Telescope window using tabs.
![example](https://github.com/FabianWirth/search.nvim/blob/main/example.gif)

**this plugin is in pre-alpha state**

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
it is also possible to provide a tab_id to directly activate a specific tab
```lua
require('search').open({ tab_id = 2 })
```

### Switching Tabs
Navigate between tabs using the **`<Tab>`** and **`<S-Tab>`** keys in normal and insert modes. This allows you to switch between different search modes conveniently.

### Customizing Tabs
You can customize the available tabs by modifying the tabs table in the plugin configuration. Each tab should be defined as a Lua table with the following properties:
```
name: Display name of the tab.
tele_func: The Telescope function associated with the tab.
available (optional): A function to determine if the tab is currently available based on certain conditions.
```
For example:

```lua
require("search").setup({
  append_tabs = { -- append_tabs will add the provided tabs to the default ones
    {
      name = "Commits",
      tele_func = require('telescope.builtin').git_commits,
      available = function()
        return vim.fn.isdirectory(".git") == 1
      end
    }
  }
})
```
## License

This plugin is licensed under the MIT License. See the [LICENSE](/LICENSE.md) file for details.

-------------------------------------------------------------------------------


Happy searching with search.nvim! 🚀
