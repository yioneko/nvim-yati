local config = require("nvim-yati.configs.c")
local extend = require("nvim-yati.utils").extend_config

return extend(config, {
  indent = {
    "template_parameter_list",
    "template_argument_list",
    "condition_clause",
  },
  indent_last = {
    "for_range_loop",
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
  skip_child = {
    field_declaration_list = {
      named = { "access_specifier" },
    },
    for_range_loop = { named = { "compound_statement" } },
    if_statement = {
      named = { "compound_statement", "if_statement", "condition_clause" },
      literal = { "else" },
    },
    else_clause = { named = { "compound_statement" } },
    while_statement = { named = { "compound_statement", "condition_clause" } },
    do_statement = { named = { "compound_statement", "condition_clause" } },
    for_statement = { named = { "compound_statement" } },

  }
})
