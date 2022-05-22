local Hook = require("nvim-yati.hook")
local chains = require("nvim-yati.chains")

---@type YatiConfig
local config = {
  indent = {
    "mod_item",
    "enum_variant_list",
    "ordered_field_declaration_list",
    "field_declaration_list",
    "field_initializer_list",
    "declaration_list",
    "function_item",
    "parameters",
    "struct_expression",
    "match_block",
    "tuple_expression",
    "array_expression",
    "match_arm",
    "match_block",
    "if_expression",
    "else_clause",
    "if_let_expression",
    "while_expression",
    "for_expression",
    "loop_expression",
    "assignment_expression",
    "arguments",
    "parameters",
    "type_parameters",
    "type_arguments",
    "block",
    "use_list",
    "macro_definition",
    "token_tree",
    "parenthesized_expression",
  },
  indent_last = {
    "const_item",
    "let_declaration",
    "assignment_expression",
    "binary_expression",
    "compound_assignment_expr",
    "field_expression",
    "call_expression",
    "where_clause",
    "await_expression",
  },
  skip_child = {
    if_expression = { named = { "block", "else_clause" } },
    if_let_expression = { named = { "block", "else_clause" } },
    else_clause = { named = { "block" } },
    while_expression = { named = { "block" } },
    for_expression = { named = { "block" } },
    loop_expression = { named = { "block" } },
    function_item = { named = { "parameters", "where_clause", "type_parameters" } },
  },
  ignore_within = { "raw_string_literal", "line_comment", "block_comment" },
  ignore_self = { named = { "string_literal" } },
  hook_node = Hook(
    chains.block_comment_extra_indent("block_comment"),
    chains.chained_field_call("arguments", "field_expression")
  ),
}

return config
