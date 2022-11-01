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
-- require("nvim-yati.debug").toggle()
EOF
