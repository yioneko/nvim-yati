local M = {}

function M.init()
  require("nvim-treesitter").define_modules({
    yati = {
      module_path = "nvim-yati.internal",
      is_supported = function(lang)
        return pcall(require, "nvim-yati.configs." .. lang)
      end,
    },
  })
end

return M
