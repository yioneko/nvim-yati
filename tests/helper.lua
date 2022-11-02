local assert = require("luassert")
local say = require("say")
local get_indent = require("nvim-yati.indent").get_indent
local scandir = require("plenary.scandir").scan_dir
local utils = require("nvim-yati.utils")

local test_file_dir = "tests/fixtures/"
local ignore_pattern = ".*%.fail%..*"
local test_langs = {
  "c",
  "cpp",
  "graphql",
  "html",
  "javascript",
  "json",
  "lua",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vue",
}

local M = {}

local function same_indent(state, arguments)
  local lnum = arguments[1]
  local expected = arguments[2]

  local indent = get_indent(lnum - 1)
  return indent == expected
end

---@param bufnr number buffer number
---@param marker_str string marker for the empty line
---@return table<number, number> empty_indents a lnum to indent size map
local function extract_marker(bufnr, marker_str)
  local empty_indents = {}
  local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for lnum, line in ipairs(content) do
    -- count the number of spaces at the beginning of the line and trim the line
    local _, indent = line:find("^%s*")
    if line:sub(indent + 1) == marker_str then
      empty_indents[lnum] = indent
      vim.api.nvim_buf_set_lines(bufnr, lnum - 1, lnum, true, { "" })
    end
  end

  return empty_indents
end

function M.expected_indents_iter(marker_str, bufnr)
  local line_cnt = vim.api.nvim_buf_line_count(bufnr)
  local empty_indents = extract_marker(bufnr, marker_str)
  local lnum = 0
  return function()
    while lnum < line_cnt do
      lnum = lnum + 1
      local expected = utils.cur_indent(lnum - 1, bufnr)
      if empty_indents[lnum] then
        return lnum, empty_indents[lnum]
      elseif expected ~= 0 then
        return lnum, expected
      end
    end
  end
end

function M.get_test_langs()
  return test_langs
end

function M.get_test_files(lang)
  local files = scandir(test_file_dir .. lang)
  return vim.tbl_filter(function(file)
    return vim.fs.basename(file):find(ignore_pattern) == nil
  end, files)
end

function M.basename(path)
  return vim.fs.basename(path)
end

function M.setup()
  say:set_namespace("en")
  say:set("assertion.same_indent.negative", "Line %s didn't indent to %s.")
  say:set("assertion.same_indent.positive", "Line %s didn't indent to %s.")

  assert:register(
    "assertion",
    "same_indent",
    same_indent,
    "assertion.same_indent.positive",
    "assertion.same_indent.negative"
  )
end

return M
