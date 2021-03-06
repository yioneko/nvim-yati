local M = {}
local ts_parser = require("nvim-treesitter.parsers")

---Extend the config table with max depth 2
---@param config YatiConfig
---@param extend YatiConfig
function M.extend_config(config, extend)
  ---@type YatiConfig
  local merged = vim.deepcopy(config)
  for k, v in pairs(extend) do
    -- Don't deep extend hooks
    if type(v) == "table" and v.chains == nil then
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

function M.is_supported(lang)
  return pcall(require, "nvim-yati.configs." .. lang)
end

function M.get_parser(bufnr)
  return ts_parser.get_parser(bufnr)
end

---@return string
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

function M.try_find_child(node, predicate, limit)
  limit = limit or 5
  if limit == 0 then
    return
  end
  for child, _ in node:iter_children() do
    if predicate(child) then
      return child
    else
      local res = M.try_find_child(child, predicate, limit - 1)
      if res then
        return res
      end
    end
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

-- Transform end position (x, 0) to (x-1, '$')
function M.get_normalized_end(node, bufnr)
  local erow, ecol = node:end_()
  if ecol == 0 and erow > 0 then
    erow = erow - 1
    ecol = M.get_buf_line(bufnr, erow):len()
  end
  return erow, ecol
end

function M.pos_cmp(pos1, pos2)
  if pos1[1] == pos2[1] then
    return pos1[2] - pos2[2]
  else
    return pos1[1] - pos2[1]
  end
end

function M.contains(node1, node2)
  local srow1, scol1, erow1, ecol1 = node1:range()
  local srow2, scol2, erow2, ecol2 = node2:range()
  return M.pos_cmp({ srow1, scol1 }, { srow2, scol2 }) <= 0 and M.pos_cmp({ erow1, ecol1 }, { erow2, ecol2 }) >= 0
end

function M.node_has_injection(node, bufnr)
  local root_lang_tree = M.get_parser(bufnr)
  local res = false

  root_lang_tree:for_each_child(function(child, lang)
    for _, tree in ipairs(child:trees()) do
      if M.contains(node, tree:root()) and M.is_supported(lang) then
        res = true
      end
    end
  end)

  return res
end

return M
