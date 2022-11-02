local utils = require("nvim-yati.utils")

local M = {}

---@alias YatiFallbackFn fun(lnum: integer, computed: integer, bufnr: integer): integer
---@alias YatiFallback "cindent"|"asis"|"auto"|YatiFallbackFn

---@param lnum integer
---@param computed integer
---@param bufnr integer
---@return integer
function M.vim_cindent(lnum, computed, bufnr)
  -- TODO: lispindent ?
  local cindent = vim.api.nvim_buf_call(bufnr, function()
    return vim.fn.cindent(lnum + 1)
  end)
  return cindent + computed
end

---@param lnum integer
---@param computed integer
---@param bufnr integer
---@return integer
function M.as_is(lnum, computed, bufnr)
  return utils.cur_indent(lnum, bufnr) + computed
end

function M.vim_auto()
  return -1
end

---Get resolved fallback method from config option
---@param fallback YatiFallback
function M.get_fallback(fallback)
  if type(fallback) == "function" then
    return fallback
  elseif fallback == "cindent" then
    return M.vim_cindent
  elseif fallback == "asis" then
    return M.as_is
  else
    return M.vim_auto
  end
end

return M
