---@type YatiConfig
local config = {
  indent = {
    "flow_sequence",
  },
  indent_last = {
    "block_mapping_pair",
    "block_sequence_item",
    "block_scalar"
  },
  indent_last_open = true,
  ignore_self = { named = { "block_node", "block_sequence", "block_mapping" } },
}

return config
