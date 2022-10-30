local utils = require("nvim-yati.utils")

local M = {}

---@return YatiInitialHandler
function M.block_comment_extra_indent(comment, pattern)
  pattern = pattern or "^%s*%*"
  ---@param ctx YatiInitialCtx
  return function(ctx)
    local node = utils.get_node_at_line(ctx.lnum, true, ctx.bufnr)
    if
      node
      and node:type() == comment
      and node:start() ~= ctx.lnum
      and utils.get_buf_line(ctx.bufnr, ctx.lnum):match(pattern) ~= nil
    then
      return node
    end
  end
end

return M
