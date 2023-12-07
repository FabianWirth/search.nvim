# search.nvim

search.nvim is a Neovim plugin that enhances the functionality of the Telescope plugin by providing a tab-based search experience. It allows you to seamlessly switch between different search modes within the Telescope window using tabs.

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


## Usage

### Opening the Tabsearch Window
To open the search.nvim window, use the following command:

```lua
require('search').open()
```
This will activate the default tab and open the Telescope window with the specified layout and prompt.

### Switching Tabs
Navigate between tabs using the **`<Tab>`** and **`<S-Tab>`** keys in normal and insert modes. This allows you to switch between different search modes conveniently.

### Customizing Tabs
You can customize the available tabs by modifying the tabs table in the plugin configuration. Each tab should be defined as a Lua table with the following properties:
```
id: Unique identifier for the tab.
name: Display name of the tab.
key: Keybinding for quick tab switching.
tele_func: The Telescope function associated with the tab.
available (optional): A function to determine if the tab is currently available based on certain conditions.
```
For example:

```lua
{
  id = 5,
  name = "Custom Search",
  key = "c",
  tele_func = require('telescope.builtin').find_files,
  available = function()
    -- Add custom conditions to enable or disable the tab dynamically
    return true
  end
}
```
## License

This plugin is licensed under the MIT License. See the #[LICENSE](/LICENSE.md) file for details.

-------------------------------------------------------------------------------


Happy searching with search.nvim! 🚀
