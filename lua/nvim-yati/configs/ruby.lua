local ch = require("nvim-yati.handlers.common")

---@type YatiBuiltinConfig
local config = {
  scope = {
    "do_block",
    "block",
    "method",
    "module",
    "if",
    "for",
    "until",
    "class",
    "case_match",
    "case",
    "in_clause",
    "while",
    "when",
    "begin",
    "block_parameters",
    "destructured_parameter",
    "parenthesized_statements",
    "argument_list",
    "array",
    "hash",
  },
  scope_open = {
    "call",
    "assignment",
    "operator_assignment",
    "else",
    "elsif",
  },
  indent_list = {
    "call",
    "block_parameters",
    "argument_list",
    "array",
    "hash",
  },
  indent_align = {
    "block_parameters",
    "argument_list",
    "array",
    "hash",
  },
  dedent_child = {
    ["if"] = { "else", "elsif" },
    case = { "when", "else" },
    case_match = { "in_clause" },
  },
  ignore = { "then", "do" },
  handlers = {
    on_initial = {
      ch.multiline_string_literal("heredoc_content"),
    },
    on_traverse = {
      ch.chained_field_call("argument_list", "call", "method"),
    },
  },
}

return config
