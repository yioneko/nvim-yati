local function get_list_item_indent(node)
  local inc = 0
  local cur_indent = vim.fn.indent(node:start() + 1)
  local cur = node:prev_sibling()
  while cur ~= nil do
    local indent = vim.fn.indent(cur:start() + 1)
    if indent < cur_indent then
      cur_indent = indent
      inc = inc + 1
    end
    cur = cur:prev_sibling()
  end
  if node:parent():parent():type() == "list_item" then
    inc = inc + 1
  end
  return inc
end

---@type YatiConfig
local config = {
  ignore_within = { named = { "html_block", "fenced_code_block" } },
  hook_new_line = function(lnum, node, ctx)
    if node:type() == "list_item" then
      return get_list_item_indent(node) * ctx.shift - vim.fn.indent(ctx.upper_line + 1), node:parent():parent()
    end
  end,
  hook_node = function(node, ctx)
    if node:type() == "list_item" then
      return get_list_item_indent(node) * ctx.shift - vim.fn.indent(ctx.upper_line + 1), node:parent():parent()
    end
  end,
}

return config
