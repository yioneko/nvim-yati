set noswapfile
set packpath+=./deps
set rtp+=.

packloadall

lua require('benchmark.compare')
