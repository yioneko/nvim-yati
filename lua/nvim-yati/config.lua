local M = {}
local extend = require("nvim-yati.utils").extend_config
local get_module_config = require("nvim-treesitter.configs").get_module

---@alias tsnode userdata
---@alias tstree userdata

---@class TSNodeList
---@field named string[]
---@field literal string[]

---@class HookCtx
---@field bufnr number
---@field tree tstree
---@field upper_line number
---@field shift number

---@class YatiConfig
---@field indent string[]
---@field indent_last string[]
---@field indent_last_open string[] | boolean
---@field skip_child table<string, TSNodeList>
---@field ignore_outer TSNodeList
---@field ignore_within string[]
---@field ignore_self TSNodeList
---@field hook_node fun(node: tsnode, ctx: HookCtx): number, tsnode
---@field hook_new_line fun(lnum: number, node: tsnode, ctx: HookCtx): number, tsnode

---@type YatiConfig
local default = {
  indent = {},
  indent_last = {},
  indent_last_open = false,
  skip_child = {},
  ignore_within = { "string", "comment" },
  ignore_outer = {},
  ignore_self = {},
  -- Used to handle complex scenarios
  hook_node = function(node, ctx) end,
  hook_new_line = function(lnum, node, ctx) end,
}

---@param lang string
---@return YatiConfig | nil
function M.get_config(lang)
  local exists, config = pcall(require, "nvim-yati.configs." .. lang)
  if not exists then
    return
  end

  local overrides = get_module_config("yati").overrides

  return extend(default, extend(config, overrides[lang] or {}))
end

return M
