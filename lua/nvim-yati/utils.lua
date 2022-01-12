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

return M
