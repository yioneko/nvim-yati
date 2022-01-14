local utils = require("nvim-yati.utils")
local M = {}

function M.init()
  require("nvim-treesitter").define_modules({
    yati = {
      module_path = "nvim-yati.internal",
      is_supported = utils.is_supported,
      overrides = {},
    },
  })
end

return M
