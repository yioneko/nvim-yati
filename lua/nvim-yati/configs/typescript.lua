local config = require("nvim-yati.configs.javascript")
local extend = require("nvim-yati.utils").extend_config

return extend(config, {
  indent = {
    "object_type",
    "tuple_type",
    "enum_body",
  },
  indent_last = {
    "property_signature",
    "conditional_type",
    "type_arguments",
    "type_parameters",
  },
})
