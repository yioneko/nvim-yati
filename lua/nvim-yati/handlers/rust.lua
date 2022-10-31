local nt = require("nvim-yati.utils").node_type

local M = {}

local function check_prev_field_closed(field_node, bufnr)
  local lines = vim.treesitter.get_node_text(field_node, bufnr, { concat = false })
  for i = #lines, 1, -1 do
    local first_char = vim.trim(lines[i]):sub(1, 1)
    -- skip previous chained field or empty line
    if first_char ~= "" and first_char ~= "." then
      -- find close delimeter
      if first_char:find("^[%]})>]") ~= nil then
        return true
      else
        break
      end
    end
  end
  return false
end

-- Related: sample.rs#L203
function M.dedent_field_on_close_initial(field_expression)
  ---@param ctx YatiContext
  return function(ctx)
    if
      ctx.node
      and nt(ctx.node) == field_expression
      and ctx.node:child(0)
      and check_prev_field_closed(ctx.node:child(0), ctx.bufnr)
    then
      -- skip default indent
      return true
    end
  end
end

function M.dedent_field_on_close_traverse(field_expression, field_type)
  ---@param ctx YatiContext
  return function(ctx)
    if
      (nt(ctx.node) == field_type or ctx.node:type() == ".")
      and ctx:parent()
      and nt(ctx:parent()) == field_expression
      and check_prev_field_closed(ctx:first_sibling(), ctx.bufnr)
    then
      ctx:to_parent()
      return true
    end
  end
end

return M
