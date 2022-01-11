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
    elseif vim.endswith(vim.api.nvim_buf_get_lines(0, node:start(), node:start() + 1, true)[1], ":") then
      return ctx.shift, node
    end
  end,
}

return config
