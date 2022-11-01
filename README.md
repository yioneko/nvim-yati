# nvim-yati

Yet another tree-sitter indent plugin for Neovim.

This plugin was originally created when the experience of builtin indent module of [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) was still terrible. Now since it has improved a lot with better community support, this plugin **should be no longer needed** if the upstream one already satisfies you.

If you are still frustrated with the 'official' indent module or interested in this plugin, welcome to provide feedback or submit any issues. Take a glance at [features](#features) to learn about the differences.

## Warning

This plugin is under rewrite. The new version should fix more common cases, but it is a **breaking change**. I have no time to write a detailed migration guide, if you want to stick with old version, just pin the plugin to the `legacy` tag.

## Setup

Install with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({ "yioneko/nvim-yati", tag = "legacy", requires = "nvim-treesitter/nvim-treesitter" })
```

Enable this module:

```lua
require("nvim-treesitter.configs").setup {
  yati = {
    enable = true,
    disable = { "python" }, -- disable by languages
    default_lazy = false, -- enable lazy mode
  },
  indent = {
    enable = false -- disable builtin indent module
  }
}
```

Available config options:

```lua
local get_builtin = require("nvim-yati.config").get_builtin
-- This is just an example, not recommend to do this since the result is unpredictable
local js_overrides = vim.tbl_deep_extend("force", get_builtin("javascript"), {
  lazy_mode =  false,
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

- Could be faster and more context aware if `lazy_mode` enabled, see `default_lazy` option. This is specifically useful if the surrounding code doesn't obey indent rules:

  ```lua
  function fun()
    if abc then
                  if cbd then
                    a() -- new indent will goes here even if the parent node indent wrongly
                  end
    end
  end
  ```

- Fallback indent method support, by default `:h cindent()` is used.
- Support indent in injection region. See [sample.html](test/fixtures/html/sample.html) for example.
- [Tests](test/fixtures) covered and handles much more edge cases. Refer samples in that directory for what the indentation would be like. The style is slightly opinionated as there is no actual standard, but customization is still possible.
- Support for custom handlers to deal with complex scenarios. This plugin relies on dedicated handlers to fix many edge cases like the following one:

  ```python
  if True:
    pass
    else: # should auto dedent <-
          # the parsed tree is broken here and cannot be handled by tree-sitter
  ```

## Notes

- The calculation result heavily relies on the correct tree-sitter parsing of the code. I'd recommend using plugins like [nvim-autopairs](https://github.com/windwp/nvim-autopairs) or [luasnip](https://github.com/L3MON4D3/LuaSnip) to keep the syntax tree error-free while editing. This should avoid most of the wrong indent calculations.
- I mainly write `js/ts` so other languages may not receive better support than these two, bad cases for other languages are generally expected, and please create issues for them if possible.

## Supported languages

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

More languages could be supported by adding config files to [configs/](lua/nvim-yati/configs) directory.

## Credits

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for initial aspiration and test cases.
- [chfritz/atom-sane-indentation](https://github.com/chfritz/atom-sane-indentation) for algorithm and test cases.
