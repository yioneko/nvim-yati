local utils = require("nvim-yati.utils")
local M = {}

---@alias Chain fun(ctx: HookCtx): number | nil, tsnode | nil

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

---Add extra indent in ternary branch (sample.js#L261)
---@return Chain
function M.ternary_extra_indent(ternary, consequence, alternative)
  return function(ctx)
    local node = ctx.node
    local prev = node:prev_sibling() -- "?" or ":"
    local parent = node:parent()

    if parent and prev and parent:type() == ternary and prev:start() == node:start() then
      if parent:field(consequence)[1]:id() == node:id() or parent:field(alternative)[1]:id() == node:id() then
        return ctx.shift, node
      end
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

---@return Chain
function M.escape_string_end(string, string_end)
  return function(ctx)
    local node = ctx.node
    local parent = node:parent()
    if parent and parent:type() == string and node:type() == string_end then
      return 0,
        utils.try_find_parent(parent, function(gparent)
          return parent:start() ~= gparent:start() -- escape the indent by returning node not at the same line
        end)
    end
  end
end

--- /**
---  * <- one extra indent here
---  */
---@return Chain
function M.block_comment_extra_indent(comment, pattern)
  pattern = pattern or "^%s*%*"
  return function(ctx)
    local node = ctx.node
    if
      node:type() == comment
      and ctx.lnum ~= node:start()
      and utils.get_buf_line(ctx.bufnr, ctx.lnum):match(pattern) ~= nil
    then
      return 1, node
    end
  end
end

return M
