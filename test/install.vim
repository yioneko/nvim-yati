" https://github.com/neovim/neovim/issues/12432
set display=lastline

set packpath+=./deps
set rtp+=.

packloadall
runtime plugin/nvim-yati.vim

lua << EOF
local parsers = require('nvim-treesitter.parsers')
local config = require('nvim-yati.config')
for _, lang in ipairs(parsers.available_parsers()) do
  if
    config.is_supported(lang)
    and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) == 0
  then
    vim.cmd("TSInstallSync " .. lang)
  end
end
EOF
