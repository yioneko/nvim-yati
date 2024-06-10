local ch = require("nvim-yati.handlers.common")
local handlers = require("nvim-yati.handlers.rust")

---@type YatiBuiltinConfig
local config = {
  scope = {
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
  scope_open = {
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
  dedent_child = {
    if_expression = { "block", "else_clause" },
    if_let_expression = { "block", "else_clause" },
    else_clause = { "block" },
    while_expression = { "block" },
    for_expression = { "block" },
    loop_expression = { "block" },
    function_item = { "parameters", "where_clause", "type_parameters" },
  },
  ignore = {
    "string_content",
  },
  handlers = {
    on_initial = {
      ch.multiline_string_literal("string_literal"),
      ch.multiline_string_literal("raw_string_literal"),
      ch.block_comment_extra_indent("block_comment", { "'*/'" }),
      handlers.dedent_field_on_close_initial("field_expression"),
      handlers.dedent_field_on_close_initial("await_expression"),
    },
    on_traverse = {
      ch.chained_field_call("arguments", "field_expression", "field"),
      handlers.dedent_field_on_close_traverse("field_expression", "field_identifier"),
      handlers.dedent_field_on_close_traverse("await_expression", "'await'"),
    },
  },
}

return config
