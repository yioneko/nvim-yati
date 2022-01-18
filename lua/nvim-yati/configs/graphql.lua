---@type YatiConfig
local config = {
  indent = {
    "selection_set",
    "arguments",
    "fields_definition",
    "arguments_definition",
    "object_value",
    "list_value",
    "variable_definitions",
    "enum_values_definition",
  },
  indent_last = {
    "union_member_types",
  },
  ignore_within = { "description" },
}

return config
