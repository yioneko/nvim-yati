local M = {}
local stored_expr = {}

function M.attach(bufnr, lang)
  stored_expr[bufnr] = vim.api.nvim_buf_get_option(bufnr, "indentexpr")
  vim.api.nvim_buf_set_option(bufnr, "indentexpr", 'v:lua.require("nvim-yati.indent2").indentexpr()')
end

function M.detach(bufnr)
  vim.api.nvim_buf_set_option(bufnr, "indentexpr", stored_expr[bufnr])
  stored_expr[bufnr] = nil
end

return M
