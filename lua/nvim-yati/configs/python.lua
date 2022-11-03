local ch = require("nvim-yati.handlers.common")

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
    "boolean_operator",
    "binary_operator",
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
    "finally_clause",
    "class_definition",
    "function_definition",
    "lambda",
  },
  indent_align = {
    "argument_list",
    "parameters",
    "list",
    "tuple",
  },
  indent_list = {
    "argument_list",
    "parameters",
    "list",
    "tuple",
  },
  dedent_child = {
    if_statement = { "else_clause", "elif_clause", "parenthesized_expression" },
    elif_clause = { "parenthesized_expression" },
    while_statement = { "else_clause", "parenthesized_expression" },
    try_statement = { "except_clause", "else_clause", "finally_clause", "parenthesized_expression" },
  },
  handlers = {
    on_initial = {
      ch.multiline_string_literal("string"),
    },
    on_traverse = {
      ch.dedent_pattern("else:", "identifier", "if_statement"),
      ch.dedent_pattern("elif:", "identifier", "if_statement"),
      ch.dedent_pattern("except:", "identifier", "try_statement"),
      ch.dedent_pattern("finnally:", "identifier", "try_statement"),
    },
  },
}

return config
