local config = require("nvim-yati.configs.c")
local extend = require("nvim-yati.utils").extend_config

return extend(config, {
  indent = {
    "template_parameter_list",
    "template_argument_list",
  },
  indent_last = {
    "condition_clause",
    "lambda_expression",
    "field_initializer_list",
    "init_declarator",
    "class_specifier",
    "if_statement",
    "while_statement",
    "for_statement",
    "for_range_loop",
  },
  ignore = {
    named = { "comment" },
  },
})
