---@type YatiBuiltinConfig
local config = {
  scope = {
    "template_element",
    "element",
    "start_tag",
    "end_tag",
    "interpolation",
    "self_closing_tag",
  },
  ignore = { "text", "raw_text" },
}

return config
