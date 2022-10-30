---@type YatiBuiltinConfig
local config = {
  scope = {
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
  scope_open = {
    "assignment",
    "import_from_statement",
    "return_statement",
    "expression_list",
  },
  scope_open_extended = {
    "if_statement",
    "elif_clause",
    "else_clause",
    "for_statement",
    "while_statement",
    "with_statement",
    "try_statement",
    "except_clause",
    "finnaly_clause",
    "class_definition",
    "function_definition",
    "lambda",
  },
  dedent_child = {
    if_statement = { "else_clause", "elif_clause", "parenthesized_expression" },
    elif_clause = { "parenthesized_expression" },
    while_statement = { "else_clause", "parenthesized_expression" },
    try_statement = { "except_clause", "else_clause", "finnaly_clause", "parenthesized_expression" },
  },
}

return config
