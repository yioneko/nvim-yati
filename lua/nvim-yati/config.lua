local get_module_config = require("nvim-treesitter.configs").get_module
local fallback = require("nvim-yati.fallback")

local M = {}

---@class YatiBuiltinConfig
---@field scope string[]
---@field scope_open string[]
---@field scope_open_extended string[]
---@field indent_zero string[]
---@field indent_align string[]
---@field indent_list string[]
---@field indent_fallback string[]
---@field ignore string[]
---@field dedent_child table<string, string[]>
---@field handlers YatiHandlers
---@field fallback fun(lnum: integer, computed: integer, bufnr: integer):integer

---@class YatiNodeConfig
---@field scope boolean
---@field scope_open boolean
---@field scope_open_extended boolean
---@field indent_zero boolean
---@field indent_align boolean
---@field indent_list boolean
---@field indent_fallback boolean
---@field ignore boolean
---@field dedent_child string[]

---@alias YatiNodesConfig table<string, YatiNodeConfig>

---@class YatiLangConfig
---@field nodes YatiNodesConfig
---@field handlers YatiHandlers
---@field fallback fun(lnum: integer, computed: integer, bufnr: integer):integer
---@field lazy_mode boolean

---@class YatiUserConfig
---@field overrides table<string, YatiLangConfig>
---@field default_fallback nil|fun(lnum: integer, computed: integer, bufnr: integer):integer
---@field default_lazy nil|boolean

---@type YatiBuiltinConfig
local common_config = {
  scope = {},
  scope_open = {},
  scope_open_extended = {},
  indent_zero = {},
  indent_align = {},
  indent_list = {},
  dedent_child = {},
  -- ignore these outermost nodes to work around cross tree issue
  ignore = { "source", "document", "chunk", "script_file", "source_file", "program" },
  fallback = fallback.default_fallback,
  indent_fallback = { "ERROR" },
  handlers = {
    on_initial = {},
    on_traverse = {},
  },
}

---@param config YatiBuiltinConfig
---@return YatiLangConfig
function M.transform_builtin(config)
  ---@type YatiLangConfig
  local transformed = { nodes = {}, handlers = { on_initial = {}, on_traverse = {} } }

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
  for _, node in ipairs(config.indent_list) do
    transformed.nodes[node].indent_list = true
  end
  for _, node in ipairs(config.ignore) do
    transformed.nodes[node].ignore = true
  end
  for _, node in ipairs(config.indent_fallback) do
    transformed.nodes[node].indent_fallback = true
  end
  for node, child_list in pairs(config.dedent_child) do
    transformed.nodes[node].scope = true
    transformed.nodes[node].dedent_child = child_list
  end
  transformed.handlers.on_traverse = config.handlers.on_traverse or {}
  transformed.handlers.on_initial = config.handlers.on_initial or {}
  transformed.fallback = config.fallback

  return transformed
end

---@param base YatiBuiltinConfig
---@param config YatiBuiltinConfig
---@return YatiBuiltinConfig
function M.extend(base, config)
  local merged = vim.deepcopy(base)

  vim.list_extend(merged.scope or {}, config.scope or {})
  vim.list_extend(merged.scope_open or {}, config.scope_open or {})
  vim.list_extend(merged.scope_open_extended or {}, config.scope_open_extended or {})
  vim.list_extend(merged.indent_zero or {}, config.indent_zero or {})
  vim.list_extend(merged.indent_align or {}, config.indent_align or {})
  vim.list_extend(merged.indent_list or {}, config.indent_list or {})
  vim.list_extend(merged.indent_fallback or {}, config.indent_fallback or {})
  vim.list_extend(merged.ignore or {}, config.ignore or {})
  if config.handlers then
    vim.list_extend(merged.handlers.on_initial or {}, config.handlers.on_initial or {})
    vim.list_extend(merged.handlers.on_traverse or {}, config.handlers.on_traverse or {})
  end
  if config.fallback then
    merged.fallback = config.fallback
  end
  merged.dedent_child = vim.tbl_extend("force", merged.dedent_child or {}, config.dedent_child or {})

  return merged
end

---@return YatiUserConfig
function M.get_user_config()
  return get_module_config("yati")
end

---@param lang string
---@return boolean
function M.is_supported(lang)
  local user_config = M.get_user_config()
  if user_config.overrides and user_config.overrides[lang] then
    return true
  end
  local exists = pcall(require, "nvim-yati.configs." .. lang)
  return exists
end

---@type table<string, YatiLangConfig>
local builtin_lang_config_cache = {}

---@param lang string
---@return YatiLangConfig
function M.get_builtin(lang)
  if not builtin_lang_config_cache[lang] then
    local ok, config = pcall(require, "nvim-yati.configs." .. lang)
    if ok then
      builtin_lang_config_cache[lang] = M.transform_builtin(M.extend(common_config, config))
    end
  end
  return builtin_lang_config_cache[lang]
end

---@type table<string, YatiLangConfig>
local lang_config_cache = {}
local memo_user_config -- use user config as memoize key

---@param lang string
---@return YatiLangConfig
function M.get(lang)
  local user_config = M.get_user_config()
  local conf = M.get_builtin(lang)
  if not user_config then
    return conf
  end

  if user_config == memo_user_config and lang_config_cache[lang] then
    return lang_config_cache[lang]
  end

  memo_user_config = user_config
  local overrides = user_config.overrides
  if overrides and overrides[lang] then
    conf = overrides[lang]
  end

  if user_config.default_lazy then
    conf.lazy_mode = user_config.default_lazy
  end
  if user_config.default_fallback then
    conf.fallback = user_config.default_fallback
  end

  lang_config_cache[lang] = conf
  return conf
end

return M
