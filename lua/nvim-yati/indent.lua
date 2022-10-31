local utils = require("nvim-yati.utils")
local o = require("nvim-yati.config")
local handlers = require("nvim-yati.handlers")
local TSCursor = require("nvim-yati.cursor")

local M = {}

---@class YatiBaseCtx
---@field bufnr integer
---@field indent integer
---@field shift integer
---@field lang string
---@field config YatiNodesConfig
---@field global { ignore: string[] }
---@field add fun(self, delta: integer)
---@field set fun(self, indent: integer)

---@class YatiInitialCtx:YatiBaseCtx
---@field lnum integer
---@field indent integer
---@field handlers YatiInitialHandler[]

---@class YatiParentCtx:YatiBaseCtx
---@field cursor TSCursor
---@field handlers YatiParentHandler[]
---@field parent_lang string|nil
---@field parent_config YatiNodesConfig|nil
---@field parent_handlers YatiParentHandler[]

local function cursor_filter(node)
  return not vim.tbl_contains(o.global.ignore, utils.node_type(node))
end

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

  local node = utils.get_node_at_line(lnum, false, bufnr, o.global.ignore)
  if not node then
    return -1
  end

  local initial_cursor = TSCursor:new(node, root_tree, cursor_filter)
  local lang = initial_cursor:lang()

  ---@type YatiInitialCtx
  local ctx = {
    bufnr = bufnr,
    config = o.get(lang).nodes,
    handlers = o.get(lang).handlers.on_initial,
    global = o.global,
    lnum = lnum,
    lang = lang,
    shift = utils.get_shift(bufnr),
    indent = 0,
  }
  function ctx:add(indent_delta)
    self.indent = self.indent + indent_delta
  end
  function ctx:set(indent)
    self.indent = indent
  end

  local initial_node_or_cont = handlers.handle_initial(ctx, initial_cursor)
  if not initial_node_or_cont then
    return ctx.indent
  end

  local cursor = TSCursor:new(initial_node_or_cont, root_tree, cursor_filter)
  lang = cursor:lang()

  local parent_lang = cursor:parent_lang()
  ---@type YatiParentCtx
  local ctx = {
    bufnr = bufnr,
    cursor = cursor,
    lang = lang,
    shift = ctx.shift,
    config = o.get(lang).nodes,
    handlers = o.get(lang).handlers.on_parent,
    global = o.global,
    parent_lang = parent_lang,
    parent_config = parent_lang and o.get(parent_lang).nodes,
    parent_handlers = parent_lang and o.get(parent_lang).handlers.on_parent,
    indent = ctx.indent,
  }
  function ctx:add(indent_delta)
    self.indent = self.indent + indent_delta
  end
  function ctx:set(indent)
    self.indent = indent
  end

  while cursor:deref() do
    local prev_node = cursor:deref()

    local should_cont = handlers.handle_parent(ctx, cursor)
    if not should_cont then
      break
    end

    -- force traversing up if not changed in handlers
    if prev_node == cursor:deref() then
      cursor:to_parent()
    end

    lang = cursor:lang()
    parent_lang = cursor:parent_lang()
    ctx.lang = lang
    ctx.config = o.get(lang).nodes
    ctx.handlers = o.get(lang).handlers.on_parent
    ctx.parent_lang = parent_lang
    ctx.parent_config = parent_lang and o.get(parent_lang).nodes
    ctx.parent_handlers = parent_lang and o.get(parent_lang).handlers.on_parent
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
