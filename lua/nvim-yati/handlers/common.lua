local utils = require("nvim-yati.utils")

local M = {}

function M.block_comment_extra_indent(comment, ignores, pattern)
  pattern = pattern or "^%s*%*"
  ---@param ctx YatiInitialCtx
  ---@param cursor TSCursor
  return function(ctx, cursor)
    -- NOTE: this mutates cursor to skip comment initially
    while cursor:deref() and vim.tbl_contains(ignores, utils.node_type(cursor:deref())) do
      cursor:to_parent()
    end

    local node = cursor:deref()
    if
      node
      and node:type() == comment
      and node:start() ~= ctx.lnum
      and utils.get_buf_line(ctx.bufnr, ctx.lnum):match(pattern) ~= nil
    then
      ctx:add(1)
      return node
    end
  end
end

function M.ternary_flatten_indent(ternary)
  ---@param ctx YatiParentCtx
  ---@param cursor TSCursor
  return function(ctx, cursor)
    local node = cursor:deref()
    local parent = cursor:peek_parent()
    local prev = cursor:peek_prev_sibling()

    if parent and parent:type() == ternary then
      cursor:to_parent()
      if parent and parent:parent():type() == ternary and parent:child(0) == node then
        prev = cursor:peek_prev_sibling()
      end

      while cursor:peek_parent():type() == ternary do
        cursor:to_parent()
      end

      if node:type() == "?" or node:type() == ":" then
        ctx:add(ctx.shift)
      elseif prev and (prev:type() == "?" or prev:type() == ":") then
        if prev:start() == node:start() then
          ctx:add(ctx.shift * 2)
        else
          ctx:add(ctx.shift)
        end
      end

      return true
    end
  end
end

---Fix indent in arguemnt of chained function calls (sample.js#L133)
function M.chained_field_call(arguemnts, field)
  ---@param ctx YatiParentCtx
  ---@param cursor TSCursor
  return function(ctx, cursor)
    local node = cursor:deref()
    local sibling = cursor:peek_prev_sibling()
    if
      node
      and sibling
      and node:type() == arguemnts
      and sibling:type() == field
      and sibling:start() ~= sibling:end_()
    then
      ctx:add(ctx.shift)
      return true
    end
  end
end

function M.multiline_string_literal(str)
  ---@param ctx YatiInitialCtx
  ---@param cursor TSCursor
  return function(ctx, cursor)
    if cursor:deref():type() == str and cursor:deref():start() ~= ctx.lnum then
      if utils.is_line_empty(ctx.lnum, ctx.bufnr) then
        ctx:set(-1)
      else
        ctx:set(utils.cur_indent(ctx.lnum, ctx.bufnr))
      end
      return false
    end
  end
end

function M.multiline_string_injection(str, close_delim, should_indent)
  if should_indent == nil then
    should_indent = true
  end
  ---@param ctx YatiParentCtx
  ---@param cursor TSCursor
  return function(ctx, cursor)
    local parent = cursor:peek_parent()
    if parent and parent:type() == str then
      -- in injection
      if ctx.lang ~= ctx.parent_lang and cursor:deref():start() ~= parent:start() then
        if should_indent then
          ctx:add(ctx.shift)
        end
      elseif cursor:deref():type() ~= close_delim then
        ctx:add(utils.cur_indent(cursor:deref():start(), ctx.bufnr))
        return false
      end
      return true
    end
  end
end

return M
