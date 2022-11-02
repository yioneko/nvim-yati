local ch = require("nvim-yati.handlers.common")

---@type YatiBuiltinConfig
local config = {
  scope = {
    "table_constructor",
    "function",
    "function_definition",
    "function_declaration",
    "expression_list",
    "parameters",
    "arguments",
    "if_statement",
    "do_statement",
    "for_statement",
    "for_in_statement",
    "while_statement",
    "repeat_statement",
    "parenthesized_expression",
  },
  scope_open = {
    "else_statement",
    "elseif_statement",
    "assignment_statement",
    "function_call",
    "method_index_expression",
    "variable_declaration",
    "dot_index_expression",
    "return_statement",
  },
  indent_list = {
    "arguments",
    "table_constructor",
  },
  dedent_child = {
    local_function = { "parameters" },
    function_definition = { "parameters" },
    function_declaration = { "parameters" },
    ["function"] = { "parameters" },
    if_statement = { "'then'", "else_statement", "elseif_statement" },
    elseif_statement = { "'then'" },
    for_statement = { "'do'" },
    for_in_statement = { "'do'", "'in'" },
    while_statement = { "'do'" },
    repeat_statement = { "'until'" },
  },
  ignore = { "binary_expression" }, -- ignore binary_expression to be compatible with stylua
  handlers = {
    on_initial = {
      ch.multiline_string_literal("string_content"),
    },
    on_traverse = {
      ch.chained_field_call("arguments", "method_index_expression", "method"),
      ch.chained_field_call("arguments", "dot_index_expression", "field"),
      ch.multiline_string_injection("string_content", "string_end"),
    },
  },
}

return config
