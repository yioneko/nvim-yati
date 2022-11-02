# nvim-yati

Yet another tree-sitter indent plugin for Neovim.

This plugin was originally created when the experience of builtin indent module of [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) was still terrible. Now since it has improved a lot with better community support, this plugin **should be no longer needed** if the upstream one already satisfies you.

If you are still frustrated with the 'official' indent module or interested in this plugin, welcome to provide feedback or submit any issues. Take a glance at [features](#features) to learn about the differences.

<details>
  <summary>
    <b>Supported languages</b>
  </summary>

- C/C++
- CSS
- GraphQL
- HTML
- Javascript/Typescript (jsx and tsx are also supported)
- JSON
- Lua
- Python
- Rust
- TOML

</details>

More languages could be supported by [setup](#setup) or adding config files to [configs/](lua/nvim-yati/configs) directory.

## Compatibility

This plugin is always developed based on latest neovim and nvim-treesitter. Please consider upgrading them if there is any compatibility issue.

The plugin has been completely rewritten since `legacy` tag. Use that if you prefer not migrating to the current version for some reason.

## Installation

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({ "yioneko/nvim-yati", tag = "*", requires = "nvim-treesitter/nvim-treesitter" })
```

[vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug "nvim-treesitter/nvim-treesitter"
Plug "yioneko/nvim-yati", { 'tag': '*' }
```

## Setup

The module is **required** to be enabled to work:

```lua
require("nvim-treesitter.configs").setup {
  yati = {
    enable = true,
    -- Disable by languages, see `Supported languages`
    disable = { "python" },

    -- Whether to enable lazy mode (recommend to enable this if bad indent happens frequently)
    default_lazy = true,

    -- Determine the fallback method used when we cannot calculate indent by tree-sitter
    --   "auto": fallback to vim auto indent
    --   "asis": use current indent as-is
    --   "cindent": see `:h cindent()`
    -- Or a custom function return the final indent result.
    default_fallback = "auto"
  },
  indent = {
    enable = false -- disable builtin indent module
  }
}
```

If you want to use the indent module simultaneously, disable the indent module for languages to be handled by this plugin.

```lua
require("nvim-treesitter.configs").setup {
  indent = {
    enable = true,
    disable = { "html", "javascript" }
  },
  -- And optionally, disable the conflict warning emitted by plugin
  yati = {
    suppress_conflict_warning = true,
  },
}
```

Example for a more customized setup:

```lua
local get_builtin = require("nvim-yati.config").get_builtin
-- This is just an example, not recommend to do this since the result is unpredictable
local js_overrides = vim.tbl_deep_extend("force", get_builtin("javascript"), {
  lazy = false,
  fallback = function() return -1 end,
  nodes = {
    ["if_statement"] = { "scope" }, -- set attributes by node
  },
  handlers = {
    on_initial = {},
    on_travers = {
      function(ctx) return false end, -- set custom handlers
    }
  }
})

require("nvim-treesitter.configs").setup {
  yati = {
    enable = true,
    disable = { "python" },
    default_lazy = false,
    default_fallback = function() return -1 end, -- provide custom fallback indent method
    overrides = {
      javascript = js_overrides -- override config by language
    }
  }
}
```

More technical details goes there (**highly unstable**): [CONFIG.md](./CONFIG.md).

## Features

- Fast, match node on demand by implementing completely in Lua, compared to executing scm query on the whole tree on every indent calculation.
- Could be faster and more context aware if `lazy` enabled, see `default_lazy` option. This is specifically useful if the surrounding code doesn't obey indent rules:

  ```lua
  function fun()
    if abc then
                  if cbd then
                    a() -- new indent will goes here even if the parent node indent wrongly
                  end
    end
  end
  ```

- Fallback indent method support, and I'm planning to create an accompanying regex-based indent plugin to support saner fallback indent calculation.
- Support indent in injection region. See [sample.html](tests/fixtures/html/sample.html) for example.
- [Tests](tests/fixtures) covered and handles much more edge cases. Refer samples in that directory for what the indentation would be like. The style is slightly opinionated as there is no actual standard, but customization is still possible.
- Support for custom handlers to deal with complex scenarios. This plugin relies on dedicated handlers to fix many edge cases like the following one:

  ```python
  if True:
    pass
    else: # should auto dedent <-
          # the parsed tree is broken here and cannot be handled by tree-sitter
  ```

## Notes

- The calculation result heavily relies on the correct tree-sitter parsing of the code. I'd recommend using plugins like [nvim-autopairs](https://github.com/windwp/nvim-autopairs) or [luasnip](https://github.com/L3MON4D3/LuaSnip) to keep the syntax tree error-free while editing. This should avoid most of the wrong indent calculations.
- I mainly write javascript so other languages may not receive better support than it, and bad cases for other languages are generally expected. Please create issues for them if possible.

## Credits

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for initial aspiration and test cases.
- [chfritz/atom-sane-indentation](https://github.com/chfritz/atom-sane-indentation) for algorithm and test cases.
