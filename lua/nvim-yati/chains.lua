local utils = require("nvim-yati.utils")
local M = {}

---@alias Chain fun(ctx: HookCtx): number | nil, tsnode | nil, boolean | nil

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

---TODO: May need to refactor hook to make it more reasonable and understandable
---Add extra indent in ternary branch (sample.js#L261)
---@return Chain
function M.ternary_extra_indent(ternary)
  return function(ctx)
    local node = ctx.node
    local prev = node:prev_sibling()
    local parent = node:parent()

    if parent and prev and parent:type() == ternary then
      if prev:start() == node:start() and (prev:type() == "?" or prev:type() == ":") then
        if parent:parent():type() ~= ternary then
          return ctx.shift, node
        else
          return ctx.shift, parent
        end
      elseif node:type() == "?" or node:type() == ":" then
        if parent:parent():type() ~= ternary then
          return 0, node
        else
          return 0, parent
        end
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
      return 1, node, false
    end
  end
end

---Before: a &&    After:  a &&
---          b &&          b &&
---          c             c
---@return Chain
function M.ignore_inner_left_binary_expression(binary_expression, not_operators)
  not_operators = not_operators or { "<<", ">>" }
  return function(ctx)
    local cur = ctx.node:parent()
    if cur and cur:type() == binary_expression then
      if vim.tbl_contains(not_operators, cur:child(1):type()) then
        return
      end
      local parent = cur:parent()
      while parent and parent:type() == binary_expression do
        if parent:field("right")[1]:id() == cur:id() or vim.tbl_contains(not_operators, parent:child(1):type()) then
          return 0, cur, true
        end
        cur = parent
        parent = cur:parent()
      end
      return 0, cur, true
    end
  end
end

return M
