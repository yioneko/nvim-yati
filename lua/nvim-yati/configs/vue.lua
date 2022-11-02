---@type YatiBuiltinConfig
local config = {
  scope = {
    "template_element",
    "element",
    "start_tag",
    "end_tag",
    "self_closing_tag",
  },
  ignore = { "text" },
}

return config
