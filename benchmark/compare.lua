local yati = require("nvim-yati.indent").indentexpr
local nvim_ts = require("nvim-treesitter.indent").get_indent
local bench = require("plenary.benchmark")

local sample_file = "bench_sample.lua"

local function test_indent(get_indent)
  local lines = vim.api.nvim_buf_get_lines(0, 2000, 2200, false)
  for i, line in ipairs(lines) do
    if vim.trim(line) ~= "" then
      -- simulate editing operation to invalidate current syntax tree
      vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, { "" })

      local computed = get_indent(i)
    end
  end
end

local function run_test()
  vim.cmd("edit! " .. sample_file)
  vim.bo.shiftwidth = 2

  bench("nvim_ts", {
    runs = 1,
    fun = {
      {
        "nvim_ts",
        function()
          test_indent(nvim_ts)
        end,
      },
    },
  })
  bench("yati", {
    runs = 1,
    fun = {
      {
        "yati",
        function()
          test_indent(yati)
        end,
      },
    },
  })
end

vim.schedule(function()
  run_test()
  vim.cmd("qall!")
end)
