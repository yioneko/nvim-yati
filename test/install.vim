set packpath+=./deps
set rtp+=.

packloadall
runtime plugin/nvim-yati.vim

lua << EOF
local parsers = require('nvim-treesitter.parsers')
local utils = require('nvim-yati.utils')
for _, lang in ipairs(parsers.available_parsers()) do
  if
    utils.is_supported(lang)
    and #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) == 0
  then
    vim.cmd("TSInstallSync " .. lang)
  end
end
EOF
