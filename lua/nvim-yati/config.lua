local M = {}
local extend = require("nvim-yati.utils").extend_config
local get_module_config = require("nvim-treesitter.configs").get_module
local Hook = require("nvim-yati.hook")
local chains = require("nvim-yati.chains")

---@alias tsnode userdata
---@alias tstree userdata

---@class TSNodeList
---@field named string[]
---@field literal string[]

---@class HookCtx
---@field bufnr number
---@field indent number
---@field lnum number
---@field node tsnode
---@field shift number
---@field tree tstree
---@field upper_line number

---@class YatiConfig
---@field indent string[]
---@field indent_last string[]
---@field indent_last_open string[]
---@field skip_child table<string, TSNodeList>
---@field ignore_outer TSNodeList
---@field ignore_within string[]
---@field ignore_self TSNodeList
---@field hook_node Hook
---@field hook_new_line Hook

---@type YatiConfig
local default = {
  indent = {},
  indent_last = {},
  indent_last_open = {},
  skip_child = {},
  ignore_within = { "string", "comment" },
  ignore_outer = {},
  ignore_self = {},
  hook_node = Hook(),
  hook_new_line = Hook(),
}

---@param lang string
---@return YatiConfig | nil
function M.get_config(lang)
  local exists, config = pcall(require, "nvim-yati.configs." .. lang)
  if not exists then
    return
  end

  local overrides = get_module_config("yati").overrides

  local merged = extend(default, extend(config, overrides[lang] or {}))
  vim.list_extend(merged.indent_last, merged.indent_last_open)
  merged.hook_node:add(
    chains.escape_string_end("string", '"'),
    chains.escape_string_end("string", "'"),
    chains.block_comment_extra_indent("comment"),
    chains.ignore_inner_left_binary_expression("binary_expression")
  )
  return merged
end

return M
