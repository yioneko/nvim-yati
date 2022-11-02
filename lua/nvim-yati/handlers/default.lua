local utils = require("nvim-yati.utils")

local M = {}

local nt = utils.node_type

---@param parent userdata
---@param bufnr integer
local function check_indent_align(parent, bufnr)
  local first_no_delim_sib = parent:child(1)
  if first_no_delim_sib and first_no_delim_sib:start() == parent:start() then
    local col_s = utils.get_first_nonblank_col_at_line(parent:start(), bufnr)
    local _, col_e = first_no_delim_sib:start()
    return col_e - col_s
  end
end

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

    local attrs = ctx:config()[nt(node)]

    if attrs.indent_fallback and node:start() ~= node:end_() then
      return ctx:fallback()
    end

    -- If the node is not at the same line and it's an indent node, we should indent
    if node:start() ~= ctx.lnum and attrs.scope and (attrs.scope_open_extended or node:end_() >= ctx.lnum) then
      local aligned_indent
      if attrs.indent_align then
        aligned_indent = check_indent_align(node, ctx.bufnr)
        if aligned_indent ~= nil then
          ctx:add(aligned_indent)
        end
      end

      if aligned_indent == nil then
        ctx:add(ctx.shift)
      end
    end
  end

  return true
end

---@param ctx YatiContext
local function check_indent_range(ctx)
  local node = ctx.node
  local parent = ctx:parent()
  if not parent then
    return false
  end

  local attrs = ctx:config()[nt(parent)]
  local delimeters = 2
  if attrs.scope_open then
    delimeters = 1
  end

  -- special case: not direct parent
  if node:parent() ~= parent then
    return ctx.node:start() ~= parent:start()
  end

  -- only expand range if more than one child
  if attrs.indent_list and parent:child_count() > delimeters + 1 then
    local srow = node:start()
    local erow = node:end_()

    local prev = node:prev_sibling()
    while prev and prev:end_() == srow do
      srow = prev:start(0)
      prev = prev:prev_sibling()
    end

    local next = node:next_sibling()
    while next and next:start() == erow do
      erow = next:end_()
      next = next:next_sibling()
    end

    return srow ~= parent:start() or erow ~= parent:end_()
  else
    return ctx.node:start() ~= ctx:first_sibling():end_()
  end
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
  if attrs.indent_fallback and node:start() ~= node:end_() then
    return ctx:fallback()
  end

  if parent then
    local p_attrs = conf[nt(parent)]
    local prev = ctx:prev_sibling()
    local should_indent = p_attrs.scope and check_indent_range(ctx)
    -- TODO: deal with no direct parent
    if parent == node:parent() then
      should_indent = should_indent
        and prev ~= nil
        and not vim.tbl_contains(p_attrs.dedent_child, nt(node))
        and (ctx:next_sibling() ~= nil or p_attrs.scope_open)
    end

    if should_indent then
      local aligned_indent
      if p_attrs.indent_align then
        aligned_indent = check_indent_align(parent, ctx.bufnr)
        if aligned_indent ~= nil then
          ctx:add(aligned_indent)
        end
      end

      if aligned_indent == nil then
        ctx:add(ctx.shift)
      end
    end
  end

  return true
end

return M
