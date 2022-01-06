local M = {}

function M.attach(bufnr, lang)
  vim.api.nvim_buf_set_option(bufnr, "indentexpr", 'v:lua.require("nvim-yati.indent").get_indent()')
end

function M.detach(bufnr)
  -- TODO: Fill this with what you need to do when detaching from a buffer
end

return M
