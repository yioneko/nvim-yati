---@type YatiConfig
local config = {
  indent = {
    "flow_sequence",
  },
  indent_last = {
    "block_sequence_item",
  },
  indent_last_open = {
    "block_mapping_pair",
    "block_scalar",
  },
  ignore_self = { named = { "block_node", "block_sequence", "block_mapping" } },
}

return config
