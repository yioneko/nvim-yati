local ch = require("nvim-yati.handlers.common")

---@type YatiBuiltinConfig
local config = {
  scope = {
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
  scope_open = {
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
    "labeled_statement",
  },
  dedent_child = {
    compound_statement = {
      "labeled_statement",
    },
    if_statement = {
      "compound_statement",
      "if_statement",
      "parenthesized_expression",
      "'else'",
    },
    else_clause = { "compound_statement", "parenthesized_expression" },
    while_statement = { "compound_statement", "parenthesized_expression" },
    do_statement = { "compound_statement", "parenthesized_expression" },
    for_statement = { "compound_statement", "parenthesized_expression" },
  },
  ignore = { "preproc_if", "preproc_else" },
  indent_zero = { "'#if'", "'#else'", "'#endif'", "'#ifdef'", "'#ifndef'", "'#define'" },
  handlers = {
    on_initial = {
      ch.block_comment_extra_indent("comment", {}),
    },
  },
}

return config
