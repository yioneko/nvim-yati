local utils = require("nvim-yati.utils")
local o = require("nvim-yati.config")
local handlers = require("nvim-yati.handlers")
local Context = require("nvim-yati.context")
local logger = require("nvim-yati.logger")
local get_fallback = require("nvim-yati.fallback").get_fallback
local nt = utils.node_type

local M = {}

---@param ctx YatiContext
local function check_lazy_exit(ctx)
  local conf = ctx:conf()
  if
    conf
    and conf.lazy
    and ctx.node
    and ctx.node:start() ~= ctx.lnum
    and utils.is_first_node_on_line(ctx.node, ctx.bufnr)
  then
    ctx:add(utils.cur_indent(ctx.node:start(), ctx.bufnr))
    logger("main", "Exit early for lazy mode at " .. nt(ctx.node))
    return true
  end
end

---@param conf YatiLangConfig
---@param lnum integer
---@param computed integer
---@param bufnr integer
---@return integer
local function exec_fallback(conf, lnum, computed, bufnr)
  return get_fallback(conf.fallback)(lnum, computed, bufnr)
end

local function can_reparse(lnum, bufnr)
  local line = utils.get_buf_line(bufnr, lnum)
  -- The line only has open delimiter
  -- To fix new line jsx indent caused by 'indentkeys'
  return vim.trim(line):find("^[%[({]$") == nil
end

function M.get_indent(lnum, bufnr, user_conf)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  user_conf = user_conf or o.get_user_config()
  local cget = o.with_user_config_get(user_conf)

  local root_tree = utils.get_parser(bufnr)

  if not root_tree then
    return -1
  end

  -- Firstly, ensure the tree is updated
  if not root_tree:is_valid() and can_reparse(lnum, bufnr) then
    root_tree:parse()
  end

  local bootstrap_lang = utils.get_lang_at_line(lnum, bufnr)
  if not bootstrap_lang then
    return -1
  end

  local bootstrap_conf = cget(bootstrap_lang)
  if not bootstrap_conf then
    return -1
  end

  local node_filter = function(node, lang)
    local c = (lang and cget(lang)) or bootstrap_conf
    return not c.nodes[nt(node)].ignore
  end
  local ctx = Context:new(lnum, bufnr, node_filter, cget)
  if not ctx then
    return -1
  end

  logger("main", string.format("Bootstrap node %s(%s)", nt(ctx.node), ctx:lang()))

  local should_cont = handlers.handle_initial(ctx)
  if ctx.has_fallback then
    local conf = ctx:conf() or bootstrap_conf
    return exec_fallback(conf, lnum, 0, bufnr)
  elseif not ctx.node or not should_cont then
    return ctx.computed_indent
  end

  logger("main", string.format("Initial node %s(%s), computed %s", nt(ctx.node), ctx:lang(), ctx.computed_indent))

  if check_lazy_exit(ctx) then
    return ctx.computed_indent
  end

  ctx:begin_traverse()

  -- main traverse loop
  while ctx.node do
    local prev_node = ctx.node
    local prev_lang = ctx:lang()

    should_cont = handlers.handle_traverse(ctx)
    if ctx.has_fallback then
      local lang = ctx:lang()
      local node = ctx.node
      if lang and node and ctx:conf() then
        return exec_fallback(ctx:conf(), node:start(), ctx.computed_indent, bufnr)
      else
        return exec_fallback(bootstrap_conf, lnum, 0, bufnr)
      end
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

    if check_lazy_exit(ctx) then
      break
    end
  end

  return ctx.computed_indent
end

function M.indentexpr(vlnum)
  if vlnum == nil then
    vlnum = vim.v.lnum
  end

  logger("START", "Line " .. vlnum)
  local ok, indent = pcall(M.get_indent, vlnum - 1)
  if ok then
    logger("END", "Total computed: " .. indent)
    return indent
  else
    logger("END", "Error: " .. indent)
    vim.schedule(function()
      vim.notify_once(
        string.format("[nvim-yati]: indent computation for line %s failed, consider submitting an issue for it", vlnum),
        vim.log.levels.WARN
      )
    end)
    return -1
  end
end

return M
