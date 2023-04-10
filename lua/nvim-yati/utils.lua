local M = {}

---@return LanguageTree
function M.get_parser(bufnr)
  local ft = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ft)
  return vim.treesitter.get_parser(bufnr, lang)
end

---@return string
function M.get_buf_line(bufnr, lnum)
  return vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, true)[1] or ""
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

function M.is_line_empty(lnum, bufnr)
  local line = M.get_buf_line(bufnr, lnum)
  return #vim.trim(line) == 0
end

function M.get_first_nonblank_col_at_line(lnum, bufnr)
  local line = M.get_buf_line(bufnr, lnum)
  local _, col = string.find(line or "", "^%s*")
  return col or 0
end

function M.is_first_node_on_line(node, bufnr)
  local line, col = node:start()
  return M.get_first_nonblank_col_at_line(line, bufnr) >= col
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

  local res_node
  local cur_root
  parser.for_each_tree(parser, function(tstree, lang_tree)
    local root = tstree:root()
    local rsr, rsc, rer, rec = root:range()
    if
      not M.range_contains(rsr, rsc, rer, rec, lnum, col, lnum, col + 1)
      or (cur_root and M.node_contains(root, cur_root))
    then
      return
    end

    local node
    if named then
      node = root:named_descendant_for_range(lnum, col, lnum, col + 1)
    else
      node = root:descendant_for_range(lnum, col, lnum, col + 1)
    end

    -- make sure the returned node contains the range
    local sr, sc, er, ec = node:range()
    if not M.range_contains(sr, sc, er, ec, lnum, col, lnum, col + 1) then
      return
    end

    while node and filter and not filter(node, lang_tree:lang()) do
      node = node:parent()
    end
    if
      node --[[ (not res_node or M.node_contains(res_node, node)) ]]
    then
      res_node = node
      cur_root = root
    end
  end)

  return res_node
end

-- Do not use table here to drastically improve performance
function M.range_contains(sr1, sc1, er1, ec1, sr2, sc2, er2, ec2)
  if sr1 > sr2 or (sr1 == sr2 and sc1 > sc2) then
    return false
  end
  if er1 < er2 or (er1 == er2 and ec1 < ec2) then
    return false
  end
  return true
end

function M.node_contains(node1, node2)
  local srow1, scol1, erow1, ecol1 = node1:range()
  local srow2, scol2, erow2, ecol2 = node2:range()
  return M.range_contains(srow1, scol1, erow1, ecol1, srow2, scol2, erow2, ecol2)
end

return M
