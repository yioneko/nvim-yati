# nvim-yati

Yet another tree-sitter indent plugin for Neovim.

This plugin was originally created when the experience of builtin indent module of [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) was still terrible. Now since the maintainers came back, and it has improved a lot and become usable, I'll stop maintaining this once the 'official' one completely supersede (also hope it will!).

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

- Fast, match node on demand by implementing completely in Lua.
- Handles injected language. See [sample.html](test/indent/sample.html) for example.
- [Tests](test/indent) covered. Refer samples in that directory for what the indentation would be like (it is slightly opinionated since there is no actual standard for it).

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
