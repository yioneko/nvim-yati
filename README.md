# nvim-yati

Yet another tree-sitter indent plugin for Neovim.

This plugin was originally created when the experience of builtin indent module of [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) was still terrible. Now since the maintainers came back, and it has improved a lot and become usable, I'll stop maintaining this once the 'official' one completely supersede (also hope it will!).

Currently I'm very confident that this plugin is nearly perfect and should cover most of the situations for supported languages. If you are still frustrated with the 'official' indent module, welcome to use this plugin instead as temporary solution. Feel free to submit issues for any problems.

The details of configuration are described at [CONFIG.md](CONFIG.md). Take a glance at it if you are interested in internal working principles or helping development.

## Setup

Install with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({ "yioneko/nvim-yati", requires = "nvim-treesitter/nvim-treesitter" })
```

Enable this module:

```lua
require("nvim-treesitter.configs").setup {
  yati = { enable = true },
}
```

## Features

- Fast, match node on demand by implementing completely in Lua, compared to executing scm query on the whole file on every indent calculation (that's why I use Lua table instead of scm query for configuration).
- Support indent in injection region. See [sample.html](test/indent/sample.html) for example.
- [Tests](test/indent) covered and handles much more edge cases. Refer samples in that directory for what the indentation would be like (it is slightly opinionated since there is no actual standard for it).
- Support for custom hooks to deal with complex scenarios. Personally I regard this as killer feature of this plugin and finally making it possible to become perfect.

  For example, the following situation is difficult to handle in pure scm query because of breaking of syntax tree in Python:

  ```python
  if True:
    pass
    else # should auto dedent
  ```

  But by using custom hooks in Lua, we could use regex to test the line and check the tree programmatically to make the decision of dedent. I already create many commonly used hooks in [chains.lua](lua/nvim-yati/chains.lua) and other language-specific hooks in their configs.

## Notes

The calculation result heavily relies on the correct tree-sitter parsing of the code. I'd recommend using plugins like [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) to keep the syntax tree error-free while inserting. This should avoid most of the wrong indent calculations.

## Supported languages

- C/C++
- CSS
- GraphQL
- HTML
- Javascript/Typescript (jsx and tsx are also supported)
- JSON
- Lua
- Markdown
- PHP
- Python
- Rust
- TOML
- Vim
- YAML

More languages could be supported by adding config files to [configs/](lua/nvim-yati/configs) directory.

## Credits

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for initial aspiration and test cases.
- [chfritz/atom-sane-indentation](https://github.com/chfritz/atom-sane-indentation) for algorithm and test cases.
