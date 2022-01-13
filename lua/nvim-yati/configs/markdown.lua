local utils = require("nvim-yati.utils")

local function get_list_item_indent(node, bufnr)
  local inc = 0
  local cur_indent = utils.cur_indent(node:start(), bufnr)
  local cur = node:prev_sibling()
  -- The nested numbered list item is treated as sibling?
  while cur ~= nil do
    local indent = utils.cur_indent(cur:start(), bufnr)
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
      return get_list_item_indent(node, ctx.bufnr) * ctx.shift - utils.cur_indent(ctx.upper_line, ctx.bufnr),
        utils.get_nth_parent(node, 2)
    end
  end,
  hook_node = function(node, ctx)
    if node:type() == "list_item" then
      return get_list_item_indent(node, ctx.bufnr) * ctx.shift - utils.cur_indent(ctx.upper_line, ctx.bufnr),
        utils.get_nth_parent(node, 2)
    end
  end,
}

return config
