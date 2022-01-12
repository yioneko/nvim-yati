local utils = require("nvim-yati.utils")

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
    "compound_assignment_expr",
    "field_expression",
    "call_expression",
    "where_clause",
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
  hook_node = function(node, ctx)
    -- fix duplicate indent in macros
    local parent = utils.get_nth_parent(node, 1)
    local grandparent = utils.get_nth_parent(node, 2)
    if parent and grandparent and parent:type() == "block" and grandparent:type() == "source_file" then
      return 0
    end

    local sibling = node:prev_sibling()
    -- Fix indent in arguemnt of chained function calls
    if node:type() == "arguments" and sibling:type() == "field_expression" and sibling:start() ~= sibling:end_() then
      return ctx.shift, node
    end
  end,
}

return config
