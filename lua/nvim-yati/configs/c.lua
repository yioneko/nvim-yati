local Hook = require("nvim-yati.hook")
local chains = require("nvim-yati.chains")

---@type YatiConfig
local config = {
  indent = {
    "compound_statement",
    "argument_list",
    "field_declaration_list",
    "enumerator_list",
    "parameter_list",
    "initializer_list",
    "parenthesized_expression",
    "preproc_function_def",
    "preproc_arg",
  },
  indent_last = {
    "for_statement",
    "if_statement",
    "while_statement",
    "do_statement",
    "case_statement",
    "return_statement",
    "shift_expression",
    "call_expression",
    "field_expression",
    "logical_expression",
    "math_expression",
    "conditional_expression",
    "relational_expression",
    "assignment_expression",
    "field_initializer_list",
    "init_declarator",
    "concatenated_string",
    "binary_expression",
  },
  skip_child = {
    compound_statement = {
      "labeled_statement",
    },
    if_statement = {
      named = { "compound_statement", "if_statement", "parenthesized_expression" },
      literal = { "else" },
    },
    else_clause = { named = { "compound_statement", "parenthesized_expression" } },
    while_statement = { named = { "compound_statement", "parenthesized_expression" } },
    do_statement = { named = { "compound_statement", "parenthesized_expression" } },
    for_statement = { named = { "compound_statement", "parenthesized_expression" } },
  },
  ignore_self = { literal = { ";" } },
  ignore_outer = { literal = { "#if", "#else", "#endif", "#ifdef", "#ifndef", "#define" } },
}

return config
