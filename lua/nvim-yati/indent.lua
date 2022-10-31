local utils = require("nvim-yati.utils")
local o = require("nvim-yati.config")
local handlers = require("nvim-yati.handlers")
local Context = require("nvim-yati.context")

local M = {}

-- TODO: replace -1 with fallback
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

  local bootstrap_lang = utils.get_lang_at_line(lnum, bufnr)
  if not bootstrap_lang then
    return -1
  end
  local bootstrap_conf = o.get(bootstrap_lang)
  local node_filter = function(node)
    return not bootstrap_conf.nodes[utils.node_type(node)].ignore
  end
  local ctx = Context:new(lnum, bufnr, node_filter)
  if not ctx then
    return -1
  end

  local should_cont = handlers.handle_initial(ctx)
  if ctx.has_fallback then
    return -1
  elseif not should_cont then
    return ctx.computed_indent
  end

  ctx:begin_traverse()

  while ctx.node do
    local prev_node = ctx.node

    local should_cont = handlers.handle_parent(ctx)
    if ctx.has_fallback then
      return -1
    elseif not should_cont then
      break
    end

    -- force traversing up if not changed in handlers
    if prev_node == ctx.node then
      ctx:to_parent()
    end
  end

  return ctx.computed_indent
end

function M.indentexpr(vlnum)
  if vlnum == nil then
    vlnum = vim.v.lnum
  end
  return M.get_indent(vlnum - 1)
end

return M
