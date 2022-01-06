---@type YatiConfig
local config = {
  indent = {
    "compound_statement",
    "argument_list",
    "field_declaration_list",
    "enumerator_list",
    "parameter_list",
    "initializer_list",
  },
  indent_last = {
    "for_statement",
    "return_statement",
    "shift_expression",
    "call_expression",
    "field_expression",
    "logical_expression",
    "math_expression",
    "relational_expression",
    "assignment_expression",
    "field_initializer_list",
    "init_declarator",
  },
  ignore = { named = { "comment", "preproc_function_def" } },
}

return config
