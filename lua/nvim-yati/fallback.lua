local M = {}

---@param lnum integer
---@param computed integer
function M.default_fallback(lnum, computed, bufnr)
  -- TODO: lispindent
  local cindent = vim.api.nvim_buf_call(bufnr, function()
    return vim.fn.cindent(lnum + 1)
  end)
  return cindent + computed
end

return M
