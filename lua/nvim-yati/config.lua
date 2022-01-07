local M = {}

---@class TSNodeList
---@field named string[]
---@field literal string[]

---@class YatiConfig
---@field indent string[]
---@field indent_last string[]
---@field indent_last_new_line string[]
---@field indent_last_open string[] | boolean
---@field skip_child table<string, TSNodeList>
---@field ignore TSNodeList

---@type YatiConfig
local default = {
  indent = {},
  indent_last = {},
  indent_last_new_line = {},
  indent_last_open = false,
  skip_child = {},
  ignore = {},
}

---@type table<string, YatiConfig>
local overrides = {}

---@param user_overrides table<string, YatiConfig> | nil
function M.setup(user_overrides)
  overrides = user_overrides or {}
end

---@param lang string
---@return YatiConfig | nil
function M.get_config(lang)
  local exists, config = pcall(require, "nvim-yati.configs." .. lang)
  if not exists then
    return
  end

  return vim.tbl_extend("keep", overrides[lang] or {}, config, default)
end

return M
