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
    opts = {
        export_on_save = true,
    }
}
```

## Default Options

The default options are:
```lua
{
    export_on_save = false,
}
```

## Usage

Add the file path to the code block you want to write to.

````markdown
Simple Hello World
This is going to be saved to hello_world.lua

```lua file="hello_world.lua"
function main()
    print("Hello, World!")
end

main()
```
````

Then Export the code blocks to files.

```vim
lua require('literate_markdown').export_code_blocks()
```
