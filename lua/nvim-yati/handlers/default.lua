local utils = require("nvim-yati.utils")

local M = {}

local nt = utils.node_type

---@param ctx YatiInitialCtx
---@param initial_cursor TSCursor
function M.on_initial(ctx, initial_cursor)
  local node = initial_cursor:deref()
  if not node then
    return false
  end

  -- The line is empty
  if node:start() ~= ctx.lnum then
    local prev_node
    local cur_line = utils.prev_nonblank_lnum(ctx.lnum, ctx.bufnr)
    prev_node = utils.get_node_at_line(cur_line, false, ctx.bufnr)

    --[[
    -- Try find node considered always 'open' for last indent
    -- Example:
    --   if true:
    --     some()
    --
    --     |
    --]]
    while prev_node and ctx.config[nt(prev_node)].indent_zero do
      cur_line = utils.prev_nonblank_lnum(cur_line, ctx.bufnr)
      if cur_line < node:start() then
        prev_node = nil
        break
      end
      prev_node = utils.get_node_at_line(cur_line, false, ctx.bufnr)
    end
    prev_node = utils.try_find_parent(prev_node, function(parent)
      return ctx.config[nt(parent)].scope_open_extended
    end)

    -- If prev_node is contained inside, then we use prev_node as indent base
    if prev_node and utils.node_contains(node, prev_node) then
      node = prev_node
    end

    -- If the node is not at the same line and it's an indent node, we should indent
    if node:start() ~= ctx.lnum and ctx.config[nt(node)].scope then
      if ctx.config[nt(node)].scope_open_extended or node:end_() >= ctx.lnum then
        ctx:add(ctx.shift)
      end
    end
  end

  return node
end

---@param ctx YatiParentCtx
---@param cursor TSCursor
function M.on_parent(ctx, cursor)
  local node = cursor:deref()
  local parent = cursor:peek_parent()
  if ctx.config[nt(node)].indent_zero then
    ctx:set(0)
    return false
  end

  local attrs = ctx.config[nt(node)]
  if attrs.fallback then
    -- TODO: fallback expr
  end

  if parent then
    local p_attrs = ctx.config[nt(parent)]
    local prev = cursor:peek_prev_sibling()
    local should_indent = p_attrs.scope
      and prev
      and cursor:peek_first_sibling():end_() ~= node:start()
      and not vim.tbl_contains(p_attrs.dedent_child, nt(node))
      and (cursor:peek_next_sibling() ~= nil or p_attrs.scope_open)

    if should_indent then
      if p_attrs.indent_align then
        local col_s = utils.get_first_nonblank_col_at_line(parent:start(), ctx.bufnr)
        local _, col_e = cursor:peek_first_sibling():start()
        ctx:add(col_e - col_s)
      else
        ctx:add(ctx.shift)
      end
    end
    print(nt(node) .. " " .. nt(parent) .. " " .. ctx.lang .. " " .. (ctx.parent_lang or "") .. ctx.indent)
  end

  return true
end

return M
