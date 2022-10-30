local config = require("nvim-yati.config")
local M = {}

function M.init()
  require("nvim-treesitter").define_modules({
    yati = {
      module_path = "nvim-yati.internal",
      is_supported = config.is_supported,
      overrides = {},
    },
  })
end

return M
