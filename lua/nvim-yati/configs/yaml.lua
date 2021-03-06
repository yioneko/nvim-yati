local utils = require("nvim-yati.utils")
local Hook = require("nvim-yati.hook")

---@type YatiConfig
local config = {
  indent = {
    "flow_sequence",
  },
  indent_last = {
    "block_sequence_item",
  },
  indent_last_open = {
    "block_mapping_pair",
    "block_scalar",
  },
  ignore_self = { named = { "block_node", "block_sequence", "block_mapping" } },
  hook_new_line = Hook(function(ctx)
    local prev_line = utils.prev_nonblank_lnum(ctx.lnum, ctx.bufnr)
    local prev_node = utils.get_node_at_line(prev_line, ctx.tree, true, ctx.bufnr)

    -- - b: aa
    --   |
    if
      prev_node:type() == "block_sequence_item"
      and utils.try_find_child(prev_node, function(child)
        return child:type() == "block_mapping_pair" and child:start() == prev_line
      end)
    then
      return ctx.shift, prev_node:parent()
    end

    -- b: (>|)
    --   |
    -- c: aaa
    -- |
    do
      local mapping_pair = utils.try_find_parent(prev_node, function(parent)
        return parent:type() == "block_mapping_pair" and parent:start() == prev_line
      end)
      if mapping_pair then
        local line = utils.get_buf_line(ctx.bufnr, prev_line)
        if line:match("[:>|]%s*$") ~= nil then
          return 0, mapping_pair
        else
          local next = mapping_pair:parent()
          -- Skip the original node
          if next and next:id() == ctx.node:id() then
            next = next:parent()
          end
          return 0, next
        end
      end
    end
  end),
}

return config
