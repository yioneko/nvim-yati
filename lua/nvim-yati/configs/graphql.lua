---@type YatiBuiltinConfig
local config = {
  scope = {
    "selection_set",
    "arguments",
    "fields_definition",
    "arguments_definition",
    "object_value",
    "list_value",
    "variable_definitions",
    "enum_values_definition",
  },
  scope_open = {
    "union_member_types",
  },
}

return config
