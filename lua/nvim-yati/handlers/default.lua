local utils = require("nvim-yati.utils")

local M = {}

local nt = utils.node_type

---@param ctx YatiContext
function M.on_initial(ctx)
  local node = ctx.node

  -- The line is empty
  if not node or node:start() ~= ctx.lnum then
    local prev_node
    local cur_line = utils.prev_nonblank_lnum(ctx.lnum, ctx.bufnr)
    prev_node = utils.get_node_at_line(cur_line, false, ctx.bufnr, ctx.filter)

    --[[
    -- Try find node considered always 'open' for last indent
    -- Example:
    --   if true:
    --     some()
    --
    --     |
    --]]
    while prev_node and ctx:config()[nt(prev_node)].indent_zero do
      cur_line = utils.prev_nonblank_lnum(cur_line, ctx.bufnr)
      if cur_line < node:start() then
        prev_node = nil
        break
      end
      prev_node = utils.get_node_at_line(cur_line, false, ctx.bufnr, ctx.filter)
    end
    prev_node = utils.try_find_parent(prev_node, function(parent)
      return ctx:config()[nt(parent)].scope_open_extended
    end)

    -- If prev_node is contained inside, then we use prev_node as indent base
    if prev_node and utils.node_contains(node, prev_node) then
      node = prev_node
      ctx:relocate(node)
    end

    if not node then
      return ctx:fallback()
    end
    print(ctx.node)

    local attrs = ctx:config()[nt(node)]
    -- If the node is not at the same line and it's an indent node, we should indent
    if node:start() ~= ctx.lnum and attrs.scope and (attrs.scope_open_extended or node:end_() >= ctx.lnum) then
      local first_no_delim_sib = node:child(1)
      if attrs.indent_align and (first_no_delim_sib and first_no_delim_sib:start() == node:start()) then
        local col_s = utils.get_first_nonblank_col_at_line(node:start(), ctx.bufnr)
        local _, col_e = first_no_delim_sib:start()
        ctx:add(col_e - col_s)
      else
        ctx:add(ctx.shift)
      end
    end
  end

  return true
end

---@param ctx YatiContext
function M.on_traverse(ctx)
  local node = ctx.node
  local parent = ctx:parent()
  local conf = ctx:config()
  if not conf then
    return ctx:fallback()
  end

  if conf[nt(node)].indent_zero then
    ctx:set(0)
    return false
  end

  local attrs = conf[nt(node)]
  if attrs.fallback then
    return ctx:fallback()
  end

  if parent then
    local p_attrs = conf[nt(parent)]
    local prev = ctx:prev_sibling()
    local should_indent = p_attrs.scope
      and prev
      and ctx:first_sibling():end_() ~= node:start()
      and not vim.tbl_contains(p_attrs.dedent_child, nt(node))
      and (ctx:next_sibling() ~= nil or p_attrs.scope_open)

    if should_indent then
      local first_no_delim_sib = ctx:first_sibling():next_sibling()
      if p_attrs.indent_align and (first_no_delim_sib and first_no_delim_sib:start() == parent:start()) then
        local col_s = utils.get_first_nonblank_col_at_line(parent:start(), ctx.bufnr)
        local _, col_e = first_no_delim_sib:start()
        ctx:add(col_e - col_s)
      else
        ctx:add(ctx.shift)
      end
    end
    print(nt(node) .. " " .. nt(parent) .. " " .. ctx:lang() .. " " .. (ctx:parent_lang() or "") .. ctx.computed_indent)
  end

  return true
end

return M
