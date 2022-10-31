local utils = require("nvim-yati.utils")
local o = require("nvim-yati.config")
local handlers = require("nvim-yati.handlers")
local Context = require("nvim-yati.context")
local logger = require("nvim-yati.logger")
local nt = utils.node_type

local M = {}

function M.get_ts_indent(lnum, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root_tree = utils.get_parser(bufnr)

  if not root_tree then
    return
  end
  -- Firstly, ensure the tree is updated
  if not root_tree:is_valid() then
    root_tree:parse()
  end

  local bootstrap_lang = utils.get_lang_at_line(lnum, bufnr)
  if not bootstrap_lang then
    return
  end

  local bootstrap_conf = o.get(bootstrap_lang)
  if not bootstrap_conf then
    return
  end

  local node_filter = function(node)
    return not bootstrap_conf.nodes[utils.node_type(node)].ignore
  end
  local ctx = Context:new(lnum, bufnr, node_filter)
  if not ctx then
    return
  end

  logger("main", string.format("Bootstrap node %s(%s)", nt(ctx.node), ctx:lang()))

  local should_cont = handlers.handle_initial(ctx)
  if ctx.has_fallback then
    return
  elseif not should_cont then
    return ctx.computed_indent
  end

  logger("main", string.format("Initial node %s(%s), computed %s", nt(ctx.node), ctx:lang(), ctx.computed_indent))

  ctx:begin_traverse()
  -- main traverse loop
  while ctx.node do
    local prev_node = ctx.node
    local prev_lang = ctx:lang()

    should_cont = handlers.handle_traverse(ctx)
    if ctx.has_fallback then
      return
    elseif not should_cont then
      break
    end

    -- force traversing up if not changed in handlers
    if prev_node == ctx.node then
      ctx:to_parent()
    end

    if ctx.node then
      logger(
        "main",
        string.format(
          "Traverse from %s(%s) to %s(%s), computed %s",
          nt(prev_node),
          prev_lang,
          nt(ctx.node),
          ctx:lang(),
          ctx.computed_indent
        )
      )
    end
  end

  return ctx.computed_indent
end

function M.get_indent(lnum, bufnr)
  local indent = M.get_ts_indent(lnum, bufnr)
  if type(indent) ~= "number" or indent < 0 then
    -- TODO: call fallback here
    return -1
  else
    return indent
  end
end

function M.indentexpr(vlnum)
  if vlnum == nil then
    vlnum = vim.v.lnum
  end

  local ok, indent = pcall(M.get_indent, vlnum - 1)
  if ok then
    logger("main", "Total computed: " .. indent)
    return indent
  else
    logger("main", "Error: " .. indent)
    vim.schedule(function()
      vim.notify_once(
        string.format("[nvim-yati]: indent computation for line %s failed, please submit an issue", vlnum),
        vim.log.levels.WARN
      )
    end)
    return -1
  end
end

return M
