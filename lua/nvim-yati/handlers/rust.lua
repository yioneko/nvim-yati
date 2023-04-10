local utils = require("nvim-yati.utils")
local nt = utils.node_type

local M = {}

local function check_prev_field_closed(field_node, bufnr)
  local lines = vim.split(vim.treesitter.get_node_text(field_node, bufnr, {}), "\n")
  for i = #lines, 1, -1 do
    local first_char = vim.trim(lines[i]):sub(1, 1)
    -- skip previous chained field or empty line
    if first_char ~= "" and first_char ~= "." then
      -- find close delimeter
      if first_char:find("^[%]})>]") ~= nil then
        local prev_line = field_node:end_() - #lines + i
        return utils.get_node_at_line(prev_line, false, bufnr)
      else
        break
      end
    end
  end
end

-- Related: sample.rs#L203
function M.dedent_field_on_close_initial(field_expression)
  ---@param ctx YatiContext
  return function(ctx)
    if ctx.node and nt(ctx.node) == field_expression and ctx.node:child(0) then
      local prev_close_node = check_prev_field_closed(ctx.node:child(0), ctx.bufnr)
      if prev_close_node then
        ctx:relocate(prev_close_node)
        return true
      end
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
    then
      local prev_close_node = check_prev_field_closed(ctx:first_sibling(), ctx.bufnr)
      if prev_close_node then
        ctx:relocate(prev_close_node)
        return true
      end
    end
  end
end

return M
