# nvim-yati

Yet another tree-sitter indent plugin for Neovim.

The experimental buitin indent module of [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) seems broken for dialy use and lacks maintainers currently (2022-01). However, if we want to get saner indent support we must turn on legacy vim syntax highlighting and run it with tree-siter parsing parallelly in most cases. This is such a pain so I decided to write another one with a more reasonable and powerful algorithm and get rid of the old-style vim syntax engine.

If that's the same case for you, give this plugin a try. Contribution is also welcome.

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
- Javascript/Typescript (jsx and tsx are also supported)
- Python
- Lua
- HTML
- CSS
- JSON
- YAML
- Markdown

More languages could be supported by adding config files to [configs/](lua/nvim-yati/configs) directory.

## Credits

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for initial spiration and test cases.
- [chfritz/atom-sane-indentation](https://github.com/chfritz/atom-sane-indentation) for algorithm and test cases.
