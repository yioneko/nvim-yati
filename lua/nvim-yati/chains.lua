local utils = require("nvim-yati.utils")

local M = {}

---Fix indent in arguemnt of chained function calls (sample.js#L133)
---@return Chain
function M.chained_field_call(arguemnts, field)
  return function(ctx)
    local node = ctx.node
    local sibling = node:prev_sibling()
    if node:type() == arguemnts and sibling:type() == field and sibling:start() ~= sibling:end_() then
      return ctx.shift, node
    end
  end
end

---Directly jump to the containing indent node to escape the indent
---@return Chain
function M.escape_indent(line_pattern, node_type, indent_node_type, no_trim)
  return function(ctx)
    local node = ctx.node
    local line = utils.get_buf_line(ctx.bufnr, node:start())
    if not no_trim then
      line = vim.trim(line)
    end
    if node:type() == node_type and line:match(line_pattern) ~= nil then
      local next = utils.try_find_parent(node, function(parent)
        return parent:type() == indent_node_type
      end)
      if next then
        return 0, next
      end
    end
  end
end

return M
