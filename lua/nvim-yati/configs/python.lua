---@type YatiConfig
local config = {
  indent = {
    "list",
    "tuple",
    "dictionary",
    "set",
    "parenthesized_expression",
    "generator_expression",
    "list_comprehension",
    "set_comprehension",
    "dictionary_comprehension",
    "tuple_pattern",
    "list_pattern",
    "argument_list",
    "parameters",
  },
  indent_last = {
    "if_statement",
    "for_statement",
    "while_statement",
    "with_statement",
    "try_statement",
    "except_clause",
    "finnaly_clause",
    "import_from_statement",
    "function_definition",
    "class_definition",
    "return_statement",
    "elif_clause",
    "else_clause",
    "expression_list",
    "binary_operator",
    "lambda",
  },
  indent_last_open = true,
  skip_child = {
    if_statement = { named = { "else_clause", "elif_clause" } },
    while_statement = { named = { "else_clause" } },
    try_statement = { named = { "except_clause", "else_clause", "finnaly_clause" } },
  },
}

return config
