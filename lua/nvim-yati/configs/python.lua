local utils = require("nvim-yati.utils")

---@type YatiConfig
local config = {
  indent = {
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
  indent_last = {
    "import_from_statement",
    "return_statement",
    "expression_list",
    "binary_operator",
  },
  indent_last_open = {
    "if_statement",
    "elif_clause",
    "else_clause",
    "for_statement",
    "while_statement",
    "with_statement",
    "try_statement",
    "except_clause",
    "finnaly_clause",
    "class_definition",
    "function_definition",
    "lambda",
  },
  skip_child = {
    if_statement = { named = { "else_clause", "elif_clause" } },
    while_statement = { named = { "else_clause" } },
    try_statement = { named = { "except_clause", "else_clause", "finnaly_clause" } },
  },
  hook_node = function(node, ctx)
    local dedent = {
      ["else"] = "if_statement",
      ["elif"] = "if_statement",
      ["except"] = "try_statement",
      ["finally"] = "try_statement",
    }
    for cur, next in pairs(dedent) do
      local line = vim.trim(utils.get_buf_line(ctx.bufnr, node:start()))
      if node:type() == "identifier" and vim.startswith(line, cur) and vim.endswith(line, ":") then
        local parent = node:parent()
        while parent:type() ~= next do
          parent = parent:parent()
        end
        return 0, parent
      end
    end
  end,
}

return config
