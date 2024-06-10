local ch = require("nvim-yati.handlers.common")

---@type YatiBuiltinConfig
local config = {
  handlers = {
    on_initial = {
      ch.block_comment_extra_indent("comment", { "'text'", "source", "description", "document" }),
      ch.block_comment_extra_indent("block_comment", { "'text'", "source", "description", "document", "'*/'" }),
    },
  },
}

return config
