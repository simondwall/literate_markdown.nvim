# literate_markdown.nvim

## Features

- Write code from markdown code blocks to files

## Installation

```lua
{ 
    "simondwall/literate_markdown.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    opts = {}
}
```

## Usage

Add the file path to the code block you want to write to.

````markdown
Install literate_markdown.nvim.

```lua file="lua/user/plugins.lua"
require('lazy').setup({
    { "simondwall/literate_markdown.nvim", opts = {} }
})
```
````

Then Export the code blocks to files.

```vim
lua require('literate_markdown').export_code_blocks()
```
