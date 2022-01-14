local utils = require("nvim-yati.utils")

local function is_end_augroup(node, bufnr)
  local text = vim.treesitter.get_node_text(node, bufnr)
  return vim.endswith(vim.trim(text), "END")
end

---@type YatiConfig
local config = {
  indent = {
    "function_definition",
    "if_statement",
    "try_statement",
    "while_loop",
    "list",
    "dictionnary",
    "parameters",
    "arguments",
  },
  indent_last = {
    "let_statement",
    "else_statement",
    "catch_statement",
  },
  skip_child = {
    if_statement = { named = { "else_statement" } },
    try_statement = { named = { "catch_statement" } },
    function_definition = { named = { "function_declaration" } },
    function_declaration = { named = { "parameters" } },
  },
  ignore_self = { named = { "body" } },
  hook_node = function(node, ctx)
    if node:type() == "autocmd_statement" then
      local prev = node:prev_sibling()
      while prev do
        if prev:type() == "augroup_statement" then
          if not is_end_augroup(prev, ctx.bufnr) then
            return ctx.shift, prev
          else
            return
          end
        end
        prev = prev:prev_sibling()
      end
    end
  end,
  hook_new_line = function(lnum, node, ctx)
    local prev_line = utils.prev_nonblank_lnum(lnum, ctx.bufnr)
    local prev_node = utils.get_node_at_line(prev_line, ctx.tree, true, ctx.bufnr)

    if prev_node:type() == "autocmd_statement" then
      return 0, prev_node
    end

    if prev_node:type() == "augroup_statement" and not is_end_augroup(prev_node, ctx.bufnr) then
      return ctx.shift, prev_node
    end
  end,
}

return config
