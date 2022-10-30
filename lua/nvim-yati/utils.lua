local M = {}
local ts_parser = require("nvim-treesitter.parsers")

function M.get_parser(bufnr)
  return ts_parser.get_parser(bufnr)
end

---@return string
function M.get_buf_line(bufnr, lnum)
  return vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, true)[1]
end

function M.get_shift(bufnr)
  -- NOTE: Not work with 'vartabstop'
  local shift = vim.bo[bufnr].shiftwidth
  if shift <= 0 then
    shift = vim.bo[bufnr].tabstop
  end
  return shift
end

function M.node_type(node)
  if node:named() then
    return node:type()
  else
    return "'" .. node:type() .. "'"
  end
end

function M.cur_indent(lnum, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_call(bufnr, function()
    return vim.fn.indent(lnum + 1)
  end)
end

function M.prev_nonblank_lnum(lnum, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local prev = lnum - 1
  while prev >= 0 do
    local line = M.get_buf_line(bufnr, prev)
    if string.match(line, "^%s*$") == nil then
      return prev
    end
    prev = prev - 1
  end
  return -1
end

function M.try_find_parent(node, predicate, limit)
  limit = limit or math.huge
  local cur = node
  while limit >= 0 and cur do
    if predicate(cur) then
      return cur
    end
    cur = cur:parent()
    limit = limit - 1
  end
end

function M.get_nth_parent(node, n)
  local parent = node
  for _ = 1, n do
    if not parent then
      return
    end
    parent = parent:parent()
  end
  return parent
end

function M.get_first_nonblank_col_at_line(lnum, bufnr)
  local line = M.get_buf_line(bufnr, lnum)
  local _, col = string.find(line, "^[%s%\\]*") -- NOTE: Also exclude \ (sample.vim#L6)
  return col or 0
end

function M.get_node_at_line(lnum, named, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local col = M.get_first_nonblank_col_at_line(lnum, bufnr)

  local parser = M.get_parser(bufnr)
  local tree = parser:tree_for_range({ lnum, col, lnum, col })
  if not tree then
    return
  end

  local root = tree:root()
  if named then
    return root:named_descendant_for_range(lnum, col, lnum, col)
  else
    return root:descendant_for_range(lnum, col, lnum, col)
  end
end

function M.pos_cmp(pos1, pos2)
  if pos1[1] == pos2[1] then
    return pos1[2] - pos2[2]
  else
    return pos1[1] - pos2[1]
  end
end

function M.range_contains(range1, range2)
  return M.pos_cmp(range1[1], range2[1]) <= 0 and M.pos_cmp(range1[2], range2[2]) >= 0
end

function M.node_range_inclusive(node)
  local srow, scol, erow, ecol = node:range()
  return { { srow, scol }, { erow, ecol - 1 } }
end

function M.node_contains(node1, node2)
  return M.range_contains(M.node_range_inclusive(node1), M.node_range_inclusive(node2))
end

return M
