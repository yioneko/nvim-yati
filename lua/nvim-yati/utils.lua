local M = {}

---Extend the config table with max depth 2
---@param config YatiConfig
---@param extend YatiConfig
function M.extend_config(config, extend)
  ---@type YatiConfig
  local merged = vim.deepcopy(config)
  for k, v in pairs(extend) do
    if type(v) == "table" then
      if vim.tbl_islist(v) then
        merged[k] = vim.list_extend(merged[k] or {}, v)
      else
        merged[k] = vim.tbl_extend("force", merged[k] or {}, v)
      end
    else
      merged[k] = v
    end
  end
  return merged
end

function M.get_buf_line(bufnr, lnum)
  return vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, true)[1]
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
  local _, col = string.find(line, "^%s*")
  return col or 0
end

function M.get_node_at_line(lnum, tree, named, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root = tree:root()

  local col = M.get_first_nonblank_col_at_line(lnum, bufnr)
  if named then
    return root:named_descendant_for_range(lnum, col, lnum, col)
  else
    return root:descendant_for_range(lnum, col, lnum, col)
  end
end

return M
