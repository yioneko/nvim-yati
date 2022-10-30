local block_comment = require("nvim-yati.handlers.block_comment")

---@type YatiBuiltinConfig
local config = {
  handlers = {
    on_initial = {
      block_comment.block_comment_extra_indent("block_comment"),
    },
  },
}

return config
