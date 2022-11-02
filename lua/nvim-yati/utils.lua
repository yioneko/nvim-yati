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

function M.indent_diff(l1, l2, bufnr)
  return M.cur_indent(l1, bufnr) - M.cur_indent(l2, bufnr)
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

function M.is_line_empty(lnum, bufnr)
  local line = M.get_buf_line(bufnr, lnum)
  return #vim.trim(line) == 0
end

function M.get_first_nonblank_col_at_line(lnum, bufnr)
  local line = M.get_buf_line(bufnr, lnum)
  local _, col = string.find(line or "", "^%s*")
  return col or 0
end

-- Get the bootstrap language for the given line
function M.get_lang_at_line(lnum, bufnr)
  local parser = M.get_parser(bufnr)
  local col = M.get_first_nonblank_col_at_line(lnum, bufnr)
  local lang_tree = parser:language_for_range({ lnum, col, lnum, col })
  return lang_tree:lang()
end

function M.get_node_at_line(lnum, named, bufnr, filter)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local col = M.get_first_nonblank_col_at_line(lnum, bufnr)

  local parser = M.get_parser(bufnr)

  local min_node
  parser.for_each_tree(parser, function(tstree)
    local root = tstree:root()
    local node
    if named then
      node = root:named_descendant_for_range(lnum, col, lnum, col)
    else
      node = root:descendant_for_range(lnum, col, lnum, col)
    end

    -- OK, this is weird, but there are cases where this will be true...
    -- sample.lua#L138
    if node:start() > lnum or node:end_() < lnum then
      return
    end

    while node and filter and not filter(node) do
      node = node:parent()
    end
    if node and (not min_node or M.node_contains(min_node, node)) then
      min_node = node
    end
  end)

  return min_node
end

function M.pos_cmp(pos1, pos2)
  if pos1[1] == pos2[1] then
    return pos1[2] - pos2[2]
  else
    return pos1[1] - pos2[1]
  end
end

function M.range_eql(range1, range2)
  return M.pos_cmp(range1[1], range2[1]) == 0 and M.pos_cmp(range1[2], range2[2]) == 0
end

function M.range_contains(range1, range2)
  return M.pos_cmp(range1[1], range2[1]) <= 0 and M.pos_cmp(range1[2], range2[2]) >= 0
end

function M.node_range(node, inclusive)
  if inclusive == nil then
    inclusive = true
  end
  local ecol_diff = 0
  if inclusive then
    ecol_diff = -1
  end
  local srow, scol, erow, ecol = node:range()
  return { { srow, scol }, { erow, ecol + ecol_diff } }
end

function M.node_contains(node1, node2)
  return M.range_contains(M.node_range(node1), M.node_range(node2))
end

return M
