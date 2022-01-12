set noswapfile
set directory=""
set display=lastline

set packpath+=./deps
set rtp+=.

set shiftwidth=2
set expandtab

packloadall
runtime plugin/nvim-yati.vim

lua << EOF
require("nvim-treesitter.configs").setup {
  ensure_installed = "maintained",
  yati = { enable = true },
}
-- require("nvim-yati.debug").toggle()
EOF

" TODO: Only install needed parsers
execute("silent TSInstallSync all")
