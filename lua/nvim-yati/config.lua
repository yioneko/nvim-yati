local get_module_config = require("nvim-treesitter.configs").get_module
local default_handlers = require("nvim-yati.handlers.default")

local M = {}

---@class YatiBuiltinConfig
---@field scope string[]
---@field scope_open string[]
---@field scope_open_extended string[]
---@field indent_zero string[]
---@field indent_align string[]
---@field dedent_child table<string, string[]>
---@field fallback string[]
---@field handlers YatiHandlers

---@class YatiNodeConfig
---@field scope boolean
---@field scope_open boolean
---@field scope_open_extended boolean
---@field indent_zero boolean
---@field indent_align boolean
---@field fallback boolean
---@field dedent_child string[]

---@alias YatiNodesConfig table<string, YatiNodeConfig>

---@class YatiLangConfig
---@field nodes YatiNodesConfig
---@field handlers YatiHandlers

---@type YatiBuiltinConfig
local common_config = {
  scope = {},
  scope_open = {},
  scope_open_extended = {},
  indent_zero = {},
  indent_align = {},
  dedent_child = {},
  fallback = { "comment", "string" },
  handlers = {
    on_initial = { default_handlers.on_initial() },
    on_parent = { default_handlers.on_parent() },
  },
}

---@param config YatiBuiltinConfig
---@return YatiLangConfig
function M.transform_builtin(config)
  ---@type YatiLangConfig
  local transformed = { nodes = {}, handlers = { on_initial = {}, on_parent = {} } }

  setmetatable(transformed.nodes, {
    __index = function(tbl, key)
      rawset(tbl, key, { dedent_child = {} })
      return rawget(tbl, key)
    end,
  })

  for _, node in ipairs(config.scope) do
    transformed.nodes[node].scope = true
  end
  for _, node in ipairs(config.scope_open) do
    transformed.nodes[node].scope = true
    transformed.nodes[node].scope_open = true
  end
  for _, node in ipairs(config.scope_open_extended) do
    transformed.nodes[node].scope = true
    transformed.nodes[node].scope_open = true
    transformed.nodes[node].scope_open_extended = true
  end
  for _, node in ipairs(config.indent_zero) do
    transformed.nodes[node].indent_zero = true
  end
  for _, node in ipairs(config.indent_align) do
    transformed.nodes[node].indent_align = true
  end
  for _, node in ipairs(config.fallback) do
    transformed.nodes[node].fallback = true
  end
  for node, child_list in pairs(config.dedent_child) do
    transformed.nodes[node].scope = true
    transformed.nodes[node].dedent_child = child_list
  end
  for _, handler in ipairs(config.handlers.on_parent) do
    table.insert(transformed.handlers.on_parent, 1, handler)
  end
  for _, handler in ipairs(config.handlers.on_initial) do
    table.insert(transformed.handlers.on_initial, 1, handler)
  end

  return transformed
end

---@param base YatiBuiltinConfig
---@param config YatiBuiltinConfig
---@return YatiBuiltinConfig
function M.extend(base, config)
  local merged = vim.deepcopy(base)

  vim.list_extend(merged.scope, config.scope or {})
  vim.list_extend(merged.scope_open, config.scope_open or {})
  vim.list_extend(merged.scope_open_extended, config.scope_open_extended or {})
  vim.list_extend(merged.indent_zero, config.indent_zero or {})
  vim.list_extend(merged.indent_align, config.indent_align or {})
  vim.list_extend(merged.fallback, config.fallback or {})
  merged.dedent_child = vim.tbl_extend("force", merged.dedent_child, config.dedent_child or {})

  return merged
end

---@param lang string
---@return boolean
function M.is_supported(lang)
  local user_config = get_module_config("yati").overrides
  if user_config and user_config[lang] then
    return true
  end
  local exists = pcall(require, "nvim-yati.configs." .. lang)
  return exists
end

---@type table<string, YatiLangConfig>
local lang_config_cache = {}

---@param lang string
---@return YatiLangConfig
function M.get(lang)
  local user_config = get_module_config("yati").overrides
  if user_config and user_config[lang] then
    return user_config[lang]
  end
  if not lang_config_cache[lang] then
    local ok, config = pcall(require, "nvim-yati.configs." .. lang)
    if ok then
      lang_config_cache[lang] = M.transform_builtin(M.extend(common_config, config))
    end
  end
  return lang_config_cache[lang]
end

return M
