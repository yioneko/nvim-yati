local ch = require("nvim-yati.handlers.common")

---@type YatiBuiltinConfig
local config = {
  scope = {
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
    "named_imports",
    "export_clause",
    "subscript_expression",
  },
  scope_open = {
    "expression_statement",
    "variable_declarator",
    "lexical_declaration",
    "member_expression",
    "binary_expression",
    "return_statement",
    "if_statement",
    "else_clause",
    "for_statement",
    "for_in_statement",
    "while_statement",
    "jsx_self_closing_element",
    "assignment_expression",
    "arrow_function",
    "call_expression",
    "pair",
  },
  scope_open_extended = {
    "switch_case",
    "switch_default",
  },
  indent_list = {
    "object",
    "array",
    "arguments",
  },
  dedent_child = {
    if_statement = { "statement_block", "else_clause", "parenthesized_expression" },
    else_clause = { "statement_block", "parenthesized_expression" },
    while_statement = { "statement_block", "parenthesized_expression" },
    for_statement = { "statement_block", "'('", "')'" },
    for_in_statement = { "statement_block", "'('", "')'" },
    arrow_function = { "statement_block" },
    jsx_fragment = { "'<'" },
    jsx_self_closing_element = { "'/>'" },
  },
  ignore = { "jsx_text" },
  handlers = {
    on_initial = {
      ch.multiline_string_literal("template_string"),
      ch.multiline_string_literal("string_fragment"),
      ch.block_comment_extra_indent("comment", {}),
    },
    on_traverse = {
      ch.ternary_flatten_indent("ternary_expression"),
      ch.chained_field_call("arguments", "member_expression", "property"),
      ch.multiline_string_injection("template_string", "`"),
      ch.multiline_string_injection("string_fragment", "`"),
    },
  },
}

return config
