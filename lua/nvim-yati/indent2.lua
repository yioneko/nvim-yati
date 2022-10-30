local utils = require("nvim-yati.utils")
local o = require("nvim-yati.config")
local handlers = require("nvim-yati.handlers")
local TSCursor = require("nvim-yati.cursor")

local M = {}

---@class YatiBaseCtx
---@field bufnr integer
---@field indent integer
---@field shift integer
---@field config YatiNodesConfig
---@field lang string
---@field set_indent fun(self, indent: integer)

---@class YatiInitialCtx:YatiBaseCtx
---@field lnum integer
---@field indent integer
---@field handlers YatiInitialHandler[]

---@class YatiParentCtx:YatiBaseCtx
---@field cursor TSCursor
---@field handlers YatiParentHandler[]

function M.get_indent(lnum, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root_tree = utils.get_parser(bufnr)

  if not root_tree then
    return -1
  end
  -- Firstly, ensure the tree is updated
  if not root_tree:is_valid() then
    root_tree:parse()
  end

  local lang = root_tree:language_for_range({ lnum, 0, lnum, 0 }):lang()
  ---@type YatiInitialCtx
  local ctx = {
    bufnr = bufnr,
    config = o.get(lang).nodes,
    handlers = o.get(lang).handlers.on_initial,
    lnum = lnum,
    lang = lang,
    shift = utils.get_shift(bufnr),
    indent = 0,
  }
  function ctx:set_indent(new_indent)
    self.indent = new_indent
  end

  local initial_node = handlers.handle_initial(ctx)
  if not initial_node then
    return -1
  end

  local cursor = TSCursor:new(initial_node, root_tree)
  lang = cursor:lang()
  if not lang then
    return -1
  end

  ---@type YatiParentCtx
  local ctx = {
    bufnr = bufnr,
    cursor = cursor,
    lang = lang,
    shift = ctx.shift,
    config = o.get(lang).nodes,
    handlers = o.get(lang).handlers.on_parent,
    indent = ctx.indent,
  }
  function ctx:set_indent(new_indent)
    self.indent = new_indent
  end

  while cursor:deref() do
    local should_cont = handlers.handle_parent(ctx, cursor)
    if should_cont == nil then
      return -1
    elseif not should_cont then
      return ctx.indent
    end
    cursor:to_parent()

    lang = cursor:lang()
    if lang and lang ~= ctx.lang then
      ctx.lang = lang
      ctx.config = o.get(lang).nodes
      ctx.handlers = o.get(lang).handlers.on_parent
    end
  end

  return ctx.indent
end

function M.indentexpr(vlnum)
  if vlnum == nil then
    vlnum = vim.v.lnum
  end
  return M.get_indent(vlnum - 1)
end

return M
