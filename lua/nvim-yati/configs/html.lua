---@type YatiBuiltinConfig
local config = {
  scope = {
    "element",
    "style_element",
    "script_element",
    "start_tag",
    "end_tag",
    "self_closing_tag",
  },
  ignore = {
    "raw_text",
  },
}

return config
