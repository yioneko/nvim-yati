---@type YatiConfig
local config = {
  indent = {
    "element",
    "style_element",
    "script_element",
    "start_tag",
    "end_tag",
    "self_closing_tag",
  },
  ignore_self = { named = { "text" } },
}

return config
