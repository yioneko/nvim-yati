local config = require("nvim-yati.configs.javascript")
local extend = require("nvim-yati.config").extend

return extend(config, {
  scope = {
    "object_type",
    "tuple_type",
    "enum_body",
    "type_arguments",
    "type_parameters",
  },
  scope_open = {
    "property_signature",
    "conditional_type",
    "required_parameter",
    "property_signature",
    "type_annotation",
    "type_alias_declaration",
  },
  ignore = { "union_type" },
  dedent_child = {
    ["type_alias_declaration"] = { "object_type" },
  },
})
