local Hook = require("nvim-yati.hook")
local chains = require("nvim-yati.chains")

---@type YatiConfig
local config = {
  indent = {
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
  indent_last = {
    "else_statement",
    "elseif_statement",
    "assignment_statement",
    "function_call",
    "method_index_expression",
    "variable_declaration",
    "dot_index_expression",
    "return_statement",
  },
  skip_child = {
    local_function = { named = { "parameters" } },
    function_definition = { named = { "parameters" } },
    function_declaration = { named = { "parameters" } },
    ["function"] = { named = { "parameters" } },
    if_statement = { literal = { "then" }, named = { "else_statement", "elseif_statement" } },
    for_statement = { literal = { "do" } },
    for_in_statement = { literal = { "do", "in" } },
    while_statement = { literal = { "do" } },
    repeat_statement = { literal = { "until" } },
  },
  ignore_self = { named = { "binary_expression" } },
  hook_node = Hook(
    chains.chained_field_call("arguments", "method_index_expression"),
    chains.chained_field_call("arguments", "dot_index_expression")
  ),
}

return config
