local utils = require("nvim-yati.utils")

---@type YatiConfig
local config = {
  indent = {
    "flow_sequence",
  },
  indent_last = {
    "block_mapping_pair",
    "block_sequence_item",
    "block_scalar",
  },
  indent_last_open = true,
  ignore_self = { named = { "block_node", "block_sequence", "block_mapping" } },
  hook_new_line = function(lnum, node, ctx)
    if node:type() == "block_sequence" then
      return 0, node
    elseif vim.endswith(utils.get_buf_line(ctx.bufnr, node:start()), ":") then
      return ctx.shift, node
    end
  end,
}

return config
