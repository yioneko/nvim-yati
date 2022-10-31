local utils = require("nvim-yati.utils")
local logger = require("nvim-yati.logger")
local nt = utils.node_type

local M = {}

function M.block_comment_extra_indent(comment, ignores, pattern)
  pattern = pattern or "^%s*%*"
  ---@param ctx YatiContext
  return function(ctx)
    -- NOTE: this mutates cursor to skip comment initially
    while ctx.node and vim.tbl_contains(ignores, nt(ctx.node)) do
      logger("handler", "Skip initial comment " .. nt(ctx.node))
      ctx:to_parent()
    end

    local node = ctx.node
    if
      node
      and node:type() == comment
      and node:start() ~= ctx.lnum
      and utils.get_buf_line(ctx.bufnr, ctx.lnum):match(pattern) ~= nil
    then
      logger("handler", string.format("Match inner block comment (%s), add extra indent", nt(ctx.node)))
      ctx:add(1)
      return true
    end
  end
end

function M.ternary_flatten_indent(ternary)
  ---@param ctx YatiContext
  return function(ctx)
    local node = ctx.node
    local parent = ctx:parent()
    local prev = ctx:prev_sibling()

    if parent and parent:type() == ternary then
      ctx:to_parent()
      if parent and parent:parent():type() == ternary and parent:child(0) == node then
        prev = ctx:prev_sibling()
      end

      while ctx:parent():type() == ternary do
        ctx:to_parent()
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
function M.chained_field_call(arguemnts, field_expr, field_name)
  ---@param ctx YatiContext
  return function(ctx)
    local node = ctx.node
    local sibling = ctx:prev_sibling()
    local field = sibling and sibling:field(field_name)[1]
    if
      node
      and sibling
      and field
      and node:type() == arguemnts
      and sibling:type() == field_expr
      and sibling:start() ~= sibling:end_()
    then
      ctx:relocate(field)
      return true
    end
  end
end

function M.multiline_string_literal(str)
  ---@param ctx YatiContext
  return function(ctx)
    if ctx.node:type() == str and ctx.node:start() ~= ctx.lnum then
      if utils.is_line_empty(ctx.lnum, ctx.bufnr) then
        return ctx:fallback()
      else
        -- TODO: replace with fallback
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
  ---@param ctx YatiContext
  return function(ctx)
    local parent = ctx:parent()
    if parent and parent:type() == str then
      -- in injection
      if ctx:lang() ~= ctx:parent_lang() and ctx.node:start() ~= parent:start() then
        if should_indent then
          ctx:add(ctx.shift)
        end
      elseif ctx.node:type() ~= close_delim then
        ctx:add(utils.cur_indent(ctx.node:start(), ctx.bufnr))
        return false
      end
      return true
    end
  end
end

function M.dedent_pattern(pattern, node_type, indent_node_type)
  ---@param ctx YatiContext
  return function(ctx)
    local node = ctx.node
    local line = utils.get_buf_line(ctx.bufnr, node:start())
    if not line then
      return
    end
    line = vim.trim(line)
    if node:type() == node_type and line:match(pattern) ~= nil then
      local next = utils.try_find_parent(node, function(parent)
        return parent:type() == indent_node_type
      end)
      if next then
        ctx:relocate(next, true)
      end
    end
  end
end

return M
