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

return M
