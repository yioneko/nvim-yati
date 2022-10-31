local config = require("nvim-yati.configs.c")
local extend = require("nvim-yati.config").extend

return extend(config, {
  scope = {
    "template_parameter_list",
    "template_argument_list",
    "condition_clause",
  },
  scope_open = {
    "for_range_loop",
    "condition_clause",
    "lambda_expression",
    "abstract_function_declarator",
    "field_initializer_list",
    "init_declarator",
    "class_specifier",
    "if_statement",
    "while_statement",
    "for_statement",
    "for_range_loop",
  },
  dedent_child = {
    field_declaration_list = {
      "access_specifier",
    },
    for_range_loop = { "compound_statement" },
    if_statement = {
      "compound_statement",
      "if_statement",
      "condition_clause",
      "'else'",
    },
    else_clause = { "compound_statement" },
    while_statement = { "compound_statement", "condition_clause" },
    do_statement = { "compound_statement", "condition_clause" },
    for_statement = { "compound_statement" },
  },
})
