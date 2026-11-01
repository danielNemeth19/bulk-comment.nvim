# bulk-comment.nvim

A small plugin to toggle comments on a single line or on a visual selection, with support for line and block comment styles.

## Table of Contents
* [Features](#features)
* [Installation](#installation)
* [Configuration](#configuration)
    * [Using defaults](#using-defaults)
    * [Customization](#customization)
* [Default Mappings](#default-mappings)
* [Behavior](#behavior)
* [Supported languages](#supported-languages)
* [TODO](#todo)

## Features
* toggle a line comment on the current line (normal mode)
* toggle a block comment around a visual selection (visual mode)
* falls back to commenting each selected line individually if the language has no block comment syntax
* languages without line comments (e.g. HTML, CSS) are handled with inline block comments
* keymaps are buffer-local, and only set for supported filetypes

## Installation
### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return {
  {
    "danielNemeth19/bulk-comment.nvim",
    opts = {
      -- See Customization section for options
    },
  },
}
```

## Configuration
### Using defaults
The plugin registers a `FileType` autocommand for all supported languages, so no explicit `ft` is needed. To use the defaults, pass an empty `opts` table:
```lua
return {
  {
    "danielNemeth19/bulk-comment.nvim",
    opts = {},
  },
}
```
Lazy will call `setup()` with the empty table, which is merged with the default config.

Alternatively, set `config = true` to have Lazy call `setup()` without arguments:
```lua
return {
  {
    "danielNemeth19/bulk-comment.nvim",
    config = true,
  },
}
```

See [lazy spec setup](https://lazy.folke.io/spec#spec-setup) for more details.

### Customization
All configuration options currently supported:
```lua
{
  keymaps = {
    line_comment = "<C-q>",  -- normal mode
    block_comment = "<C-q>", -- visual mode
  },
}
```
To change anything, set the corresponding key in `opts`, e.g.:
```lua
return {
  {
    "danielNemeth19/bulk-comment.nvim",
    opts = {
      keymaps = {
        line_comment = "<leader>c",
        block_comment = "<leader>c",
      },
    },
  },
}
```

## Default Mappings
| Mode   | Key     | Action                                  |
| ------ | ------- | --------------------------------------- |
| Normal | `<C-q>` | Toggles comment on the current line     |
| Visual | `<C-q>` | Toggles comment on the selected lines   |

Mappings are buffer-local and only set in buffers with a supported filetype.

## Behavior
### Normal mode
* The current line is commented or uncommented, keeping the original indentation.
* Empty (or whitespace-only) lines are left untouched.
* The cursor moves to the line below, so the mapping can be repeated to work down the file.
* If the language has no line comment syntax (e.g. HTML, CSS, XML), the line is wrapped in a block comment, such as `<!-- line -->`.

### Visual mode
* **Languages with block comments:** the opening and closing symbols are inserted on their own lines, above and below the selection. If the first and last lines of the selection are exactly those symbols, they are removed instead.
* **Languages without block comments** (e.g. Python, Bash): each selected line is toggled individually, like in normal mode.

For example, in Lua:
```lua
local a = 1
local b = 2
```
becomes
```lua
--[=[
local a = 1
local b = 2
]=]
```

## Supported languages
Languages are grouped by comment style. The block comment column decides how visual mode behaves (see [Behavior](#behavior)).

| Line comment | Block comment | Languages |
| ------------ | ------------- | --------- |
| `//`  | `/* */`      | c, cpp, cs, dart, go, java, javascript, javascriptreact, kdl, kotlin, php, rust, scala, swift, typescript, typescriptreact |
| `#`   | -            | bash, dockerfile, elixir, fish, perl, ps1, python, ruby, sh, yaml, zsh |
| `--`  | `/* */`      | sql |
| `--`  | `--[=[ ]=]`  | lua |
| `%`   | `%{ }%`      | matlab |
| `;`   | -            | lisp |
| `"`   | -            | vim |
| -     | `/* */`      | css |
| -     | `<!-- -->`   | html, htmldjango, xml |

The full definitions live in `lua/bulk-comment/config.lua`.
