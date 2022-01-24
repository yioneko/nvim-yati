local Hook = require("nvim-yati.hook")
local chains = require("nvim-yati.chains")

---@type YatiConfig
local config = {
  indent = {
    "array",
    "object",
    "object_pattern",
    "arguments",
    "statement_block",
    "class_body",
    "parenthesized_expression",
    "formal_parameters",
    "jsx_element",
    "jsx_fragment",
    "jsx_opening_element",
    "jsx_expression",
    "switch_body",
    "member_expression",
    "template_substitution",
  },
  indent_last = {
    "expression_statement",
    "variable_declarator",
    "lexical_declaration",
    "ternary_expression",
    "binary_expression",
    "return_statement",
    "if_statement",
    "else_clause",
    "while_statement",
    "switch_case",
    "switch_default",
    "jsx_self_closing_element",
    "assignment_expression",
    "arrow_function",
    "call_expression",
  },
  skip_child = {
    if_statement = { named = { "statement_block", "else_clause", "parenthesized_expression" } },
    else_clause = { named = { "statement_block", "parenthesized_expression" } },
    while_statement = { named = { "statement_block", "parenthesized_expression" } },
    jsx_fragment = { literal = { "<" } },
  },
  ignore_self = { literal = { ";" }, named = { "jsx_text" } },
  ignore_within = { "description", "template_string" },
  hook_node = Hook(
    chains.escape_string_end("template_string", "`"),
    chains.block_comment_extra_indent("description"),
    chains.chained_field_call("arguments", "member_expression"),
    chains.ternary_extra_indent("ternary_expression", "consequence", "alternative")
  ),
}

return config
