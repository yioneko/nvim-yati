local assert = require("luassert")
local get_indent = require("nvim-yati.indent").get_indent
local say = require("say")
local marker = "MARKER"
local test_file_dir = "test/fixtures"
local test_files = {
  cpp = { "sample.cpp" },
  c = { "sample.c" },
  css = { "sample.css" },
  graphql = { "sample.graphql" },
  html = { "sample.html" },
  javascript = { "sample.js" },
  json = { "sample.json" },
  lua = { "sample.lua" },
  python = { "sample.py" },
  rust = { "sample.rs" },
  toml = { "sample.toml" },
  typescript = { "sample.ts" },
  vue = { "sample.vue" },
}

local function same_indent(state, arguments)
  local lnum = arguments[1]
  local expected = arguments[2]

  local indent = get_indent(lnum - 1)
  return indent == expected
end

local function setup_lazy_mode()
  require("nvim-treesitter.configs").setup({
    yati = {
      default_lazy = true,
    },
  })
end

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

for lang, files in pairs(test_files) do
  describe(lang .. " indentation in", function()
    for _, file in ipairs(files) do
      describe("[" .. file .. "]", function()
        before_each(function()
          vim.cmd("edit! " .. test_file_dir .. "/" .. file)
        end)

        after_each(function()
          vim.cmd("bdelete!")
        end)

        it("should be correct", function()
          local empty_indents = extract_marker(0, marker)
          local line_cnt = vim.api.nvim_buf_line_count(0)

          for lnum = 1, line_cnt do
            local indent = vim.fn.indent(lnum)
            if empty_indents[lnum] then
              assert.same_indent(lnum, empty_indents[lnum])
            elseif indent ~= 0 then
              assert.same_indent(lnum, indent)
            end
          end
        end)
      end)
    end
  end)

  describe(lang .. " indentation in", function()
    setup_lazy_mode()

    for _, file in ipairs(files) do
      describe("[" .. file .. "] with lazy mode", function()
        before_each(function()
          vim.cmd("edit! " .. test_file_dir .. "/" .. file)
        end)

        after_each(function()
          vim.cmd("bdelete!")
        end)

        it("should be correct", function()
          local empty_indents = extract_marker(0, marker)
          local line_cnt = vim.api.nvim_buf_line_count(0)

          for lnum = 1, line_cnt do
            local indent = vim.fn.indent(lnum)
            if empty_indents[lnum] then
              assert.same_indent(lnum, empty_indents[lnum])
            elseif indent ~= 0 then
              assert.same_indent(lnum, indent)
            end
          end
        end)
      end)
    end
  end)
end
